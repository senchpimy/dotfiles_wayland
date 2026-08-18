#!/usr/bin/env bash
mode="${1:-walls}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
themesDir="$XDG_CONFIG_HOME/hyde/themes"
hydeConf="$XDG_CONFIG_HOME/hyde/hyde.conf"

theme="$(sed -n 's/^hydeTheme="\([^"]*\)"/\1/p' "$hydeConf" 2>/dev/null | head -1)"
[ -z "$theme" ] && theme="Local"

items="[]"
current=""

if [ "$mode" = "themes" ]; then
    current="$theme"
    items="$(find "$themesDir" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null | sort \
        | while IFS= read -r d; do
            wallset="$(readlink -f "$d/wall.set" 2>/dev/null)"
            [ -f "$wallset" ] || continue
            name="$(basename "$d")"
            jq -cn --arg n "$name" --arg i "$wallset" '{name:$n, image:$i, payload:$n}'
        done \
        | jq -cs '.')"
else
    dir="$themesDir/$theme/wallpapers"
    current="$(readlink -f "$themesDir/$theme/wall.set" 2>/dev/null)"
    cachedir="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/media/wallpapers"
    mkdir -p "$cachedir"
    items="$(find "$dir" -maxdepth 1 -type f \( -iname '*.gif' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.mp4' \) -print 2>/dev/null | sort \
        | while IFS= read -r f; do
            f="$(readlink -f "$f")"
            n="$(basename "$f")"; n="${n%.*}"
            thumb=""
            ext="${f##*.}"; ext="${ext,,}"
            if [ "$ext" = "mp4" ]; then
                # Image can't decode a video, so bake a first-frame still the
                # carousel can paint while the player isn't running (same
                # approach as pibble's ffmpeg thumbnail). Cached by path hash
                # and only regenerated when the source is newer.
                key=$(printf '%s|t1' "$f" | md5sum | cut -d' ' -f1)
                t="$cachedir/$key.png"
                if [ ! -f "$t" ] || [ "$f" -nt "$t" ]; then
                    if command -v ffmpeg >/dev/null 2>&1; then
                        ffmpeg -y -v error -i "$f" -vframes 1 -vf "scale='min(1920,iw)':-1:flags=lanczos,unsharp=5:5:0.8:5:5:0.0" "$t" 2>/dev/null
                    fi
                fi
                [ -f "$t" ] && thumb="$t"
            fi
            jq -cn --arg n "$n" --arg i "$f" --arg t "$thumb" '{name:$n, image:$i, thumb:$t, payload:$i}'
        done \
        | jq -cs '.')"
fi

jq -cn --argjson items "$items" --arg current "$current" '{items:$items, current:$current}'
