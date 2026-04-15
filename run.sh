#!/bin/bash

set -e

PLATFORM_FLAG=""
FLUTTER_ARGS=()

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

HAS_DEVICE_FLAG=false
for arg in "${FLUTTER_ARGS[@]}"; do
    if [[ "$arg" == "-d" || "$arg" == --device-id* ]]; then
        HAS_DEVICE_FLAG=true
        break
    fi
done

if [ "$PLATFORM_FLAG" == "--ios" ]; then
    ./scripts/setup_opencv.sh --ios
    if [ "$HAS_DEVICE_FLAG" == false ]; then
        DEVICE_ID=$(flutter devices 2>/dev/null | grep -i 'ios\|iphone\|ipad' | head -1 | sed 's/.*• \([^ ]*\) *•.*/\1/')
        if [ -n "$DEVICE_ID" ]; then
            FLUTTER_ARGS+=("-d" "$DEVICE_ID")
        fi
    fi
elif [ "$PLATFORM_FLAG" == "--android" ]; then
    ./scripts/setup_opencv.sh --android
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    OPENCV_SDK="$SCRIPT_DIR/third_party/opencv/android/OpenCV-android-sdk/sdk/native"
    export OPENCV_LINK_LIBS=opencv_java4
    export OPENCV_LINK_PATHS="$OPENCV_SDK/libs/arm64-v8a"
    export OPENCV_INCLUDE_PATHS="$OPENCV_SDK/jni/include"
    if [ "$HAS_DEVICE_FLAG" == false ]; then
        DEVICE_ID=$(flutter devices 2>/dev/null | grep -i 'android' | head -1 | sed 's/.*• \([^ ]*\) *•.*/\1/')
        if [ -n "$DEVICE_ID" ]; then
            FLUTTER_ARGS+=("-d" "$DEVICE_ID")
        else
            echo "Warning: No Android device found. Run 'flutter devices' to check."
        fi
    fi
elif [ "$PLATFORM_FLAG" == "--macos" ]; then
    echo "-- macOS target detected: Relying on Homebrew OpenCV. Skipping downloads. --"
    if [ "$HAS_DEVICE_FLAG" == false ]; then
        FLUTTER_ARGS+=("-d" "macos")
    fi
else
    echo "-- No specific platform flag (--ios, --android, --macos) provided. Checking all mobile targets. --"
    ./scripts/setup_opencv.sh --all
fi

cd example && flutter run "${FLUTTER_ARGS[@]}"
