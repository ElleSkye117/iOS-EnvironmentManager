# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

source 'https://github.com/markitondemand/MDPodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example
  # pod 'MD-Extensions'
  pod 'MDEnvironmentManager', :path => './MDEnvironmentManager.podspec'

end

target 'MDEnvironmentManager' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MDEnvironmentManager
  pod 'MDEnvironmentManager', :path => './MDEnvironmentManager.podspec'
  
  target 'MDEnvironmentManagerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
