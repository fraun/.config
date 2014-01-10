#!/bin/bash



dzen_fn="-*-terminus-medium-*-*-*-10-*-*-*-*-*-*-*"
dzen_fg="#ffffff"
dzen_bg="#002b36"

[[ $0 == /* ]] && script="$0" || script="${PWD}/${0#./}"
panelfolder=${script%/*}
trap 'herbstclient emit_hook quit_panel' TERM
herbstclient pad 0 16
herbstclient emit_hook quit_panel

# Start conky first so it is in the background
conky -c "$~/.config/herbstluftwm/panel/conkyrc" | dzen2 -fn "$dzen_fn" -h 16 -fg "$dzen_fg" -bg "$dzen_bg" -e 'button3=' &
#pids+=($!)

$panelfolder/tray.sh &
#pids+=($!)

$panelfolder/tags.sh &
#pids+=($!)

#conky -c conkyrc &



herbstclient --wait '^(quit_panel|reload).*'
kill -TERM "${pids[@]}" >/dev/null 2>&1
exit 0
