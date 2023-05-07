{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nomad-nginx-server = lib.makeOverridable nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ({
            modulesPath,
            pkgs,
            ...
          }: {
            networking.firewall.allowedTCPPorts = [80 443 8080 4646];
            users.extraUsers.root.password = ""; # oops
            users.mutableUsers = false;
            # virtualisation = {
            # diskSize = 8000; # MB
            #   memorySize = 2048; # MB
            #   writableStoreUseTmpfs = false;
            # };

            services.openssh.enable = true;
            services.openssh.permitRootLogin = "yes";
            networking.firewall.enable = true;
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
