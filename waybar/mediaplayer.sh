#!/bin/sh

player_status=$(playerctl status 2> /dev/null)

title=$(playerctl metadata title)
song_info="${title}"
if artist=$(playerctl metadata artist); then
    artist="${artist}"
else
    artist="unknown artist"
fi
if album=$(playerctl metadata album); then
    album="${album}"
else
    album="unknown album"
fi
tooltip="${artist} - ${album}"


if [ "$player_status" = "Playing" ]; then
    output="► ${song_info}"
elif [ "$player_status" = "Paused" ] ; then
    output="⏹ ${song_info}"
fi

waybar_tooltip()
{
    echo "$1" | while read -r line; do
        count="${#line}"
        [ "$count" -lt 69 ] && line="${line}$(printf "%$((69 - count))s")"
        printf '%s' "$line "
    done
}

printf "{ \"text\": \"%s\", \"tooltip\": \"%s\" }\n" \
       "$output" "$(waybar_tooltip "$tooltip")"

# echo $output
