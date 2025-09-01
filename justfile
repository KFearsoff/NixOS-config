COLMENA_FLAGS := "--verbose --keep-result"

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
  @nix-collect-garbage --delete-older-than 7d && sudo nix-collect-garbage --delete-older-than 7d

gc-full:
  @nix-collect-garbage --delete-old && sudo nix-collect-garbage --delete-old

update:
  @nix flake update

history:
  @nix profile diff-closures --profile /nix/var/nix/profiles/system

preview:
  @nixos-rebuild --flake .# build -v && nvd diff /run/current-system ./result

preview-remote HOST=`uname -n`:
  @nixos-rebuild --flake ".#{{HOST}}" build -v && nvd diff ".gcroots/node-{{HOST}}" ./result

wat OPTION HOST=`uname -n`:
  @nix eval ".#nixosConfigurations.{{HOST}}.config.{{OPTION}}"

deploy TARGETS="blueberry,cloudberry" +ARGS="":
  @colmena apply --on {{TARGETS}} {{COLMENA_FLAGS}} {{ARGS}}

deploy-boot TARGETS="blueberry,cloudberry" +ARGS="":
  @colmena apply boot --on {{TARGETS}} {{COLMENA_FLAGS}} {{ARGS}}

build-all +ARGS="":
  @colmena build {{COLMENA_FLAGS}} {{ARGS}}

eval HOST=`uname -n`:
  @nom build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel
