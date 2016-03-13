#!/bin/sh

i3-msg workspace "$(echo 'workspace' | dmenu)"
