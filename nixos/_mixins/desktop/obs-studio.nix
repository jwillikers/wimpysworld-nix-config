{ config, pkgs, ... }: {
  # https://nixos.wiki/wiki/OBS_Studio
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1
  '';

  environment.systemPackages = with pkgs; [
    (unstable.wrapOBS {
      plugins = with unstable.obs-studio-plugins; [
        advanced-scene-switcher
        obs-3d-effect
        obs-command-source
        obs-gradient-source
        obs-gstreamer
        obs-move-transition
        obs-mute-filter
        obs-pipewire-audio-capture
        obs-rgb-levels-filter
        obs-scale-to-sound
        obs-shaderfilter
        obs-source-clone
        obs-source-record
        obs-source-switcher
        obs-teleport
        obs-text-pthread
        obs-transition-table
        obs-vaapi
        obs-vertical-canvas
        obs-vintage-filter
        obs-websocket
        waveform
      ];
    })
  ];
}
