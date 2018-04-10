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

target 'calendar99' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  allLogicPods
  allViewPods

  # Pods for calendar99

  target 'calendar99Tests' do
    inherit! :search_paths
    # Pods for testing
    allLogicPods
  end

  target 'calendar99-logic' do
    inherit! :search_paths
    # Pods for testing
    allLogicPods
  end

  target 'calendar99-logicTests' do
    inherit! :search_paths
    # Pods for testing
    allLogicPods
  end

  target 'calendar99-demo' do
    inherit! :search_paths
    # Pods for testing
    allLogicPods
    allViewPods
  end
end
