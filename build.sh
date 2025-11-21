#!/bin/bash

# GitDeck build script for Sailfish OS

set -e

ARCH="${1:-armv7hl}"
TARGET="SailfishOS-4.5.0.19-$ARCH"

echo "Building GitDeck for $TARGET..."

# Check if OAuth credentials are set
if [ -z "$GITDECK_CLIENT_ID" ] || [ -z "$GITDECK_CLIENT_SECRET" ]; then
    echo "Warning: OAuth credentials not set"
    echo "Set GITDECK_CLIENT_ID and GITDECK_CLIENT_SECRET environment variables"
    echo "Or source .env file if it exists"
    if [ -f .env ]; then
        echo "Sourcing .env file..."
        set -a
        source .env
        set +a
    fi
fi

# Build with mb2
mb2 -t "$TARGET" build

echo "Build completed!"
echo "RPMs are in RPMS/"
ls -lh RPMS/
