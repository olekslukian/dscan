use anyhow::Result;
use opencv::{core, imgcodecs, imgproc};

#[derive(Clone, Copy)]
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
    imgproc::canny_def(&blurred, &mut edges, 50.0, 150.0)?;

    let mut dilated_edges = core::Mat::default();
    let kernel = imgproc::get_structuring_element(
        imgproc::MORPH_RECT,
        core::Size::new(3, 3),
        core::Point::new(-1, -1),
    )?;
    imgproc::dilate_def(&edges, &mut dilated_edges, &kernel)?;

    let mut contours = core::Vector::<core::Vector<core::Point>>::new();
    imgproc::find_contours_def(
        &dilated_edges,
        &mut contours,
        imgproc::RETR_LIST,
        imgproc::CHAIN_APPROX_SIMPLE,
    )?;

    let mut contour_info: Vec<(f64, core::Vector<core::Point>)> = Vec::new();
    for i in 0..contours.len() {
        let contour = contours.get(i)?;
        let area = imgproc::contour_area(&contour, false)?;

        if area > 5000.0 {
            contour_info.push((area, contour));
        }
    }

    contour_info.sort_by(|a, b| b.0.partial_cmp(&a.0).unwrap());

    let mut best_contour = core::Vector::<core::Point>::new();

    for (_, contour) in contour_info {
        let perimeter = imgproc::arc_length(&contour, true)?;

        let epsilon = 0.04 * perimeter;

        let mut approx = core::Vector::<core::Point>::new();
        imgproc::approx_poly_dp(&contour, &mut approx, epsilon, true)?;

        if approx.len() == 4 {
            best_contour = approx;
            break;
        }
    }

    let mut result = Vec::new();

    if best_contour.len() == 4 {
        let mut raw_points = Vec::new();
        for i in 0..4 {
            let pt = best_contour.get(i)?;
            raw_points.push(DocPoint {
                x: pt.x as f32,
                y: pt.y as f32,
            })
        }

        let mut by_sum = raw_points.clone();
        by_sum.sort_by(|a, b| (a.x + a.y).partial_cmp(&(b.x + b.y)).unwrap());
        let top_left = by_sum[0];
        let bottom_right = by_sum[3];

        let mut by_diff = raw_points.clone();
        by_diff.sort_by(|a, b| (a.y - a.x).partial_cmp(&(b.y - b.x)).unwrap());
        let top_right = by_diff[0];
        let bottom_left = by_diff[3];

        result.push(top_left);
        result.push(top_right);
        result.push(bottom_right);
        result.push(bottom_left);
    }

    Ok(result)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
