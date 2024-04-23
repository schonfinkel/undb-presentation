{
  description = "Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, devenv, nixpkgs, ... }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      mkPkgs = system: nixpkgsFor."${system}";

      mkEnv = pkgs: pkgs.texlive.combine {
        inherit (pkgs.texlive)
        beamer
        beamertheme-metropolis
        caption
        collection-basic
        collection-fontsextra
        collection-fontsrecommended
        collection-langenglish
        collection-langportuguese
        collection-latexextra
        hyphen-portuguese
        latexmk
        paracol
        pdfx
        pgfopts
        ragged2e
        scheme-basic
        unicode-math
        xetex
        xkeyval;
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = mkPkgs system;
          texenv = mkEnv pkgs;
        in
        {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "document";
            src = self;
            buildInputs = with pkgs; [ bash coreutils gnumake texenv ];
            phases = ["unpackPhase" "buildPhase" "installPhase"];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}"
              export XDG_CACHE_HOME="$(mktemp -d)"
              make
            '';
            installPhase = ''
              mkdir -p $out
              cp slide.pdf $out/
            '';
          };
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.document);

      devShells = forAllSystems (system:
        let
          pkgs = mkPkgs system;
          texenv = mkEnv pkgs;
        in
        {
          # To be run with:
          #   nix develop .#ci
          # Reduces the number of packages to the bare minimum needed for CI
          ci = pkgs.mkShell {
            buildInputs = with pkgs; [ 
              gnumake
              texenv
            ];
          };

          # `nix develop`
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ({ pkgs, lib, ... }: {
                packages = with pkgs; [
                  bash
                  gnumake
                  texenv
                ];

                languages.texlive.enable = true;
              })
            ];
          };
        });
    };
}
