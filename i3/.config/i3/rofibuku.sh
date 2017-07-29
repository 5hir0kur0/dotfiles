#!/bin/bash

set -u +e

# FIXME: in the version of buku I wrote this script with (2.9), buku had
# a bug that required me to pipe something into it or it wouldn't work when
# started by i3, hence all the useless echo | buku pipes
# (starting the script from a shell worked just fine)
# please remove the echos once this behavior has changed

DATA_HOME="${XDG_DATA_HOME-$HOME/.local/share}"
USE_SQLITE=1 # sqlite is much faster than directly calling buku
MAX_URL_WIDTH=42
MAX_TAG_WIDTH=42
MAX_TITLE_WIDTH=80
ELLIPSIS="…"
ADD_CMD="alt+a"
ADD_CLIP_CMD="alt+c"
REMOVE_CMD="alt+r"
EDIT_TAG_CMD="alt+t"
EDIT_URL_CMD="alt+u"
ROFI_PARAMS="-matching normal -i -kb-custom-1 $ADD_CMD -kb-custom-2 $ADD_CLIP_CMD -kb-custom-3 $REMOVE_CMD -kb-custom-4 $EDIT_URL_CMD -kb-custom-5 $EDIT_TAG_CMD"
COL="<span color='darkred'>"
E_COL="</span>"
ROFI_MESG="use $COL$ADD_CMD$E_COL to add a bookmark
use $COL$ADD_CLIP_CMD$E_COL to add a bookmark from clipboard
use $COL$REMOVE_CMD$E_COL to remove bookmark
use $COL$EDIT_URL_CMD$E_COL to edit the url of a bookmark
use $COL$EDIT_TAG_CMD$E_COL to edit the tags of a bookmark"
OPENSCRIPT="$HOME/.config/i3/openbrowser.sh"
# not sure if I could have done it in an uglier way...
AWK="BEGIN { OFS=\"\"; } { printf \"%s\t\", \$1; "
AWK="$AWK""if(length(\$2) > $MAX_URL_WIDTH) printf \"%s%s\", substr("
AWK="$AWK""\$2, 1, $MAX_URL_WIDTH), \"$ELLIPSIS\"; else printf \"%s\",\$2"
AWK="$AWK""; printf \"\t\"; "
AWK="$AWK""if(length(\$3) > $MAX_TAG_WIDTH) printf \"%s%s\", substr("
AWK="$AWK""\$3, 2, $MAX_TAG_WIDTH-2), \"$ELLIPSIS\";"
AWK="$AWK""else printf \"%s\", substr(\$3, 2, length(\$3)-2)"
AWK="$AWK""; printf \"\t\""
AWK="$AWK""; \$1 = \"\"; \$2 = \"\"; \$3 = \"\";"
AWK="$AWK""tmp = \"\";"
AWK="$AWK""for (i=4; i<=NF; i++) if (i > 4) tmp = (tmp)\"|\"(\$i);"
AWK="$AWK""else tmp = \$i;"
AWK="$AWK""if(length(tmp) > $MAX_TITLE_WIDTH) printf \"%s%s\", substr("
AWK="$AWK""tmp, 1, $MAX_TITLE_WIDTH), \"$ELLIPSIS\"; else printf \"%s\",tmp"
AWK="$AWK""; printf \"\n\""
AWK="$AWK""}"

buku_list_sqlite3() {
    FILE="file:$DATA_HOME/buku/bookmarks.db?mode=ro"
    QUERY='select id, url, tags, metadata from bookmarks order by id asc;'
    sqlite3 -list "$FILE" "$QUERY"
}

buku_list_urls_and_tags() {
    echo | buku --print --format 2 | sed 's/\s\+/|/' | sed 's/\s\+/|,/' \
        | sed 's/,\([^,]\+\)$/|\1,/'
}

buku_list_titles() {
    echo | buku --print --format 3 | sed 's/\s\+/|/'
}

buku_list_native() {
    join -j 1 -t '|'  <(buku_list_urls_and_tags) <(buku_list_titles)
}

print_pretty() {
    if [ "$USE_SQLITE" -eq 1 ]; then
        buku_list_sqlite3 | awk -F '|' "$AWK" | column -s $'\t' -t
    else
        buku_list_native | awk -F '|' "$AWK" | column -s $'\t' -t
    fi

}

