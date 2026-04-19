use anyhow::Result;
use opencv::{core, imgcodecs, imgproc};

pub struct DocPoint {
    pub x: f32,
    pub y: f32,
}

pub fn detect_document_edges(image_bytes: Vec<u8>) -> Result<Vec<DocPoint>> {
    let src = imgcodecs::imdecode(
        &core::Vector::from_slice(&image_bytes),
        imgcodecs::IMREAD_COLOR,
    )?;

    let mut gray = core::Mat::default();
    imgproc::cvt_color_def(&src, &mut gray, imgproc::COLOR_BGR2GRAY)?;

    let ksize = core::Size::new(5, 5);
    let mut blurred = core::Mat::default();
    imgproc::gaussian_blur_def(&gray, &mut blurred, ksize, 0.0)?;

    let mut edges = core::Mat::default();
    imgproc::canny_def(&blurred, &mut edges, 75.0, 200.0)?;

    let mut result_bytes = core::Vector::<u8>::new();
    imgcodecs::imencode(".jpg", &edges, &mut result_bytes, &core::Vector::new())?;

    let mut contours = core::Vector::<core::Vector<core::Point>>::new();
    imgproc::find_contours_def(
        &edges,
        &mut contours,
        imgproc::RETR_LIST,
        imgproc::CHAIN_APPROX_SIMPLE,
    )?;

    let mut max_area = 0.0;
    let mut best_contour = core::Vector::<core::Point>::new();

    for i in 0..contours.len() {
        let contour = contours.get(i)?;
        let area = imgproc::contour_area(&contour, false)?;

        if area > 1000.0 {
            let perimeter = imgproc::arc_length(&contour, true)?;

            let epsilon = 0.02 * perimeter;
            let mut approx = core::Vector::<core::Point>::new();
            imgproc::approx_poly_dp(&contour, &mut approx, epsilon, true)?;

            if approx.len() == 4 && area > max_area {
                max_area = area;
                best_contour = approx;
            }
        }
    }

    let mut result = Vec::new();
    if best_contour.len() == 4 {
        for i in 0..4 {
            let pt = best_contour.get(i)?;
            result.push(DocPoint {
                x: pt.x as f32,
                y: pt.y as f32,
            })
        }
    }

    Ok(result)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
