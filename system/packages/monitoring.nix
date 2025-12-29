{ pkgs, ... }:

{
  # System monitoring and debugging tools
  # Performance monitoring and troubleshooting

  environment.systemPackages = with pkgs; [
    # Process & Resource Monitoring
    htop
    iotop
    iftop

    # System Call Tracing & Debugging
    strace
    ltrace
    lsof
  ];
}
