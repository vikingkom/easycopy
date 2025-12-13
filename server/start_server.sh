#!/bin/bash
# EasyCopy Server Startup Script

cd "$(dirname "$0")"

# Deactivate any active virtualenv
[ -n "$VIRTUAL_ENV" ] && (deactivate 2>/dev/null || unset VIRTUAL_ENV)

# Use pipenv if available
if command -v pipenv &> /dev/null; then
    echo "Starting EasyCopy Server on http://localhost:8000"
    export PIPENV_IGNORE_VIRTUALENVS=1
    cd .. && exec pipenv run python server/main.py
fi

# Fallback to system Python with fastapi
for py in python3 python; do
    if $py -c "import fastapi" 2>/dev/null; then
        echo "Starting EasyCopy Server on http://localhost:8000"
        exec $py main.py
    fi
done

echo "Error: FastAPI not found. Install dependencies: pip install -r requirements.txt"
exit 1
