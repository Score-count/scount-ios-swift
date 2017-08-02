# Uncomment the next line to define a global platform for your project
platform :ios, ’10.0’
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

def debugPods
    # UI debug
    pod 'Reveal-SDK', :configurations => ['Debug']
    
    # Logger
    pod 'CocoaLumberjack/Swift'
    pod 'Zip', '~> 0.7'
end

  target 'SwiftyScount' do
  inhibit_all_warnings!

  # Pods for SwiftyStoria
  # Analytics
  pod 'Google/Analytics'
  # Core data wrapper
  pod 'AERecord'
  # Core data + UI
  pod 'AECoreDataUI'
  # Link constraint to keyboard appearance
  pod 'UnderKeyboard', '~> 8.0'
  pod 'TPKeyboardAvoiding'
  # HTTP client
  pod 'Alamofire'
  # Manager for image downloading
  pod 'AlamofireImage'
  # Promises
  pod 'PromiseKit'
  # JSON parcer
  pod 'SwiftyJSON'
  # Social networks
  pod 'TwitterKit', '~> 3.0.2'
  pod 'FBSDKCoreKit', '~> 4.20.0'
  pod 'FBSDKLoginKit', '~> 4.20.0'
  pod 'FBSDKShareKit', '~> 4.20.0'
  pod 'GoogleSignIn', '~> 4.0.2'
  pod 'VK-ios-sdk', '~> 1.4'
  pod 'ok-ios-sdk', '~> 2.0'
  # MVVM helper
  pod 'Dollar'
  pod 'RxSwift'
  pod 'RxDataSources'
  pod 'RxCoreData'
  # Visual effects
  pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'
  pod 'DZNEmptyDataSet'
  # Code reducer
  pod 'Reusable', '~> 4.0'
  # Tooltips
  pod 'EasyTipView', '~> 1.0.2'
  # Action sheet
  pod 'XLActionController'
  # Image picker
  pod 'BSImagePicker'
  # Textfield with tags
  pod 'RKTagsView'
  # Photo gallery
  pod 'ImageSlideshow', '~> 1.2'
  pod 'ImageSlideshow/Alamofire'
  # Youtube player
  pod 'youtube-ios-player-helper', :git=>'https://github.com/SelfishInc/youtube-ios-player-helper'

  # Deeplinking
  pod 'Branch'
  pod 'Roots'

  # Betas delivery
  pod 'Fabric'
  pod 'Crashlytics'

  target 'SwiftyScountTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Quick'
    pod 'Nimble'
    pod 'SwiftyJSON'
    pod 'Alamofire'
    pod 'PromiseKit'
    pod 'RxCocoa'
    pod 'AERecord'
    pod 'TPKeyboardAvoiding'
  end

  target 'SwiftyScountUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'UIComponents' do
    # Textfield with floating title
    pod 'SkyFloatingLabelTextField', '~> 3.1.0'
    
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
        '$(FRAMEWORK_SEARCH_PATHS)'
        ]
    end
end
