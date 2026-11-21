#!/bin/sh
# Install src/ as the duxTranslate plugin of Dux Shell 2.x.
set -eu

usage() {
	cat <<'EOF'
Usage: install.sh [--link] [--force]

--link   symlink src/ instead of copying (edits in the repo apply after a reload)
--force  replace an existing plugin directory that is not dmsTranslate
EOF
	exit "${1:-0}"
}

link=0 force=0
while [ $# -gt 0 ]; do
	case $1 in
	--link) link=1 ;;
	--force) force=1 ;;
	-h | --help) usage ;;
	*) usage 1 ;;
	esac
	shift
done

id=duxTranslate
repo=$(cd "$(dirname "$0")" && pwd)
config=${XDG_CONFIG_HOME:-$HOME/.config}
base=$config/dms/plugins
dest=$base/$id

# Before 2.0 the plugin was dmsTranslate. Remove it, or both would show up in the shell.
old=$base/dmsTranslate
if { [ -e "$old" ] || [ -L "$old" ]; } && { [ ! -e "$old/plugin.json" ] || grep -q '"id": "dmsTranslate"' "$old/plugin.json"; }; then
	rm -rf "$old"
	echo "removed old plugin $old"
	echo "migrate: enable Dux Translate in Settings -> Plugins; settings and keys are copied on first load."
	echo "         add the Dux Translate widget to the bar again and change the keybind id to $id."
fi

if [ -e "$dest" ] || [ -L "$dest" ]; then
	if [ "$force" -eq 0 ] && ! grep -q "\"id\": \"$id\"" "$dest/plugin.json" 2>/dev/null; then
		echo "$dest exists and is not $id; use --force to replace it" >&2
		exit 1
	fi
	rm -rf "$dest"
fi

mkdir -p "$base"
if [ "$link" -eq 1 ]; then
	ln -s "$repo/src" "$dest"
else
	cp -R "$repo/src" "$dest"
fi

echo "installed $dest"
echo "reload: dms ipc call plugins reload $id (or Settings -> Plugins -> Scan for Plugins)"
