#!/bin/sh
printf '\033c\033]0;%s\a' Robocesta
base_path="$(dirname "$(realpath "$0")")"
"$base_path/purkiada.x86_64" "$@"
