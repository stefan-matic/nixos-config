{
  config,
  lib,
  ...
}:

with lib; {
  home.file.".config/hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pgrep hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      ignore_dbus_inhibit = false
    }

    # FIXME memory leak fries computer inbetween dpms off and suspend
    #listener {
    #  timeout = 150 # in seconds
    #  on-timeout = hyprctl dispatch dpms off
    #  on-resume = hyprctl dispatch dpms on
    #}
    listener {
      timeout = 165 # in seconds
      on-timeout = loginctl lock-session
    }
    listener {
      timeout = 180 # in seconds
      #timeout = 5400 # in seconds
      on-timeout = systemctl suspend
      on-resume = hyprctl dispatch dpms on
    }
  '';
}