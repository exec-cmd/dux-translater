#!/bin/sh
# Remove the duxTranslate plugin directory. Settings and API keys in plugin_settings.json stay.
set -eu

id=duxTranslate
config=${XDG_CONFIG_HOME:-$HOME/.config}
dest=$config/dms/plugins/$id

if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
	echo "nothing to remove at $dest"
	exit 0
fi
if ! grep -q "\"id\": \"$id\"" "$dest/plugin.json" 2>/dev/null; then
	echo "skip    $dest (not $id)" >&2
	exit 1
fi
rm -rf "$dest"
echo "removed $dest"
