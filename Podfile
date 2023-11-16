# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'GolloApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for PromosGollo
  pod 'AAInfographics', :git => 'https://github.com/AAChartModel/AAChartKit-Swift.git'
  pod 'FirebaseAuth'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestore'
  pod 'FirebaseAnalytics'
  pod 'FirebaseMessaging'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseDynamicLinks'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'GoogleSignIn'
  pod 'ImageSlideshow'
  pod "ImageSlideshow/Alamofire"
  pod 'Nuke', '~> 10.7.1'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SideMenu', '~> 6.5.0'
  pod 'DropDown'
  pod 'NotificationBannerSwift', '~> 3.2.1'
  
  pod 'XCGLogger'
  
  pod 'GolloNetWorking', :path => '/Users/rosegueda/Documents/Personales/Proyectos/Merckers/Gollo/GolloApp-Modules/GolloNetWorking'
  
  target 'GolloAppTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'GolloAppUITests' do
    # Pods for testing
  end
  
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
    end
  end
end
