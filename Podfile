platform :ios, '15.0' # Recommended minimum iOS version



target 'AnwalPaySDKNativeiOSExample' do
  use_frameworks! # Required for Flutter modules

  # Use Debug for simulator testing, Release for device/production
   pod 'amwalsdk/Release'
#   pod 'amwalsdk/Release','1.1.71'
#  pod 'amwalsdk/Release', :path => '../amwal_pay_sdk/AnwalPaySDKNativeiOSExample/amwalsdk'

  # amwalsdk 1.1.99+ App.framework was built with Flutter 3.41 which uses the FFI-based
  # objective_c package for path_provider_foundation. The released pod ships no
  # objective_c.framework, so GetStorage._init throws DOBJC_initializeApi at runtime.
  # Simulator-only slice vendored locally until the SDK's CI packaging includes it.
  pod 'objective_c', :path => 'LocalPods/objective_c'
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
