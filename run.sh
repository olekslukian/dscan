#!/bin/bash

if [[ "$@" == *"-d ios"* ]]; then
    ./scripts/setup_opencv.sh --ios
elif [[ "$@" == *"-d android"* ]]; then
    ./scripts/setup_opencv.sh --android
elif [[ "$@" == *"-d macos"* ]]; then
    echo "-- macOS target detected: Relying on Homebrew OpenCV. Skipping downloads. --"
else
    ./scripts/setup_opencv.sh --all
fi

flutter run "$@"
