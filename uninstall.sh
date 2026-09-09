#!/bin/sh
# docksteady uninstaller: disarms the triggers and removes the command.
# Configuration and the log are left in place; delete them yourself if
# you want a clean slate (~/.config/docksteady, ~/Library/Logs/docksteady.log).
set -eu

LABEL="dk.denfrievilje.docksteady"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
WAKEUP="$HOME/.wakeup"

if command -v docksteady >/dev/null 2>&1; then
    docksteady disarm
else
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "LaunchAgent removed"
    if [ -f "$WAKEUP" ] && grep -q "docksteady wake hook" "$WAKEUP"; then
        sed -i '' '/# >>> docksteady wake hook >>>/,/# <<< docksteady wake hook <<</d' "$WAKEUP"
        echo "wake hook removed from $WAKEUP"
    fi
fi

if [ -f "$HOME/.local/bin/docksteady" ]; then
    rm -f "$HOME/.local/bin/docksteady"
    echo "removed $HOME/.local/bin/docksteady"
fi

if command -v docksteady >/dev/null 2>&1; then
    echo "a docksteady remains on PATH (probably Homebrew): brew uninstall docksteady"
fi

echo "done; config and log left in place"
