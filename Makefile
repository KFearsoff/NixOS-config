switch:
	sudo nixos-rebuild --flake '.#' switch -v

test:
	sudo nixos-rebuild --flake '.#' test -v

boot:
	sudo nixos-rebuild --flake '.#' boot -v

dry:
	sudo nixos-rebuild --flake '.#' dry-activate -v

vm:
	sudo nixos-rebuild --flake '.#' build-vm -v

vm-boot:
	sudo nixos-rebuild --flake '.#' build-vm-with-bootloader -v

gc:
	sudo nix-collect-garbage --delete-older-than 7d

update:
	sudo nix flake update

diff:
	nix profile diff-closures --profile /nix/var/nix/profiles/system | less

preview:
	sudo nixos-rebuild --flake '.#' build -v && nix store diff-closures /var/run/current-system ./result
