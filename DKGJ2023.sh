#!/bin/sh
echo -ne '\033c\033]0;DKGJ2023\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/DKGJ2023.x86_64" "$@"
