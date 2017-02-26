#!/bin/bash

# requirements: surfraw, xdotool, xprop

# inspired by: https://github.com/gotbletu/shownotes/blob/master/rofi_websearch_bookmarks_surfraw.md

BROWSER="firefox"
BROWSER_CLASSES="chromium|firefox"
ELVI_DIRECTORIES=("/usr/lib/surfraw/" "$HOME/.config/surfraw/elvi/")
BOOKMARKS="$HOME/.config/surfraw/bookmarks"

set -eu

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
    return 1
}

open_in_default_browser_or_current_window() {
    CURRENT_ID="$(xdotool getwindowfocus)"
    CLASSES="$(get_property $CURRENT_ID WM_CLASS)"

    if grep -qiE "$BROWSER_CLASSES" <<< "$CLASSES"; then
        NAME="$(get_property $CURRENT_ID WM_NAME)"
        if [[ "$NAME" =~ .*Vimperator ]]; then
            xdotool windowfocus "$CURRENT_ID" # just to be sure
            xdotool type --window "$CURRENT_ID" ':tabopen ' "$@"
            xdotool key --window "$CURRENT_ID" Return
        else
            # the hackiest hack you have ever seen to open the argument in the
            # currently focused browser window
            xdotool windowfocus "$CURRENT_ID" # just to be sure
            xdotool key --window "$CURRENT_ID" ctrl+t
            xdotool type --window "$CURRENT_ID" "$@"
            # somehow one return just isn't enough...
            xdotool key --window "$CURRENT_ID" Return
            xdotool key --window "$CURRENT_ID" Return
        fi
    else
        B="$(running_browser)"
        BROWSER="${B-$BROWSER}"
        "$BROWSER" "$@"
    fi
}

list_elvi() {
    ARRAY=()
    for DIR in "${ELVI_DIRECTORIES[@]}"; do
        ARRAY+=( ${DIR}* )
    done
    printf "%s\n" "${ARRAY[@]##*/}" | sort -n
}

list_bookmarks() {
    sed '/^$/d' < "$BOOKMARKS" | sort -n
}

list_both() {
    (list_elvi; list_bookmarks | cut -f 1 -d ' ') | sort -n
}

MSG='(swapped tab and c-space)'
ROFI_ARGS=" -kb-row-select Tab -kb-row-tab Control+space -dmenu -i \
    -levenshtein-sort -matching fuzzy"

# call with list function as first argument
get_surfraw_url() {
    PRM='web:'
    # lack of double quotes intentional
    ARG="$("$1" | rofi $ROFI_ARGS -p "$PRM" -mesg "$MSG")"
    [ -n "$ARG" ] && SURFRAW_print=yes surfraw $ARG
}

get_bookmark() {
    PRM='bkm:'
    ARG="$(list_bookmarks | rofi $ROFI_ARGS -p "$PRM" -mesg "$MSG")"
    [ -n "$ARG" ] && tr -s ' ' <<< "$ARG" | cut -f 2 -d ' '
}

case "$1" in
    bookmark)
        ARG="$(get_bookmark)"
        [ -n "$ARG" ] && open_in_default_browser_or_current_window "$ARG"
        ;;
    search)
        ARG="$(get_surfraw_url list_elvi)"
        [ -n "$ARG" ] && open_in_default_browser_or_current_window "$ARG"
        ;;
    both)
        ARG="$(get_surfraw_url list_both)"
        [ -n "$ARG" ] && open_in_default_browser_or_current_window "$ARG"
        ;;
    *)
        echo "usage: $0 bookmark|search|both"
        ;;
esac
