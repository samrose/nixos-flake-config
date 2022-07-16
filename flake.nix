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
      nomad-nginx-server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ({
            modulesPath,
            pkgs,
            ...
          }: {
            imports = ["${modulesPath}/virtualisation/amazon-image.nix"];
            ec2.hvm = true;
            networking.firewall.allowedTCPPorts = [80 443 8080 4646];
            services.nginx.enable = true;
            services.nomad.enable = true;
            services.nomad.settings = {
              # A minimal config example:
              server = {
                enabled = true;
                bootstrap_expect = 1; # for demo; no fault tolerance
              };
              client = {
                enabled = true;
              };
            };
          })
        ];
      };
    };
  };
}
