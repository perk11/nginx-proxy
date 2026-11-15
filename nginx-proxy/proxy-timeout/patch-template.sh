#!/bin/sh
# Teaches upstream's nginx.tmpl the com.github.perk11.nginx-proxy.proxy-timeout
# container label: vpath.tmpl reads it next to the keepalive label,
# location.tmpl writes it into the proxy_pass location. Each snippet goes in
# after a line that must occur exactly once; anything else fails the build
# instead of producing an image that silently ignores the label.
#   patch-template.sh /app/nginx.tmpl
set -eu
tmpl=$1
dir=$(dirname "$0")
vpath_anchor='{{- $_ := set $vpath_data "keepalive" $keepalive }}'
location_anchor='set $upstream_keepalive {{ if ne $keepalive "disabled" }}true{{ else }}false{{ end }};'

for anchor in "$vpath_anchor" "$location_anchor"; do
	n=$(grep -c -F -- "$anchor" "$tmpl" || true)
	if [ "$n" != 1 ]; then
		echo "patch-template.sh: '$anchor' occurs $n times in $tmpl, expected once; the base image's template changed" >&2
		exit 1
	fi
done

awk -v va="$vpath_anchor" -v la="$location_anchor" \
	-v vs="$dir/vpath.tmpl" -v ls="$dir/location.tmpl" '
	{ print }
	index($0, va) { while ((getline l < vs) > 0) print l }
	index($0, la) { while ((getline l < ls) > 0) print l }
' "$tmpl" > "$tmpl.new"

for marker in 'set $vpath_data "proxy_timeout"' 'proxy_read_timeout {{ $vpath.proxy_timeout }};'; do
	n=$(grep -c -F -- "$marker" "$tmpl.new" || true)
	if [ "$n" != 1 ]; then
		echo "patch-template.sh: '$marker' ended up $n times in the patched template, expected once" >&2
		rm -f "$tmpl.new"
		exit 1
	fi
done
mv "$tmpl.new" "$tmpl"
echo "patch-template.sh: $tmpl now honours com.github.perk11.nginx-proxy.proxy-timeout"
