#!/bin/bash

set -e

PLATFORM_FLAG=""
FLUTTER_ARGS=()

# Parse all arguments passed to the script
while [[ $# -gt 0 ]]; do
  case $1 in
    --ios|--android|--macos)
      PLATFORM_FLAG="$1"
      shift
      ;;
    *)
      FLUTTER_ARGS+=("$1")
      shift
      ;;
  esac
done

if [ "$PLATFORM_FLAG" == "--ios" ]; then
    ./scripts/setup_opencv.sh --ios
elif [ "$PLATFORM_FLAG" == "--android" ]; then
    ./scripts/setup_opencv.sh --android
elif [ "$PLATFORM_FLAG" == "--macos" ]; then
    echo "-- macOS target detected: Relying on Homebrew OpenCV. Skipping downloads. --"
else
    echo "-- No specific platform flag (--ios, --android, --macos) provided. Checking all mobile targets. --"
    ./scripts/setup_opencv.sh --all
fi

cd example && flutter run "${FLUTTER_ARGS[@]}"
