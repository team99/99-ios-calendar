# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def allBasePods
  pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
end

def allLogicPods
  allBasePods
  pod 'RxSwift', '~> 4.0'
end

def allViewPods
  allLogicPods
  pod 'RxCocoa', '~> 4.0'
  pod 'RxDataSources'
end

def allReduxPods
  allBasePods
  pod 'HMReactiveRedux/Main+Rx', git: 'https://github.com/protoman92/HMReactiveRedux-Swift.git'
end

def allTestPods
  allLogicPods
  pod 'SwiftUtilities/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
  pod 'SwiftUtilitiesTests/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
end

target 'calendar99' do
  use_frameworks!
  allViewPods

  # Pods for calendar99

  target 'calendar99Tests' do
    inherit! :search_paths
  end

  target 'calendar99-demo' do
    inherit! :search_paths
    allReduxPods
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

target 'calendar99-redux' do
  inherit! :search_paths
  use_frameworks!
  allReduxPods

  target 'calendar99-reduxTests' do
    inherit! :search_paths
    allTestPods
  end
end
