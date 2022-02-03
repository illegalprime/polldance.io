{ stdenv, lib, fetchzip, runCommand, remarshal, dart, makeWrapper }:

{ pname # must be the same as pubspec.yaml's name
, version
, src
, pub2nix
, buildDir ? "build"
, executables
, buildType ? "release"
, dartFlags ? [ ]
}:
let
  fromYAML = yaml: builtins.fromJSON (builtins.readFile (
    runCommand "from-yaml" {
      inherit yaml;
      allowSubstitutes = false;
      preferLocalBuild = true;
    } ''
      ${remarshal}/bin/remarshal  \
        -if yaml \
        -i <(echo "$yaml") \
        -of json \
        -o $out
    ''));

  lockFile = fromYAML (builtins.readFile pub2nix);

  # TODO: https://github.com/dart-lang/pub/blob/6deb457048deb435009b36a4cd2d86003d107cf4/lib/src/source/hosted.dart#L441-L468
  pubCache = let
    step = (state: package: let
      pubCachePathParent = lib.concatStringsSep "/" [
        "$out"
        package.source
        (lib.removePrefix "https://" package.description.url)
      ];
      pubCachePath = lib.concatStringsSep "/" [
        pubCachePathParent
        "${package.description.name}-${package.version}"
      ];
      nixStorePath = fetchzip {
        inherit (package) sha256;
        stripRoot = false;
        url = lib.concatStringsSep "/" [
          package.description.url
          "packages"
          package.description.name
          "versions"
          "${package.version}.tar.gz"
        ];
      };
      in
      state + ''
        mkdir -p ${pubCachePathParent}
        ln -s ${nixStorePath} ${pubCachePath}
      ''
    );

    synthesize = builtins.foldl' step "" (builtins.attrValues lockFile.packages);
    in
    runCommand "${pname}_pub-cache" {} synthesize;


  installSnapshots = let
    inherit (builtins) attrNames;
    inherit (lib) concatStringsSep mapAttrsToList;
    installSnapshot = name: ''
      cp "${buildDir}/${name}.snapshot" "$out/lib/dart/${pname}/"
      makeWrapper "${dart}/bin/dart" "$out/bin/${name}" \
        --argv0 "${name}" \
        --add-flags "$out/lib/dart/${pname}/${name}.snapshot"
    '';
    steps = map installSnapshot (attrNames executables);
  in concatStringsSep "\n" steps;

  dartOpts = with lib;
    concatStringsSep " " ((optional (buildType == "debug") "--enable-asserts")
      ++ [ "-Dversion=${version}" ]
      ++ dartFlags);

  buildSnapshots = let
    inherit (lib) concatStringsSep mapAttrsToList;
    buildSnapshot = name: path:
      with lib; ''
        dart ${dartOpts} --snapshot="${buildDir}/${name}.snapshot" "bin/${path}.dart"
      '';
    steps = mapAttrsToList buildSnapshot executables;
  in concatStringsSep "\n" steps;
in
stdenv.mkDerivation {
  inherit pname version src;

  buildInputs = [
    dart
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  preBuildPhases = [
    "dotPackages"
    "pubCache"
    "pubGet"
    "dartAnalyzer"
  ];
  # Some tooling still expects this file to exist
  dotPackages = ''
    touch .packages
  '';
  pubCache = ''
    ln -s ${pubCache} .pub-cache
    export PUB_CACHE=.pub-cache
  '';
  pubGet = ''
    pub get --no-precompile --offline
  '';
  dartAnalyzer = ''
    dartanalyzer .
  '';
  buildPhase = ''
    mkdir -p ${buildDir}
    ${buildSnapshots}
  '';
  installPhase = ''
    mkdir -p $out/bin $out/lib/dart/${pname}
    ${installSnapshots}
  '';
}
