#!/bin/bash
set -e

trap 'echo -e "\n\nInterrupted!"; exit 130' INT

TARBALL_NAME="erlang-28.1-arm64.tar.gz"
TARBALL_URL="https://github.com/yoshi-monster/static_erlang/releases/download/otp-28.1/$TARBALL_NAME"
EXTRACT_DIR="$PWD/otp"

if [ ! -f "$TARBALL_NAME" ]; then
  echo "Downloading Erlang tarball..."
  curl -fLO "$TARBALL_URL"
fi

if [ ! -d "$EXTRACT_DIR" ]; then
  echo "Extracting tarball to $EXTRACT_DIR..."
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "$TARBALL_NAME" -C "$EXTRACT_DIR"
fi

IMAGES=(
    "debian:bookworm"
    "fedora:latest"
    "archlinux:latest"
    "alpine:latest"
    "ubuntu:22.04"
)

for image in "${IMAGES[@]}"; do
    echo ""
    echo "Testing on $image..."
    echo "---"
    docker run --rm -v "$EXTRACT_DIR/erlang:/tmp/otp" "$image" /tmp/otp/bin/erl -eval 'io:format("~s: Erlang/OTP ~s~n", ["'"$image"'", erlang:system_info(otp_release)]), halt().' -noshell
    echo "✓ $image: SUCCESS"
done

rm -rf "$TARBALL_NAME"
rm -rf "$EXTRACT_DIR"
