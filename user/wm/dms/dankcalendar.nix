{ inputs, ... }:

# DankCalendar (dcal) Configuration
# Local, Google, Microsoft, CalDAV and iCloud calendars in DMS style.
# Runs as a tray daemon; OAuth tokens go to the Secret Service (KeePassXC).
#
# View logs with: journalctl --user -u dcal
# Open the UI with: dcal

{
  imports = [ inputs.dankcalendar.homeModules.dank-calendar ];

  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
  };
}
