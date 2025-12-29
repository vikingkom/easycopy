#!/usr/bin/env bash

#set -e
source "$(dirname "$0")/.venv/bin/activate"
OUTPUT=$(python -u "$(dirname "$0")/upload.py")
CMD="display notification \"$OUTPUT\" with title \"Clip-context\""
osascript -e "$CMD"
echo $OUTPUT