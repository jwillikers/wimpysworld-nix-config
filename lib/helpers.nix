{ inputs, outputs, stateVersion, ... }: {
  # Helper function for generating home-manager configs
  mkHome = { hostname, username, desktop ? null, platform ? "x86_64-linux" }:
  let
    isISO = builtins.substring 0 4 hostname == "iso-";
    isInstall = !isISO;
    isWorkstation = builtins.isString desktop;
  in
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.${platform};
    extraSpecialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion isInstall isISO isWorkstation;
    };
    modules = [ ../home-manager ];
  };

  # Helper function for generating host configs
  mkHost = { hostname, username, desktop ? null, platform ? "x86_64-linux" }:
  let
    isISO = builtins.substring 0 4 hostname == "iso-";
    isInstall = !isISO;
    isWorkstation = builtins.isString desktop;
  in
  inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs outputs desktop hostname platform username stateVersion isInstall isISO isWorkstation;
    };
    # If the hostname starts with "iso-", generate an ISO image
    modules = let
      cd-dvd = if (desktop == null) then
                 inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
               else
                 inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix";
    in
    [
      ../nixos
    ] ++ inputs.nixpkgs.lib.optionals (isISO) [ cd-dvd ];
  };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
