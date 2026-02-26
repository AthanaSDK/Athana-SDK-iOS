Pod::Spec.new do |s|
  s.name             = 'AthanaCore'
  s.version          = '1.0.9'
  s.summary          = 'Athana SDK'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :http => 'https://athana.inonesdk.com/ios/sdk/1.0.9/AthanaCore.xcframework.zip', :type => 'zip' }
  s.license          = { :type => 'CWJoy Software License Agreement', :file => 'LICENSE' }

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target

  # 发布二进制
  s.vendored_frameworks = 'AthanaCore.xcframework'
  s.static_framework = true

  s.framework = 'UIKit'
  s.swift_versions = ['5.0']

end
