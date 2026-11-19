#!/bin/sh
printf '\033c\033]0;%s\a' Hot climbers
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Hot climbers.arm64" "$@"
