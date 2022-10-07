# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'PromosGollo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for PromosGollo
  pod 'AAInfographics', :git => 'https://github.com/AAChartModel/AAChartKit-Swift.git'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'GoogleSignIn'
  pod 'ImageSlideshow'
  pod "ImageSlideshow/Alamofire"
  pod 'Nuke', '~> 9.0'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SideMenu', '~> 6.0'
  pod 'DropDown'
  
  pod 'XCGLogger'
  
  pod 'GolloNetWorking', :path => '/Users/jonathanrodriguez/Documents/Work/Merckers/GolloPromos-iOS-Modules/GolloNetWorking'
  
  target 'PromosGolloTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'PromosGolloUITests' do
    # Pods for testing
  end
  
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
  end
 end
end
