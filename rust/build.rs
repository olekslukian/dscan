use std::env;
use std::path::PathBuf;

fn main() {
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let target = env::var("TARGET").unwrap();
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    let third_party_dir = PathBuf::from(manifest_dir).join("../third_party/opencv");

    if target_os == "macos" {
        println!("cargo:rustc-link-search=/opt/homebrew/opt/opencv/lib");
        println!("cargo:rustc-link-lib=opencv_core");
        println!("cargo:rustc-link-lib=opencv_imgproc");
        println!("cargo:rustc-link-lib=opencv_imgcodecs");
        println!("cargo:rustc-link-lib=opencv_videoio");
    } else if target_os == "ios" {
        let xcframework_dir = third_party_dir.join("ios/opencv2.framework");

        let slice = if target.ends_with("-ios-sim") || target.starts_with("x86_64-apple-ios") {
            "ios-arm64_x86_64-simulator"
        } else {
            "ios-arm64"
        };

        let framework_path = xcframework_dir.join(slice);

        println!(
            "cargo:rustc-link-search=framework={}",
            framework_path.display()
        );
        println!("cargo:rustc-link-lib=framework=opencv2");
        println!("cargo:rustc-link-lib=c++");
    } else if target_os == "android" {
        let jni_arch = match target_arch.as_str() {
            "aarch64" => "arm64-v8a",
            "arm" => "armeabi-v7a",
            "x86_64" => "x86_64",
            "x86" => "x86",
            _ => panic!("Unsupported Android architecture: {}", target_arch),
        };

        let android_libs = third_party_dir.join(format!(
            "android/OpenCV-android-sdk/sdk/native/libs/{}",
            jni_arch
        ));

        println!("cargo:rustc-link-search={}", android_libs.display());

        println!("cargo:rustc-link-lib=opencv_java4");
    }
}
