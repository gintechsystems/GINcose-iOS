platform :ios, '8.0'

target 'GINcose' do

use_frameworks!

pod 'RealmSwift'
pod 'Charts'
pod 'Charts/Realm'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
