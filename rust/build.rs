use std::env;
use std::path::PathBuf;

fn main() {
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    let third_party_dir = PathBuf::from(manifest_dir).join("../third_party/opencv");

    if target_os == "macos" {
        println!("cargo:rustc-link-search=/opt/homebrew/opt/opencv/lib");
        println!("cargo:rustc-link-lib=opencv_core");
        println!("cargo:rustc-link-lib=opencv_imgproc");
        println!("cargo:rustc-link-lib=opencv_imgcodecs");
        println!("cargo:rustc-link-lib=opencv_videoio");
    } else if target_os == "ios" {
        let framework_search_path = third_party_dir.join("ios");

        println!(
            "cargo:rustc-link-search=framework={}",
            framework_search_path.display()
        );
        println!("cargo:rustc-link-lib=framework=opencv2");
        println!("cargo:rustc-link-lib=c++");

        println!("cargo:rustc-link-lib=framework=AVFoundation");
        println!("cargo:rustc-link-lib=framework=CoreMedia");
        println!("cargo:rustc-link-lib=framework=CoreVideo");
        println!("cargo:rustc-link-lib=framework=CoreGraphics");
        println!("cargo:rustc-link-lib=framework=Accelerate");
        println!("cargo:rustc-link-lib=framework=OpenGLES");
        println!("cargo:rustc-link-lib=framework=QuartzCore");
        println!("cargo:rustc-link-lib=framework=UIKit");
        println!("cargo:rustc-link-lib=framework=Foundation");
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
