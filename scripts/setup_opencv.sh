#!/bin/bash

set -e

OPENCV_VERSION="4.10.0"
THIRD_PARTY_DIR="third_party/opencv"

IOS_URL="https://github.com/opencv/opencv/releases/download/${OPENCV_VERSION}/opencv-${OPENCV_VERSION}-ios-framework.zip"
ANDROID_URL="https://github.com/opencv/opencv/releases/download/${OPENCV_VERSION}/opencv-${OPENCV_VERSION}-android-sdk.zip"

# Parse arguments
CHECK_IOS=false
CHECK_ANDROID=false

# If no arguments are passed, check mobile platforms by default
if [ "$#" -eq 0 ]; then
    CHECK_IOS=true
    CHECK_ANDROID=true
fi

# Loop through passed arguments
for arg in "$@"; do
    case $arg in
        --ios) CHECK_IOS=true ;;
        --android) CHECK_ANDROID=true ;;
        --all) CHECK_IOS=true; CHECK_ANDROID=true ;;
    esac
done

echo "=== Checking OpenCV Dependencies ==="

mkdir -p "$THIRD_PARTY_DIR/ios"
mkdir -p "$THIRD_PARTY_DIR/android"

# ---------------------------------------------------------
# iOS
# ---------------------------------------------------------
if [ "$CHECK_IOS" = true ]; then
    if [ -d "$THIRD_PARTY_DIR/ios/opencv2.xcframework" ]; then
        echo "-- iOS OpenCV framework found. --"
    else
        echo "-- iOS OpenCV framework missing. Downloading version $OPENCV_VERSION... -- "
        curl -L "$IOS_URL" -o "$THIRD_PARTY_DIR/ios_opencv.zip"
        echo "-- Extracting iOS framework... --"
        unzip -q "$THIRD_PARTY_DIR/ios_opencv.zip" -d "$THIRD_PARTY_DIR/ios"
        rm "$THIRD_PARTY_DIR/ios_opencv.zip"
        echo "-- iOS OpenCV framework installed successfully. --"
    fi
fi

# ---------------------------------------------------------
# Android
# ---------------------------------------------------------
if [ "$CHECK_ANDROID" = true ]; then
    if [ -d "$THIRD_PARTY_DIR/android/OpenCV-android-sdk" ]; then
        echo "-- Android OpenCV SDK found. --"
    else
        echo "-- Android OpenCV SDK missing. Downloading version $OPENCV_VERSION... --"
        curl -L "$ANDROID_URL" -o "$THIRD_PARTY_DIR/android_opencv.zip"
        echo "-- Extracting Android SDK... --"
        unzip -q "$THIRD_PARTY_DIR/android_opencv.zip" -d "$THIRD_PARTY_DIR/android"
        rm "$THIRD_PARTY_DIR/android_opencv.zip"
        echo "-- Android OpenCV SDK installed successfully. --"
    fi
fi

echo "=== Dependency check complete! ==="
