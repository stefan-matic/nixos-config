{ pkgs, ... }:

{
  # Taskwarrior 3 CLI + taskwarrior-tui (terminal UI)
  # Data: ~/.local/share/task, Config: ~/.config/task/taskrc (via TASKRC env)
  # CLI: `task add "thing"`, `task list`, `task <id> done`
  # TUI: `taskwarrior-tui`

  home.packages = with pkgs; [
    taskwarrior3
    taskwarrior-tui
  ];

  home.sessionVariables = {
    TASKRC = "$HOME/.config/task/taskrc";
    TASKDATA = "$HOME/.local/share/task";
  };

  xdg.configFile."task/taskrc".text = ''
    # Taskwarrior config (managed by home-manager)
    data.location=~/.local/share/task

    # UI
    color=on
    detection=on
    defaultwidth=0

    # Default report
    default.command=next

    # Urgency tuning (lower age weight so old tasks don't dominate)
    urgency.age.coefficient=1.0
    urgency.blocking.coefficient=8.0
    urgency.blocked.coefficient=-5.0

    # News notice acknowledgement (suppress 3.x upgrade prompts after first run)
    news.version=3.4.2
  '';
}