prompt_bookmark() {
    PRM='bkm:'
    if [ -n "${ROW-}" ]; then
        ARG="$(print_pretty | rofi -dmenu -selected-row "$ROW" $ROFI_PARAMS -p "$PRM" -mesg "$ROFI_MESG")"
    else
        ARG="$(print_pretty | rofi -dmenu $ROFI_PARAMS -p "$PRM" -mesg "$ROFI_MESG")"
    fi
    VAR=$?
    if ! grep -qE '^[[:digit:]]+[[:space:]]+' <<< "$ARG"; then
        echo "$ARG"
    else
        cut -f 1 -d ' ' <<< "$ARG"
    fi
    return $VAR
}

get_buku_url() {
    if [ -n "$1" ]; then
        if ! grep -qE '^[[:digit:]]+$' <<< "$1"; then
            echo "$1"
            return 0
        fi
        ECHO="$(echo | buku --print "$1" --format 1 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            cut -f 2- -d $'\t' <<< "$ECHO"
        fi
    fi
}

get_buku_tags() {
    if [ -n "$1" ]; then
        ECHO="$(echo | buku --print "$1" --format 2 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            rev <<< "$ECHO" | cut -f 1 -d $'\t' | rev
        fi
    fi
}

list_tags() {
    TAGS="$(echo | buku --stag --nc --np)"
    NUM="$(wc -l <<< "$TAGS")"
    if [ "$NUM" -eq 1 ]; then
        echo
    else
        tr -s ' ' <<< "$TAGS" | cut -f 3 -d ' ' | tac | tail -n +2 | tac
    fi
}

join_by() {
    local IFS=","
    echo "$*"
}

add_bookmark() {
    CLIP="${1-}"
    URL=""
    if [ -n "$CLIP" ]; then
        URL="$(rofi -dmenu -filter "$CLIP" -p 'add bookmark (url):' < /dev/null)"
    else
        URL="$(rofi -dmenu -p 'add bookmark (url):' < /dev/null)"
    fi
    if [ -z "$URL" -o $? -ne 0 ]; then 
        rofi -markup -e "<span color='red'>abort adding url $URL
        exit code of rofi: $?</span>"
        return 1
    fi
    TAG="$(list_tags | rofi -dmenu -multi-select -p 'add tags:')"
    ECHO=""
    if [ -n "$TAG" ]; then
        TAGS="$(join_by ${TAG[*]})"
        ECHO="$ECHO""$(echo | buku --nc --add "$URL" --tag "$TAGS" 2>&1)"
    else
        ECHO="$ECHO""$(echo | buku --nc --add "$URL" 2>&1)"
    fi
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    else
        rofi -e "$ECHO"
    fi
    ROW="$(head -1 <<< "$ECHO" | cut -f 1 -d '.')"
    export ROW="$((ROW-1))"
}

edit_url() {
    URL="$(get_buku_url "$1")"
    [ -z "$URL" ] && return 1
    NEW_URL="$(rofi -dmenu -filter "$URL" -p 'edit url:' < /dev/null)"
    if [ -z "$NEW_URL" -o $? -ne 0 ]; then 
        rofi -markup -e "<span color='red'>abort changing url $URL
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO="$(echo | buku --nc --update "$1" --url "$NEW_URL" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    fi
    ARG="$1"
    export ROW="$((ARG-1))"
}

edit_tags() {
    TAGS="$(get_buku_tags "$1")"
    NEW_TAGS="$(rofi -dmenu -filter "$TAGS" -p 'edit tags:' < /dev/null)"
    if [ $? -ne 0 ]; then 
        rofi -markup -e "<span color='red'>abort changing tags $TAGS
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO="$(echo | buku --nc --update "$1" --tag "$NEW_TAGS" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    else
        rofi -e "$ECHO"
    fi
    ARG="$1"
    export ROW="$((ARG-1))"
}

remove_bookmark() {
    ECHO="$(echo | buku --delete "$1" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    fi
    ARG="$1"
    export ROW="$((ARG-1))"
}

ARG="$(prompt_bookmark)"
RET=$?
if [ "$RET" -ne 0 ]; then
    case "$RET" in
        10)
            add_bookmark && $0
            ;;
        11)
            CLIP="$(xsel -b)"
            if [ -n "$CLIP" ]; then
                add_bookmark "$CLIP" && $0
            else
                add_bookmark && $0
            fi
            ;;
        12)
            [ -n "$ARG" ] && remove_bookmark "$ARG" && $0
            ;;
        13)
            [ -n "$ARG" ] && edit_url "$ARG" && $0
            ;;
        14)
            [ -n "$ARG" ] && edit_tags "$ARG" && $0
            ;;
        *)
            exit
            ;;
    esac

else
    URL="$(get_buku_url "$ARG")"
    [ -n "$URL" ] && $OPENSCRIPT "$URL"
fi
