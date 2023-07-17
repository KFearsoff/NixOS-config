default: update deploy

switch:
  @sudo nixos-rebuild --flake .# switch -v

test:
  @sudo nixos-rebuild --flake .# test -v

boot:
  @sudo nixos-rebuild --flake .# boot -v

dry:
  @sudo nixos-rebuild --flake .# dry-activate -v

gc:
  @nix-collect-garbage --delete-older-than 7d

gc-full:
  @nix-collect-garbage --delete-old

update:
  @nix flake update

history:
  @nix profile diff-closures --profile /nix/var/nix/profiles/system

preview:
  @nixos-rebuild --flake .# build -v && nvd diff /run/current-system ./result

wat OPTION HOST=`uname -n`:
  @nix eval ".#nixosConfigurations.{{HOST}}.config.{{OPTION}}"

deploy +TARGETS=".#":
  @deploy --targets {{TARGETS}} -k -- -v --impure
