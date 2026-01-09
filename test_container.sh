#!/bin/bash
# Test script to verify container detection functions
source setup/functions.sh

echo "Testing container detection..."

if is_lxc_container; then
    echo "✓ Detected: Running in LXC container"
else
    echo "✗ Detected: Not running in LXC container (expected in development)"
fi

if is_privileged_container; then
    echo "✓ Detected: Running in privileged container"
else
    echo "✗ Detected: Not running in privileged container (expected in development)"
fi

echo ""
echo "System information:"
echo "- Kernel: $(uname -r)"
echo "- OS: $(lsb_release -d 2>/dev/null | cut -f2)"
echo "- Architecture: $(uname -m)"