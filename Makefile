switch:
	sudo nixos-rebuild --flake '.#' switch -v

test:
	sudo nixos-rebuild --flake '.#' test -v

system-gc:
	sudo nix-collect-garbage

home-gc:
	sudo home-manager expire-generations -30days

update:
	sudo nix flake update
