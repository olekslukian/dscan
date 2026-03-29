use anyhow::Result;
use opencv::{
    core::{self, AlgorithmHint},
    imgcodecs, imgproc,
    prelude::*,
};

pub fn make_grayscale(image_bytes: Vec<u8>) -> Result<Vec<u8>> {
    let src = imgcodecs::imdecode(
        &core::Vector::from_slice(&image_bytes),
        imgcodecs::IMREAD_COLOR,
    )?;

    let mut gray = core::Mat::default();

    imgproc::cvt_color(
        &src,
        &mut gray,
        imgproc::COLOR_BGR2GRAY,
        0,
        AlgorithmHint::ALGO_HINT_DEFAULT,
    )?;

    let mut result_bytes = core::Vector::<u8>::new();
    imgcodecs::imencode(".jpg", &gray, &mut result_bytes, &core::Vector::new())?;

    Ok(result_bytes.to_vec())
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
