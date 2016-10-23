
use_frameworks!
target 'Watson Cardiology' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Watson Cardiology
  pod 'JSQMessagesViewController','7.3.4'
  pod 'Alamofire', '3.5.0'
  pod 'Freddy', '2.1.0'

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '2.3'
          end
      end
  end

end
