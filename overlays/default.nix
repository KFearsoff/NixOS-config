{
  additions = final: _: import ../pkgs {pkgs = final;};
  tailscale-overlay = _: prev: {tailscale = prev.tailscale.overrideAttrs (_: {subPackages = ["cmd/tailscale" "cmd/tailscaled" "cmd/nginx-auth"];});};
}
