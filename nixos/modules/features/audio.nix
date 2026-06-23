{ self, inputs, ... }:
{
  flake.nixosModules.audio = { config, pkgs, ... }:
  {
    security.rtkit.enable = true;
    
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;  
      jack.enable = true;   
    };
    
    environment.systemPackages = with pkgs; [
      pavucontrol          
      pulsemixer          # Terminal-based volume mixer
      alsa-utils          # ALSA utilities (aplay, arecord, etc.)
      alsa-tools          # Additional ALSA tools
      pamixer             # PulseAudio command-line mixer
      playerctl           # Media player controls
    ];
    

    services.dbus.enable = true;
  };
}