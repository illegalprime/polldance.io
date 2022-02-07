let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/ceaca998029d4b1ac7fd2bee985a3b0f37a786b5.tar.gz";
    sha256 = "02wa4bw6s800b9inn8hznr56v4v8x3y44sj9lwmkw9zbxzw6mi7s";
  };
  pkgs = import nixpkgs {};
  pwd = toString ./.;
  inherit (pkgs.lib) optional optionals;
  dart-sass = pkgs.callPackage ./nix/dart-sass {};
in
with pkgs;
mkShell {
  buildInputs = [
    beam.packages.erlangR24.elixir_1_12
    postgresql_10
    git
    nixops
  ]
  # For file_system on Linux.
  ++ optional stdenv.isLinux inotify-tools
  # For file_system on macOS.
  ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    CoreFoundation
    CoreServices
  ]);

  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";

  # Put the PostgreSQL databases in the project diretory.
  shellHook = ''
    export PGDATA="$PWD/db"
    export MIX_SASS_PATH=${dart-sass}/bin/sass
    export MIX_ESBUILD_PATH=${esbuild}/bin/esbuild
    export NIX_PATH="nixpkgs=${nixpkgs}:${pwd}/nix/ops"
    export NIXOPS_STATE="${pwd}/secret/localstate.nixops"
    source <(awk '{print "export " $0}' ${pwd}/secret/env)
  '';
}
