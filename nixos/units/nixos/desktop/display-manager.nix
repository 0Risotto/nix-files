{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktop.displayManager {
    # The theme and greeter packages come from Ryoku's module (theme = "ryoku").
    services.displayManager.sddm.enable = true;
  };
}
