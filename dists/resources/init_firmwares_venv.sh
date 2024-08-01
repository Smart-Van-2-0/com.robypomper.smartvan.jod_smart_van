#!/bin/bash

firmwares_pats="$(pwd)/deps"
commands=(
  "python -m venv venv"
  "source venv/bin/activate"
  "pip install -r requirements.txt"
  "pip list"
  "deactivate"
)

# Iterate over all directories
for dir in "$firmwares_pats"/*/; do
  if [ -d "$dir" ]; then
    echo "Initializing firmware nella directory: $(basename $dir)"
    cd "$dir" || exit

    # Execute all commands
    for cmd in "${commands[@]}"; do
      eval "$cmd"
    done

    # Return to the original directory
    cd "$firmwares_pats" || exit
  fi
done
