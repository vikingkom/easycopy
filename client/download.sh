#!/usr/bin/env bash

#set -e
source "$(dirname "$0")/.venv/bin/activate"
OUTPUT=$(/Users/vladimir.komarevskiy/.pyenv/versions/3.11.3/bin/python -u "$(dirname "$0")/download.py")
CMD="display notification \"$OUTPUT\" with title \"Clip-context\""
osascript -e "$CMD"