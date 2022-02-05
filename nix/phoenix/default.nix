{ callPackage }:

let
  dart-sass = callPackage ../dart-sass {};

  fetchMixDeps = callPackage ./fetch-mix-deps.nix {
    inherit (beam.packages.erlangR24) hex rebar rebar3;
    elixir = beam.packages.erlangR24.elixir_1_12;
  };

  buildMix = callPackage ./build-mix.nix {
    inherit (beam.packages.erlangR24) hex rebar rebar3;
    elixir = beam.packages.erlangR24.elixir_1_12;
    inherit fetchMixDeps dart-sass;
  };
in
buildMix {
  pname = "pollparty.io";
  version = "0.5.0";
  mixSha256 = "1x81bazy1fz1i22n519ildkmmc3hzaprsk38zfq0cmzddifyd8ia";
  src = builtins.fetchGit ../..;
}
