Pod::Spec.new do |s|
  s.name             = 'AthanaSDK'
  s.version          = '1.0.8'
  s.summary          = 'Athana SDK'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :http => 'https://athana.inonesdk.com/ios/sdk/1.0.8/AthanaSDK.xcframework.zip', :type => 'zip' }
  s.license          = { :type => 'CWJoy Software License Agreement', :file => 'LICENSE' }
  
  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target

  # 发布二进制
  s.vendored_frameworks = 'AthanaSDK.xcframework'

  s.framework = 'Foundation'
  s.framework = 'StoreKit'
  s.framework = 'SwiftUI'
  s.framework = 'UIKit'
  s.dependency 'AthanaCore', '~> 1.0.8'
  s.swift_versions = ['5.0']

end
