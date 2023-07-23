let
  hosts = ["blackberry" "blueberry" "cloudberry"];
in {
  lib.metadata = {
    getInterface = host:
      if (host == "blackberry")
      then "enp4s0"
      else "eth0";
    hasIpv4 = _: true;
    hasIpv6 = host: host == "cloudberry";
    hostList = hosts;
  };
}
