Pod::Spec.new do |s|
  s.name             = 'Athana'
  s.version          = '1.0.9'
  s.summary          = 'Athana SDK'
  s.homepage         = 'https://athana.inonesdk.com'
  s.authors          = 'CWJoy'
  s.source           = { :git => 'https://github.com/AthanaSDK/Athana-SDK-iOS.git', :tag => s.version }
  s.license          = { :type => 'CWJoy Software License Agreement', :file => 'LICENSE' }

  ios_deployment_target = '13.0'

  s.ios.deployment_target = ios_deployment_target
  s.swift_versions = ['5.0']

  s.default_subspec = 'AthanaSDK'

  s.subspec 'AthanaCore' do |ss|
    ss.dependency 'AthanaCore', s.version.to_s
  end

  s.subspec 'AthanaSDK' do |ss|
    ss.dependency 'AthanaSDK', s.version.to_s
  end

  s.subspec 'AthanaAdapterApple' do |ss|
    ss.dependency 'AthanaAdapterApple', s.version.to_s
  end

  s.subspec 'AthanaAdapterAppLovin' do |ss|
    ss.dependency 'AthanaAdapterAppLovin', s.version.to_s
  end

  s.subspec 'AthanaAdapterAppsFlyer' do |ss|
    ss.dependency 'AthanaAdapterAppsFlyer', s.version.to_s
  end

  s.subspec 'AthanaAdapterFirebase' do |ss|
    ss.dependency 'AthanaAdapterFirebase', s.version.to_s
  end

  s.subspec 'AthanaAdapterGoogle' do |ss|
    ss.dependency 'AthanaAdapterGoogle', s.version.to_s
  end

  s.subspec 'AthanaAdapterMeta' do |ss|
    ss.dependency 'AthanaAdapterMeta', s.version.to_s
  end

end
