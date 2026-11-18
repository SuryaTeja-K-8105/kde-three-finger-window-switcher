#!/usr/bin/env bash
set -euo pipefail

project_dir="$HOME/.config/three-finger-window-switcher"
source_file="$project_dir/bin/kwin_gestures.so"
config_source="$project_dir/inputactions-config.yaml"
plugin_dir=/usr/lib64/qt6/plugins/kwin/effects/plugins
plugin_file="$plugin_dir/kwin_gestures.so"
backup_file="$plugin_file.before-gesture-fix"
config_file="$HOME/.config/inputactions/config.yaml"
config_backup="$config_file.before-gesture-fix"

if [[ ! -r "$source_file" || ! -r "$config_source" ]]; then
    printf 'Fixed plugin or its matching config is missing from %s\n' "$project_dir" >&2
    exit 1
fi

if [[ -e "$plugin_file" && ! -e "$backup_file" ]]; then
    sudo cp -a "$plugin_file" "$backup_file"
fi

sudo install -D -m 0755 "$source_file" "$plugin_file"
if [[ -e "$config_file" && ! -e "$config_backup" ]]; then
    cp -a "$config_file" "$config_backup"
fi
install -D -m 0644 "$config_source" "$config_file"
printf 'Installed the fixed InputActions plugin. Log out and back in to load it.\n'
