#!/bin/bash

set -u -o pipefail
shopt -s nocasematch

BROWSER='firefox'
BROWSER_CLASSES='chromium|firefox|tor browser|navigator'

# call with id property_name
get_property() {
    xprop -id "$1" "$2" | cut -f 2 -d '=' | tr -d '[:punct:]'
}

running_browser() {
    IFS='|' read -ra BROWSERS <<< "$BROWSER_CLASSES"
    for B in "${BROWSERS[@]}"; do
        if xdotool search --class "$B" >& /dev/null; then
            echo "$B"
            return 0
        fi
    done
}

open_in_default_browser_or_current_window() {
    CURRENT_ID="$(xdotool getwindowfocus)"
    CLASSES="$(get_property $CURRENT_ID WM_CLASS)"

    if grep -qiE "$BROWSER_CLASSES" <<< "$CLASSES"; then
        NAME="$(get_property $CURRENT_ID WM_NAME)"
        xdotool key --window "$CURRENT_ID" Escape
        if [[ "$NAME" =~ .*Vimperator ]]; then
            xdotool windowfocus "$CURRENT_ID" # just to be sure
            if [[ "$NAME" =~ New[[:space:]]*Tab.* ]]; then
                xdotool type --window "$CURRENT_ID" ':open ' "$@"
            else
                xdotool type --window "$CURRENT_ID" ':tabopen ' "$@"
            fi
            xdotool key --window "$CURRENT_ID" Return
        else
            # the hackiest hack you have ever seen to open the argument in the
            # currently focused browser window
            xdotool windowfocus "$CURRENT_ID" # just to be sure
            if [[ "$NAME" =~ New[[:space:]]*Tab.* ]]; then
                xdotool key --window "$CURRENT_ID" ctrl+l
            else
                xdotool key --window "$CURRENT_ID" ctrl+t
            fi
            xdotool type --window "$CURRENT_ID" "$@"
            # somehow one return just isn't enough...
            xdotool key --window "$CURRENT_ID" Return
            xdotool key --window "$CURRENT_ID" Return
        fi
    else
        B="$(running_browser)"
        echo $B
        BROWSER="${B:-$BROWSER}"
        echo $BROWSER
        $BROWSER "$@"
    fi
}

open_in_default_browser_or_current_window "$@"
