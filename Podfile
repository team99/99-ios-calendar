# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def allLogicPods
  pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
  pod 'RxSwift', '~> 4.0'
end

def allViewPods
  pod 'RxCocoa', '~> 4.0'
  pod 'RxDataSources'
end

def allTestPods
  pod 'SwiftUtilities/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
  pod 'SwiftUtilitiesTests/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
end

target 'calendar99' do
  use_frameworks!
  allLogicPods
  allViewPods

  # Pods for calendar99

  target 'calendar99Tests' do
    inherit! :search_paths
  end

  target 'calendar99-demo' do
    inherit! :search_paths
  end
end

target 'calendar99-logic' do
  inherit! :search_paths
  use_frameworks!
  allLogicPods

  target 'calendar99-logicTests' do
    inherit! :search_paths
    allTestPods
  end
end
