#!/bin/bash

set -u +e

SCRIPT_LOCATION="$HOME/.local/share/scripts/manage_surfraw_bookmarks.py"
OPENSCRIPT="$HOME/.local/share/scripts/openbrowser.sh"
MAX_URL_WIDTH=32
MAX_TAG_WIDTH=64
MAX_TITLE_WIDTH=128
ADD_CMD="alt+a"
ADD_CLIP_CMD="alt+c"
REMOVE_CMD="alt+r"
EDIT_TAG_CMD="alt+t"
EDIT_URL_CMD="alt+u"
EDIT_NAME_CMD="alt+n"
EDIT_TITLE_CMD="alt+w"
FILTER_BY_TAGS_CMD="alt+s"
ROFI_PARAMS="-matching normal -i -kb-custom-1 $ADD_CMD -kb-custom-2 $ADD_CLIP_CMD -kb-custom-3 $REMOVE_CMD -kb-custom-4 $EDIT_URL_CMD -kb-custom-5 $EDIT_TAG_CMD -kb-custom-6 $EDIT_NAME_CMD -kb-custom-7 $EDIT_TITLE_CMD -kb-custom-8 $FILTER_BY_TAGS_CMD"
HL="<b>"
END_HL="</b>"
ROFI_MESG="use $HL$ADD_CMD$END_HL to add a bookmark ($HL$ADD_CLIP_CMD$END_HL \
to add from clipboard)
use $HL$EDIT_URL_CMD$END_HL, $HL$EDIT_TAG_CMD$END_HL, $HL$EDIT_NAME_CMD$END_HL \
or $HL$EDIT_TITLE_CMD$END_HL to edit the url, tags, name or title of a bookmark
use $HL$REMOVE_CMD$END_HL to remove bookmark or $HL$FILTER_BY_TAGS_CMD$END_HL to search by tags"

print_pretty() {
    $SCRIPT_LOCATION  --max-url "$MAX_URL_WIDTH" --max-tags "$MAX_TAG_WIDTH" \
        --max-title "$MAX_TITLE_WIDTH" --print $'%n\t%u\t%t\t%T' \
        | column -s $'\t' -t
}

print_pretty_tags() {
    $SCRIPT_LOCATION  --max-url "$MAX_URL_WIDTH" --max-tags "$MAX_TAG_WIDTH" \
        --max-title "$MAX_TITLE_WIDTH" --filter-by-tags $'%n\t%u\t%t\t%T' \
        ${1?no tags specified} \
        | column -s $'\t' -t
}

prompt_bookmark() {
    PRM='bkm'
    if [ -n "${ROW-}" ]; then
        PRINTED="$(print_pretty)"
        NUM_LINES="$(wc -l <<< "$PRINTED")"
        if [ "$ROW" -eq $NUM_LINES ]; then
            ROW="$((ROW-1))"
        fi
        ARG="$(print_pretty | rofi -dmenu -selected-row "$ROW" $ROFI_PARAMS -p "$PRM" -mesg "$ROFI_MESG")"
    else
        ARG="$(print_pretty | rofi -dmenu $ROFI_PARAMS -p "$PRM" -mesg "$ROFI_MESG")"
    fi
    VAR=$?
    if ! grep -qE '^.+[[:space:]]+' <<< "$ARG"; then
        echo "$ARG"
    else
        cut -f 1 -d ' ' <<< "$ARG"
    fi
    return $VAR
}

get_bookmark_url() {
    if [ -n "$1" ]; then
        ECHO="$($SCRIPT_LOCATION --long-urls --find "$1" '%u' 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            echo "$ECHO"
        fi
    fi
}

get_bookmark_name() {
    if [ -n "$1" ]; then
        ECHO="$($SCRIPT_LOCATION --find "$1" '%n' 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            echo "$ECHO"
        fi
    fi
}

get_bookmark_title() {
    if [ -n "$1" ]; then
        ECHO="$($SCRIPT_LOCATION --find "$1" '%T' 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            echo "$ECHO"
        fi
    fi
}

get_bookmark_tags() {
    if [ -n "$1" ]; then
        ECHO="$($SCRIPT_LOCATION --find "$1" '%t' 2>&1)"
        if [ $? -ne 0 ]; then
            rofi -markup -e "<span color='red'>$ECHO</span>"
            return 1
        else
            echo "$ECHO"
        fi
    fi
}

