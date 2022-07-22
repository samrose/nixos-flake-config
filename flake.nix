{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      hydra-fractaldyn-server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ({
            modulesPath,
            pkgs,
            ...
          }: {
            imports = ["${modulesPath}/virtualisation/amazon-image.nix"];
            system.stateVersion = "22.05";
	    ec2.hvm = true;
            networking.firewall.allowedTCPPorts = [80 443 3000];
            security.acme.defaults = {
              email = "samuel.rose@gmail.com";
            };
            security.acme.acceptTerms = true;
            services.nginx = {
              enable = true;

              virtualHosts.hydra = {
                enableACME = true;
                forceSSL = true;
                locations = {
                  "/".proxyPass = "http://localhost:3000";
                };
                serverName = "hydra.fractaldyn.io";
              };
            };
            services.hydra = {
              enable = true;
              hydraURL = "http://localhost:3000";
              notificationSender = "hydra@localhost";
              buildMachinesFiles = [];
              useSubstitutes = true;
            };
          })
        ];
      };
    };
  };
}
