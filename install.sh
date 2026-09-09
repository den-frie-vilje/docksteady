#!/bin/sh
# docksteady installer: copies the command into ~/.local/bin and checks
# the two dependencies. Setup itself (panel detection, LaunchAgent, wake
# hook) happens in `docksteady init`, which explains what it does.
set -eu

BIN_DIR="$HOME/.local/bin"
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname)" != "Darwin" ]; then
    echo "docksteady is macOS-only"; exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required for the dependencies: https://brew.sh"; exit 1
fi

if ! command -v displayplacer >/dev/null 2>&1; then
    printf "displayplacer is missing. Install it now with brew? [y/N] "
    read -r answer
    if [ "$answer" = "y" ]; then
        brew install jakehilborn/jakehilborn/displayplacer
    else
        echo "docksteady needs displayplacer; install it before running init:"
        echo "  brew install jakehilborn/jakehilborn/displayplacer"
    fi
fi

if ! brew list sleepwatcher >/dev/null 2>&1; then
    printf "sleepwatcher (wake trigger) is missing. Install and start it with brew? [y/N] "
    read -r answer
    if [ "$answer" = "y" ]; then
        brew install sleepwatcher
        brew services start sleepwatcher
    else
        echo "Without sleepwatcher, enforcement on wake waits for the poll instead:"
        echo "  brew install sleepwatcher && brew services start sleepwatcher"
    fi
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$HERE/docksteady" "$BIN_DIR/docksteady"
echo "installed $BIN_DIR/docksteady"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "note: $BIN_DIR is not in your PATH; add to your shell profile:"
       echo "  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo
echo "Next: dock the machine so both panels are attached, then run:"
echo "  docksteady init"
