Pod::Spec.new do |s|
  s.name             = 'AthanaAdapterMeta'
  s.version          = '1.0.9'
  s.summary          = 'Athana SDK - Adapter - Meta'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :git => 'https://github.com/AthanaSDK/Athana-SDK-iOS.git', :tag => s.version }
  s.license          = { :type => 'CWJoy Software License Agreement', :file => 'LICENSE' }

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target
  s.source_files = 'Sources/AthanaAdapterMeta/**/*.swift'
  s.framework = 'Foundation'
  s.dependency 'AthanaCore', '~> 1.0.9'
  s.dependency 'FBSDKCoreKit', '>= 18.0.0'
  s.dependency 'FBSDKLoginKit', '>= 18.0.0'
  s.swift_versions = ['5.0']

  s.test_spec 'swift-unit' do |swift_unit_tests|
    swift_unit_tests.platforms = {
      :ios => ios_deployment_target,
    }
    swift_unit_tests.source_files = [
      'Tests/AthanaAdapterMeta/**/*.swift',
      'Tests/AthanaAdapterMeta/**/*.h',
    ]
  end
end
