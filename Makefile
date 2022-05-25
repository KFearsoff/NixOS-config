switch:
	nixos-rebuild --use-remote-sudo --flake '.#' switch -v

test:
	nixos-rebuild --use-remote-sudo --flake '.#' test -v

boot:
	nixos-rebuild --use-remote-sudo --flake '.#' boot -v

dry:
	nixos-rebuild --use-remote-sudo --flake '.#' dry-activate -v

vm:
	nixos-rebuild --use-remote-sudo --flake '.#' build-vm -v

vm-boot:
	nixos-rebuild --use-remote-sudo --flake '.#' build-vm-with-bootloader -v

gc:
	sudo nix-collect-garbage --delete-older-than 7d

update:
	nix flake update

diff:
	nix profile diff-closures --profile /nix/var/nix/profiles/system | less

preview:
	nixos-rebuild --use-remote-sudo --flake '.#' build -v && nix store diff-closures /var/run/current-system ./result
