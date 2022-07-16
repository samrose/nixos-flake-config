{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      nginx-server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ({pkgs, ...}: {
            networking.firewall.allowedTCPPorts = [ 80 443 ];
            services.nginx.enable = true;
          })
        ];
      };
    };
  };
}
