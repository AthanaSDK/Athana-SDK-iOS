Pod::Spec.new do |s|
  s.name             = 'Athana'
  s.version          = '1.0.8'
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
    ss.ios.deployment_target = ios_deployment_target
  end

  s.subspec 'AthanaSDK' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterApple' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterAppLovin' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterAppsFlyer' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterFirebase' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterGoogle' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

  s.subspec 'AthanaAdapterMeta' do |ss|
    ss.ios.deployment_target = ios_deployment_target

    ss.dependency 'Athana/AthanaCore'
  end

end
