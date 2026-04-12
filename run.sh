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
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    OPENCV_SDK="$SCRIPT_DIR/third_party/opencv/android/OpenCV-android-sdk/sdk/native"
    export OPENCV_LINK_LIBS=opencv_java4
    export OPENCV_LINK_PATHS="$OPENCV_SDK/libs/arm64-v8a"
    export OPENCV_INCLUDE_PATHS="$OPENCV_SDK/jni/include"
elif [ "$PLATFORM_FLAG" == "--macos" ]; then
    echo "-- macOS target detected: Relying on Homebrew OpenCV. Skipping downloads. --"
else
    echo "-- No specific platform flag (--ios, --android, --macos) provided. Checking all mobile targets. --"
    ./scripts/setup_opencv.sh --all
fi

cd example && flutter run "${FLUTTER_ARGS[@]}"
