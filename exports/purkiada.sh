#!/bin/sh
printf '\033c\033]0;%s\a' purkiada
base_path="$(dirname "$(realpath "$0")")"
"$base_path/purkiada.x86_64" "$@"
