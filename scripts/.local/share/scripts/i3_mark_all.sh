#!/bin/bash

set -euo pipefail
shopt -s lastpipe
exec > /dev/null

# characters that will be used as marks
# todo add those characters to i3 config
VALID_CHARS="asdfghjklqwertuioyuzxcvbnm1234567890;',./=-"

i3-msg -t get_workspaces | jq '.[] | select(.visible) | .name' \
    | readarray -t visible_workspaces

joined_with_or=$(printf '.name == %s or ' "${visible_workspaces[@]}")
# remove trailing "or"
joined_with_or=${joined_with_or%or*}
visible_selection="select($joined_with_or)"

jq_find_workspaces='.nodes[] | select(.type == "output") | .nodes[] '\
'| .nodes[] | select(.type == "workspace" and .name != "__i3_scratch")'\
"| $visible_selection"

unmarked_windows=$(i3-msg -t get_tree | jq -c "$jq_find_workspaces "\
'| recurse(.nodes[], .floating_nodes[]) | .nodes[], .floating_nodes[]'\
'| select(.window != null and ((has("marks") | not) or .marks == []))')

window_ids=()
window_titles=()
window_classes=()

# using only jq (slow but maybe more reliable)
jq '.window' <<< "$unmarked_windows" | readarray -t window_ids
jq -r '.window_properties.title' <<< "$unmarked_windows" \
    | readarray -t window_titles
jq -r '.window_properties.class' <<< "$unmarked_windows" \
    | readarray -t window_classes

# the following is a little bit faster but you get the js notation for strings
# (e.g. '"' is escaped to '\"')
# (note that the following line depends on the '-c' flag being used when
# unmarked_windows is created)
#readarray -t window_ids \
#    < <(grep -oP '(?<="window":)[^,]+' <<< "$unmarked_windows" || echo -n)
#properties=$(jq -c '.window_properties' <<< "$unmarked_windows")
#readarray -t window_titles \
#    < <(grep -oP '(?<="title":")([^"\\]+|\\.)+' <<< "$properties" || echo -n)
#readarray -t window_classes \
#    < <(grep -oP '(?<="class":")([^"\\]+|\\.)+' <<< "$properties" || echo -n)

existing_marks=()
if [[ ${#window_ids[@]} -ge 1 ]]; then
    i3-msg -t get_marks | jq -r '.[]' | readarray -t existing_marks
fi

# stolen from: https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value/8574392#8574392
function contains_element {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

for i in "${!window_ids[@]}"; do
    # try first char in title and class of window
    # (note that cut -c1 doesn't seem to be able with unicode, but grep can...)
    title_char=$(tr '[:upper:]' '[:lower:]' <<< "${window_titles[$i]}" \
        | grep -m 1 -o '.' | head -1 || echo)
    class_char=$(tr '[:upper:]' '[:lower:]' <<< "${window_classes[$i]}" \
        | grep -m 1 -o '.' | head -1 || echo)
    char=''
    if [[ -z "${VALID_CHARS##*$class_char*}" && -n "$class_char" ]] \
        && ! contains_element "$class_char" "${existing_marks[@]}"; then
        char=$class_char
    elif [[ -z "${VALID_CHARS##*$title_char*}" && -n "$title_char" ]] \
        && ! contains_element "$title_char" "${existing_marks[@]}"; then
        char=$title_char
    else
        for (( j=0; j < ${#VALID_CHARS}; j++ )); do
            c=${VALID_CHARS:$j:1}
            if ! contains_element "$c" "${existing_marks[@]}"; then
                char=$c
                break
            fi
        done
    fi
    if [[ -n "$char" ]]; then
        i3-msg "[id=${window_ids[$i]}] mark \"$char\""
        existing_marks+=("$char")
    fi
done
