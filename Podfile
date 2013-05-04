platform :ios, :deployment_target => '6.0'
  
  target :'BasePods' do
      link_with 'UberTimeService'
      pod 'PBFoundation', :podspec => 'LocalPods/PBFoundation.podspec'
      pod 'MagicalRecord', '~> 2.1'
  end

  target :'IntegrationTests' do
      link_with 'IntegrationTests'
      pod 'PBFoundation', :podspec => 'LocalPods/PBFoundation.podspec'
      pod 'MagicalRecord', '~> 2.1'
      pod 'GHUnitIOS', '~> 0.5.6'
  end

inhibit_all_warnings!

