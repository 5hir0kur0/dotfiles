#!/bin/bash

# requirements: surfraw, xdotool, xprop

# inspired by: https://github.com/gotbletu/shownotes/blob/master/rofi_websearch_bookmarks_surfraw.md

ELVI_DIRECTORIES=("/usr/lib/surfraw/" "$HOME/.config/surfraw/elvi/")
BOOKMARKS="$HOME/.config/surfraw/bookmarks"
OPENSCRIPT="$HOME/.local/share/scripts/openbrowser.sh"
DEFAULT_ELVI='google'

set -eu

list_elvi() {
    ARRAY=()
    for DIR in "${ELVI_DIRECTORIES[@]}"; do
        ARRAY+=( ${DIR}* )
    done
    printf "%s \n" "${ARRAY[@]##*/}" | sort -n
}

list_bookmarks() {
    sed '/^$/d' < "$BOOKMARKS" | sort -n
}

list_both() {
    (list_elvi; list_bookmarks | cut -f 1 -d ' ') | sort -n
}

MSG='(swapped tab and c-space)'
ROFI_ARGS=" -kb-row-select Tab -kb-row-tab Control+space -dmenu -i \
    -levenshtein-sort"

# call with list function as first argument
get_surfraw_url() {
    PRM='web:'
    # lack of double quotes intentional
    LIST="$($1)"
    ARG="$(rofi $ROFI_ARGS -p "$PRM" -mesg "$MSG" <<< "$LIST")"
    if [ -n "$ARG" ]; then
        FIRST_ELEM="$(sed 's/\s\+.*$//' <<< "$ARG")"
        if grep -q "^$FIRST_ELEM\s*\$" <<< "$LIST"; then
            SURFRAW_print=yes surfraw $ARG
        else # does not start with an elvi
            if grep -q '\.' <<< "$ARG"; then # it's probably an url
                echo "$ARG"
            else
                SURFRAW_print=yes surfraw "$DEFAULT_ELVI" $ARG
            fi
        fi
    else
        return 1
    fi
}

get_bookmark() {
    PRM='bkm:'
    ARG="$(list_bookmarks | rofi $ROFI_ARGS -p "$PRM" -mesg "$MSG")"
    [ -n "$ARG" ] && tr -s ' ' <<< "$ARG" | cut -f 2 -d ' '
}

case "${1:-}" in
    bookmark)
        ARG="$(get_bookmark)"
        [ -n "$ARG" ] && $OPENSCRIPT "$ARG"
        ;;
    search)
        ARG="$(get_surfraw_url list_elvi)"
        [ -n "$ARG" ] && $OPENSCRIPT "$ARG"
        ;;
    both)
        ARG="$(get_surfraw_url list_both)"
        [ -n "$ARG" ] && $OPENSCRIPT "$ARG"
        ;;
    nothing)
        ;;
    *)
        echo "usage: $0 bookmark|search|both"
        ;;
esac
