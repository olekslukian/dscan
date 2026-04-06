# dscan

A high-performance Flutter package for document scanning. This project leverages `flutter_rust_bridge` to execute native Rust code and utilizes OpenCV for core image processing.

## Prerequisites

### macOS
If you are developing or running the application for the macOS desktop target, OpenCV must be installed locally via Homebrew:

```bash
brew install opencv
```

### iOS and Android
No manual installation is required. The provided build scripts will automatically download and link the official pre-compiled OpenCV SDKs for mobile platforms.

### How to Run
To ensure all C++ dependencies are properly downloaded and linked before compilation, always use the included run.sh wrapper script instead of the standard flutter run command.

First, ensure the scripts have execution permissions (you only need to do this once):

```bash
chmod +x run.sh scripts/setup_opencv.sh
```

Then, execute the wrapper script and specify your target device:

```bash
# To run on macOS (relies on Homebrew)
./run.sh -d macos

# To run on iOS (automatically downloads opencv2.xcframework)
./run.sh -d ios

# To run on Android (automatically downloads OpenCV-android-sdk)
./run.sh -d android
```

If you need to pass additional Flutter arguments, simply append them to the script.
