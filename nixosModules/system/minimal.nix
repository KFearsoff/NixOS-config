{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.minimal;
in
{
  options.nixchad.minimal = {
    enable = mkEnableOption "various options to reduce system size";
  };

  config = mkIf cfg.enable {
    # taken from K900: https://gitlab.com/K900/nix/-/blob/faf75f4f91c980d8d1175d8868ca28952872f689/shared/server.nix
    nixchad.location.timezone = "UTC";

    # save some space on servers
    boot.enableContainers = false;
    environment.defaultPackages = [ ];
    # system.disableInstallerTools = true;
    documentation.enable = false;

    # reduce logspam
    networking.firewall.logRefusedConnections = false;

    # optimized network settings
    boot.kernel.sysctl = {
      # buffer limits: 32M max, 16M default
      "net.core.rmem_max" = 33554432;
      "net.core.wmem_max" = 33554432;
      "net.core.rmem_default" = 16777216;
      "net.core.wmem_default" = 16777216;
      "net.core.optmem_max" = 40960;

      # cloudflare uses this for balancing latency and throughput
      # https://blog.cloudflare.com/the-story-of-one-latency-spike/
      "net.ipv4.tcp_mem" = "786432 1048576 26777216";
      "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";

      # http://www.nateware.com/linux-network-tuning-for-2013.html
      "net.core.netdev_max_backlog" = 100000;
      "net.core.netdev_budget" = 100000;
      "net.core.netdev_budget_usecs" = 100000;

      "net.ipv4.tcp_max_syn_backlog" = 30000;
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 10;

      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;
    };
  };
}
