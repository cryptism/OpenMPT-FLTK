{
  description = "OpenMPT-FLTK: a native FLTK port of the OpenMPT tracker";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # The fltk/ and openmpt/ submodules are part of the build, and GitHub tarballs leave submodules
  # out, so fetch with ?submodules=1:
  #   nix build 'git+https://github.com/cryptism/OpenMPT-FLTK?ref=drude&submodules=1'
  #   nix build 'git+file:///path/to/checkout?submodules=1'
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        openmpt-fltk = pkgs.callPackage ./nix/package.nix {
          src = self;
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
        };
        default = openmpt-fltk;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/OpenMPT";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          packages = [ pkgs.gdb ];
        };
      });
    };
}
