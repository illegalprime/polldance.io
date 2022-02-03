{ fetchFromGitHub, callPackage }:
let
  buildDartPackage = callPackage ./build-dart.nix {};
in
buildDartPackage rec {
  pname = "sass";
  version = "1.49.0";

  src = fetchFromGitHub {
    owner = "sass";
    repo = "dart-sass";
    rev = "${version}";
    sha256 = "0xh8ibih2rwk5zzcpxp99ca63vndlf7rnlchn7m479gknrqpzwwh";
  };

  executables = {
    dart-sass = "sass";
    sass = "sass";
  };

  pub2nix = "${./pub2nix.yaml}";
}
