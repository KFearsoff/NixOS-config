#!@bash@/bin/sh
## shellcheck & shfmt please

BASE_HOSTS="@baseHosts@"
export PATH="$PATH:@tailscale@/bin:@jq@/bin"

while true; do
	if tailscale status >/dev/null; then
		newhosts=$(mktemp)
		cat "$BASE_HOSTS" >"$newhosts"
		tailscale status --json | jq -r '([.Peer[]] + [.Self])[] | [.TailscaleIPs[0], (.HostName | split(" ") | join("-") | ascii_downcase) + "@hostSuffix@"] | @tsv' >> "$newhosts"
		chmod 444 "$newhosts"
		rm /run/coredns-hosts
		mv "$newhosts" /run/coredns-hosts
	fi
	sleep 5
done
