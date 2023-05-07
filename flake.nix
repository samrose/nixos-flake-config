{
  description = "NixOS postgrest configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      });
  in {
    # A Nixpkgs overlay.
    overlay = final: prev: {
      postgrest = with final;
        stdenv.mkDerivation rec {
          pname = "postgrest";
          version = "0.0.0";
          src = fetchurl {
            url = "https://github.com/PostgREST/postgrest/releases/download/v10.1.0/postgrest-v10.1.0-linux-static-x64.tar.xz";
            sha256 = "sha256-n8kigbECI0g3fQKinwawfqxjumRy5slndd4Ff+yj91A=";
          };
          sourceRoot = ".";
          #setSourceRoot = "sourceRoot=`pwd`";
          # Add runtime dependencies to buildInputs.
          buildInputs = [];

          # Add runtime dependencies required by packages that
          # depend on this package to propagatedBuildInputs.
          propagatedBuildInputs = [];

          # Add buildtime dependencies (not required at runtime)
          # to nativeBuildInputs.
          nativeBuildInputs = [];
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp -r . $out/bin
            runHook postInstall
          '';
        };
    };
    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}) postgrest;
    });
    nixosConfigurations = {
      nomad-nginx-server = nixpkgs.lib.nixosSystem {
        inherit ;
        specialArgs = {inherit inputs;};
        modules = [
          ({
            modulesPath,
            pkgs,
            ...
          }: {
            imports = ["${modulesPath}/virtualisation/amazon-image.nix"];
            ec2.hvm = true;
            networking.firewall.allowedTCPPorts = [80 443];
            services.nginx.enable = true;
          })
        ];
      };
    };
  };
}

