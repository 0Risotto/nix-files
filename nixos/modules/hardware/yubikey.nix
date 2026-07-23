_: {
  flake.nixosModules.yubikey =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    lib.mkIf config.settings.yubikey {
      services.pcscd.enable = true;

      services.udev.packages = with pkgs; [
        yubikey-personalization
      ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      environment.systemPackages = with pkgs; [
        yubikey-manager
        yubikey-personalization
        opensc
        pcsclite
      ];
    };
}
