#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dscan.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dscan'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = 'A new Flutter FFI plugin project.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '13.0'
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust dscan',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/libdscan.a"],
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '$(inherited) /opt/homebrew/opt/opencv/include/opencv4',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) /opt/homebrew/opt/opencv/lib',
    'OTHER_LDFLAGS' => '$(inherited) -force_load "${BUILT_PRODUCTS_DIR}/libdscan.a" -L/opt/homebrew/opt/opencv/lib -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio -framework OpenCL'
  }

  s.user_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(inherited) /opt/homebrew/opt/opencv/lib'
  }
end
