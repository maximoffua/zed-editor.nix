{
  description = "Zed editor from Zed Industries, creators of Atom editor.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: let
        rustPackages = inputs'.fenix.packages;
        rustWasm = rustPackages.combine [
          rustPackages.targets.wasm32-wasip1.latest.rust-std
          rustPackages.latest.cargo
          rustPackages.latest.rustc
        ];
      in {
        overlayAttrs = config.packages;
        packages = rec {
          default = zed-editor;
          zed-editor = pkgs.callPackage ./package {};
          zed-editor-bin = pkgs.callPackage ./package/binary.nix {};
          zed-editor-fhs = zed-editor.fhs;
          zed-editor-dev = zed-editor.fhsWithPackages (_: [rustWasm pkgs.node]);
          zed-editor-pre = pkgs.callPackage ./package/pre-release.nix {
            inherit rustWasm;
            supportCustomExtensions = true;
          };
        };
      };
      flake = {
      };
    };
}
