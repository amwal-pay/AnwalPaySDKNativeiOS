platform :ios, '15.0' # Recommended minimum iOS version



target 'AnwalPaySDKNativeiOSExample' do
  use_frameworks! # Required for Flutter modules

  # Use Debug for simulator testing, Release for device/production
#   pod 'amwalsdk/Debug'
  pod 'amwalsdk/Release'  # Uncomment for release builds
#   pod 'amwalsdk/Release', :path => '../amwal_pay_sdk/AnwalPaySDKNativeiOSExample/amwalsdk'
end

# FlutterPluginRegistrant is a static xcframework. CocoaPods with use_frameworks!
# links it into both amwalsdk.framework (correct) and the main app binary (duplicate).
# This hook removes it from the main app's linker flags so GeneratedPluginRegistrant
# is only defined once — inside amwalsdk.framework where AmwalSDK.swift calls it.
post_install do |installer|
  # FlutterPluginRegistrant is a static lib already linked into amwalsdk.framework.
  # Removing it from the main app's ldflags prevents the duplicate GeneratedPluginRegistrant class.
  support_files = File.join(installer.sandbox.root.to_s, 'Target Support Files', 'Pods-AnwalPaySDKNativeiOSExample')
  Dir.glob(File.join(support_files, '*.xcconfig')).each do |path|
    content = File.read(path)
    updated = content.gsub('-framework "FlutterPluginRegistrant"', '')
    File.write(path, updated) if updated != content
    puts "post_install: patched #{File.basename(path)}" if updated != content
  end
end
