{ pkgs, config, inputs, unstable, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager.useUserPackages = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users.user = {
      imports = with pkgs.lib; [
        {
          options = {
            also.unstable = mkOption {
              type = types.attrs;
              default = unstable;
            };
            also.inputs = mkOption {
              type = types.attrs;
              default = inputs;
            };
          };
        }
        ./home-config.nix
      ];
    };
  };
}
