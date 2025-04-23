{ lib, ... }:
{
  nixchad = {
    smartctl-exporter.enable = lib.mkDefault true;
    alloy.enable = true;
    restic.enable = true;
  };
}
