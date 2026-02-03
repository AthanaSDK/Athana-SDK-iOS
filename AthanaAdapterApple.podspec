Pod::Spec.new do |s|
  s.name             = 'AthanaAdapterApple'
  s.version          = '1.0.5'
  s.summary          = 'Athana SDK - Adapter - Apple'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :git => 'https://github.com/AthanaSDK/Athana-SDK-iOS.git', :tag => s.version }
  s.license          = 'CWJoy Software License Agreement', :file => 'LICENSE'

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target
  s.source_files = 'Sources/AthanaAdapterApple/**/*.swift'
  s.framework = 'Foundation'
  s.dependency 'AthanaCore', '~> 1.0.5'
  s.swift_versions = ['5.0']

  s.test_spec 'swift-unit' do |swift_unit_tests|
    swift_unit_tests.platforms = {
      :ios => ios_deployment_target,
    }
    swift_unit_tests.source_files = [
      'Tests/AthanaAdapterApple/**/*.swift',
      'Tests/AthanaAdapterApple/**/*.h',
    ]
  end
end
