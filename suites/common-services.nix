{ lib, ... }:
{
  nixchad = {
    smartctl-exporter.enable = lib.mkDefault true;
    alloy.enable = true;
    resticModule.enable = true;
  };
}
