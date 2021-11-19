switch:
	sudo nixos-rebuild --flake '.#' switch -v

test:
	sudo nixos-rebuild --flake '.#' test -v

boot:
	sudo nixos-rebuild --flake '.#' boot -v

gc:
	sudo nix-collect-garbage --delete-older-than 7d

update:
	sudo nix flake update