list_tags() {
    ECHO="$($SCRIPT_LOCATION --list-tags 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    else
        echo "$ECHO"
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
        URL="$(rofi -dmenu -filter "$CLIP" -p 'add bookmark (url)' < /dev/null)"
    else
        URL="$(rofi -dmenu -p 'add bookmark (url)' < /dev/null)"
    fi
    if [ -z "$URL" -o $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>abort adding url $URL
        exit code of rofi: $?</span>"
        return 1
    fi
    N_SUG="$(sed -r 's|^https?://(ww.+\.)?(.+)\..*|\2|' <<< "$URL")"
    NAME="$(rofi -dmenu -filter "$N_SUG" -p 'add bookmark (name)' < /dev/null)"
    if [ -z "$NAME" -o $? -ne 0 ] \
        || $SCRIPT_LOCATION --print '%n' | grep -q "$NAME"; then
        rofi -markup -e "<span color='red'>abort adding url $URL with name $NAME
        (no name given or name exists)
        exit code of rofi: $?</span>"
        return 1
    fi
    TAG="$(list_tags | rofi -dmenu -multi-select -p 'add tags')"
    ECHO=""
    if [ -n "$TAG" ]; then
        TAGS="$(join_by ${TAG[*]})"
        ECHO="$ECHO""$($SCRIPT_LOCATION --add "$NAME" "$URL" "$TAGS" 2>&1)"
    else
        ECHO="$ECHO""$($SCRIPT_LOCATION --add "$NAME" "$URL" 2>&1)"
    fi
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    else
        rofi -e "$ECHO"
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

filter_by_tags() {
    TAG="$(list_tags | rofi -dmenu -multi-select -p 'filter by tags')"
    ECHO=""
    if [ -n "$TAG" ]; then
        TAGS="$(join_by ${TAG[*]})"
        ARG="$(print_pretty_tags "$TAGS" | rofi -dmenu $ROFI_PARAMS -p "bkm [$TAGS]" -mesg "$ROFI_MESG")"
    else
        rofi -markup -e "no tags selected; aborting"
        exit 1
    fi
    VAR=$?
    if ! grep -qE '^.+[[:space:]]+' <<< "$ARG"; then
        echo "$ARG"
    else
        cut -f 1 -d ' ' <<< "$ARG"
    fi
    return $VAR
}

edit_url() {
    URL="$(get_bookmark_url "$1")"
    [ -z "$URL" ] && return 1
    NEW_URL="$(rofi -dmenu -filter "$URL" -p 'edit url' < /dev/null)"
    if [ -z "$NEW_URL" -o $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>abort changing url $URL
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO="$($SCRIPT_LOCATION --update-url "$1" "$NEW_URL" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

edit_tags() {
    TAGS="$(get_bookmark_tags "$1")"
    NEW_TAGS="$(rofi -dmenu -filter "$TAGS" -p 'edit tags' < /dev/null)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>abort changing tags $TAGS
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO="$($SCRIPT_LOCATION --update-tags "$1" "$NEW_TAGS" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    else
        rofi -e "$ECHO"
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

edit_name() {
    NAME="$(get_bookmark_name "$1")"
    [ -z "$NAME" ] && return 1
    NEW_NAME="$(rofi -dmenu -filter "$NAME" -p 'edit name' < /dev/null)"
    if [ -z "$NEW_NAME" -o $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>abort changing name $NAME
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO="$($SCRIPT_LOCATION --update-name "$1" "$NEW_NAME" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

edit_title() {
    TITLE="$(get_bookmark_title "$1")"
    NEW_TITLE="$(rofi -dmenu -filter "$TITLE" -p 'edit title' < /dev/null)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>abort changing name $TITLE
        exit code of rofi: $?</span>"
        return 1
    fi
    ECHO=""
    FETCH=0
    if [ -n "$NEW_TITLE" ]; then
        ECHO="$($SCRIPT_LOCATION --update-title "$1" "$NEW_TITLE" 2>&1)"
    else
        FETCH=1
        ECHO="$($SCRIPT_LOCATION --update-title "$1" 2>&1)"
    fi
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    elif [ "$FETCH" -eq 1 ]; then
        rofi -e "$ECHO"
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

remove_bookmark() {
    ECHO="$($SCRIPT_LOCATION --remove "$1" 2>&1)"
    if [ $? -ne 0 ]; then
        rofi -markup -e "<span color='red'>$ECHO</span>"
        return 1
    fi
    ROW="$(grep 'index:' <<< "$ECHO" | cut -f 2 -d ' ')"
    export ROW
}

ARG="$(prompt_bookmark)"
RET=$?
while true; do
if [ "$RET" -ne 0 ]; then
    case "$RET" in
        10)
            add_bookmark && $0
            break
            ;;
        11)
            CLIP="$(xsel -bo)"
            if [ -n "$CLIP" ]; then
                add_bookmark "$CLIP" && $0
            else
                add_bookmark && $0
            fi
            break
            ;;
        12)
            [ -n "$ARG" ] && remove_bookmark "$ARG" && $0
            break
            ;;
        13)
            [ -n "$ARG" ] && edit_url "$ARG" && $0
            break
            ;;
        14)
            [ -n "$ARG" ] && edit_tags "$ARG" && $0
            break
            ;;
        15)
            [ -n "$ARG" ] && edit_name "$ARG" && $0
            break
            ;;
        16)
            [ -n "$ARG" ] && edit_title "$ARG" && $0
            break
            ;;
        17)
            ARG="$(filter_by_tags)"
            RET=$?
            ;;
        *)
            exit $RET
            ;;
    esac

else
    URL="$(get_bookmark_url "$ARG")"
    [ -n "$URL" ] && $OPENSCRIPT "$URL"
    break
fi
done
