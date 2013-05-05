platform :ios, :deployment_target => '6.0'
  
  target :'BasePods' do
      link_with 'UberTimeService'
      pod 'PBFoundation', :podspec => 'LocalPods/PBFoundation.podspec'
      pod 'MagicalRecord', '~> 2.1'
      pod 'Parse', '~> 1.2'
      pod 'Facebook-iOS-SDK', '~> 3.5'
      pod 'GCNetworkReachability', '~> 1.3'
  end

  target :'IntegrationTests' do
      link_with 'IntegrationTests'
      pod 'PBFoundation', :podspec => 'LocalPods/PBFoundation.podspec'
      pod 'MagicalRecord', '~> 2.1'
      pod 'Parse', '~> 1.2'
      pod 'Facebook-iOS-SDK', '~> 3.5'
      pod 'GCNetworkReachability', '~> 1.3'
      pod 'GHUnitIOS', '~> 0.5.6'
  end

inhibit_all_warnings!

