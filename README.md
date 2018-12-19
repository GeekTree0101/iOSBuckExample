# iOS Buck Example

https://buckbuild.com/setup/getting_started.html

## Install

```sh
brew tap facebook/fb
brew install buck
brew tap caskroom/cask
brew tap caskroom/versions
brew cask install java8
brew install ant python git watchman
pod install
```

## Run

```sh
make build
```

## How does it work? 

> ## STEP1: install pod and file utility will deploy Pod Buck files from buck-files dir
```ruby
use_frameworks!

target 'iOSBuckExample' do
    pod 'RxSwift'
end

post_install do |installer|
  require 'fileutils'

  # Assuming we're at the root dir
  buck_files_dir = 'buck-files'
  if File.directory?(buck_files_dir)
    installer.pod_targets.flat_map do |pod_target|
      pod_name = pod_target.pod_name
      # Copy the file at buck-files/BUCK_pod_name to Pods/pod_name/BUCK,
      # override existing file if needed
      buck_file = buck_files_dir + '/BUCK_' + pod_name
      if File.file?(buck_file)
        FileUtils.cp(buck_file, 'Pods/' + pod_name + '/BUCK', :preserve => false)
      end
    end
  end
end
```
> ## STEP2: buck build 

```sh
make build
```

is equal with

```sh
buck build //iOSBuckExample:iOSBuckExampleBundle
```

> ## STEP3: .buckconfig
```bzl
[cxx]
  default_platform = iphonesimulator-x86_64
  combined_preprocess_and_compile = true

[apple]
  iphonesimulator_target_sdk_version = 9.0
  iphoneos_target_sdk_version = 9.0
  xctool_default_destination_specifier = platform=iOS Simulator, name=iPhone 7, OS=12.0

[alias]
  app = //iOSBuckExample:iOSBuckExampleBundle

[httpserver]
  port = 8000

[project]
  ide = xcode
  ignore = .buckd, \
           .hg, \
           .git, \
           buck-out, \

```
- [cxx]: platform enviorment
- [apple]: apple platfrom enviorment
- [alias]: buck interface shortcut
- [httpserver]: buck build trace visual log 
- [project]: project enviorment


> ## STEP4: Project BUCK file 
```bzl

# Convenicen Config & Mecro file (copyright: https://github.com/airbnb/BuckSample)
load("//Config:configs.bzl", "binary_configs", "library_configs", "pod_library_configs", "info_plist_substitutions")

# Asset
apple_asset_catalog(
    name = "iOSBuckExampleAssets",
    visibility = ["PUBLIC"],
    dirs = ["Assets.xcassets"],
)

# Resource (such as xib, storyboard, launchscreen and so on)
apple_resource(
    name = "iOSBuckExampleResource",
    visibility = ["PUBLIC"],
    files = glob(["**/*.storyboard"]),
)

# Binary Srouce (Your soruce code, Pod libary, Apple platform frameworks etc)
apple_binary(
  name = "iOSBuckExampleBinary",
  visibility = ["PUBLIC"],
  swift_version = "4.2",
  configs = binary_configs("iOSBuckExample"),
  srcs = glob([
    "main.m",
    "**/*.swift"
  ]),
  deps = [
    ":iOSBuckExampleAssets",
    ":iOSBuckExampleResource",
    "//Pods/RxAtomic:RxAtomic",
    "//Pods/RxSwift:RxSwift"
  ],
  frameworks = [
    '$SDKROOT/System/Library/Frameworks/Foundation.framework',
    '$SDKROOT/System/Library/Frameworks/UIKit.framework'
  ],
)

# workspace project file configuration
xcode_workspace_config(
    name = "workspace",
    visibility = ["PUBLIC"],
    workspace_name = "iOSBuckExample",
    src_target = ":iOSBuckExampleBundle",
    additional_scheme_actions = {
        "Build": {
            "PRE_SCHEME_ACTIONS": ["echo 'Started Building'"],
            "POST_SCHEME_ACTIONS": ["echo 'Finished Building'"],
        },
    },
    action_config_names = {"profile": "Profile"},
)

# Bundle
apple_bundle(
    name = "iOSBuckExampleBundle",
    visibility = ["PUBLIC"],
    extension = "app",
    binary = ":iOSBuckExampleBinary",
    product_name = "iOSBuckExample",
    info_plist = "Info.plist",
    info_plist_substitutions = info_plist_substitutions("iOSBuckExample"),
)

# Packgage
apple_package(
  name = "iOSBuckExamplePackage",
  bundle = ":iOSBuckExampleBundle",
)

```

> ## STEP5: CocoaPod BUCK file (ref: buck-files dir)

RxSwift
```bzl
apple_library(
    name = "RxSwift",        # <---------- Podname
    modular = True,          # <---------- Moduler
    preprocessor_flags = [   
        "-fobjc-arc"
    ],
    visibility = ["PUBLIC"], # <---------- Must be true!
    swift_version = "4.2",  
     srcs = glob([
      "**/*.m",
      "**/*.mm",
      "**/*.swift",
    ]),
    exported_headers = glob([
      "**/*.h",
    ]),
    deps = [
        "//Pods/RxAtomic:RxAtomic" . # <---------- Other Pod dependency at here!
    ],
    frameworks = [
        "$SDKROOT/System/Library/Frameworks/Foundation.framework",   # <----- Frameworks!
        "$SDKROOT/System/Library/Frameworks/UIKit.framework"
    ] 
)

```

RxAtomic
```bzl
apple_library(
    name = "RxAtomic",
    visibility = ["PUBLIC"],
    modular = True,
    swift_version = "4.2",
    exported_headers = glob([
        "**/*.h",
    ]),
    srcs = glob([
        "**/*.c",
    ])
)
```
