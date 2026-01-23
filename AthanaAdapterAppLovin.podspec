Pod::Spec.new do |s|
  s.name             = 'AthanaAdapterAppLovin'
  s.version          = '1.0.1'
  s.summary          = 'Athana SDK - Adapter - AppLovin'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :git => 'https://github.com/AthanaSDK/Athana-SDK-iOS.git', :tag => s.version }
  s.license          = 'CWJoy Software License Agreement', :file => 'LICENSE'

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target
  s.source_files = 'Sources/AthanaAdapterAppLovin/**/*.swift'
  s.framework = 'Foundation'
  s.dependency 'AthanaCore', '~> 1.0.1'
  s.dependency 'AppLovinSDK', '>= 13.2.0'
  s.swift_versions = ['5.0']

  s.test_spec 'swift-unit' do |swift_unit_tests|
    swift_unit_tests.platforms = {
      :ios => ios_deployment_target,
    }
    swift_unit_tests.source_files = [
      'Tests/AthanaAdapterAppLovin/**/*.swift',
      'Tests/AthanaAdapterAppLovin/**/*.h',
    ]
  end
end
