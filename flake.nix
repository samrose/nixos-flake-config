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

            nix.extraOptions = ''
              restrict-eval = false
              experimental-features = nix-command flakes
            '';
            security.acme.defaults = {
              email = "samuel.rose@gmail.com";
            };
            security.acme.acceptTerms = true;
            services.nginx = {
              recommendedProxySettings = true;
              recommendedOptimisation = true;
              recommendedTlsSettings = true;
              recommendedGzipSettings = true;
              enable = true;

              virtualHosts."hydra.fractaldyn.io" = {
                enableACME = true;
                forceSSL = true;
                locations = {
                  "/" = {proxyPass = "http://127.0.0.1:3000";};
                };
              };
            };
            services.hydra = {
              enable = true;
              hydraURL = "https://hydra.fractaldyn.io";
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
