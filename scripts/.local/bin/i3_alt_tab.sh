#!/bin/bash

# If there is only one floating window, this script behaves like
# "focused mode_toggle". Otherwise it switches focus between the floating windows
# (like Alt+Tab does on Windows).

workspace_with_focused_window_filter=$(cat <<EOF
    .nodes[].nodes[].nodes[]
    | select(.type == "workspace")
    | select(recurse(.nodes[],.floating_nodes[])
    | [.nodes[].focused] | any)
EOF
)
workspace=$(i3-msg -t get_tree | jq "$workspace_with_focused_window_filter")
is_focused_window_tiling_query='[recurse(.nodes[]) | .nodes[].focused] | any'
focused_window_tiling=$(jq "$is_focused_window_tiling_query" <<< "$workspace")
count_floating_nodes=$(cat <<EOF
[
    .floating_nodes[] | recurse(.nodes[]) |
    select(has("window") and .window != null)
] | length
EOF
)
number_of_floating=$(jq "$count_floating_nodes" <<< "$workspace")

if [ "$focused_window_tiling" == 'true' ]; then
    if [ "$number_of_floating" -ge 1 ]; then
        i3-msg 'focus floating'
    fi
# maybe focus the "next" window in the "else" case but that's not so easy in i3
else
    if [ "$number_of_floating" -gt 1 ]; then
        i3-msg 'focus right'
    else
        i3-msg 'focus tiling'
    fi
fi
