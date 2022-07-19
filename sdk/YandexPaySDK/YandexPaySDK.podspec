Pod::Spec.new do |spec|
  spec.name         	     = "YandexPaySDK"
  spec.version     	       = "1.1.0"
  spec.summary      	     = "SDK for Yandex Pay."
  spec.homepage     	     = 'generic-homepage'

  spec.license 	           = { type: 'Proprietary', text: '2020 © Yandex. All rights reserved.' }

  spec.author              = { "" => "" }

  spec.platform     	     = :ios, "12.0"
  spec.swift_version 	     = '5.0'
  spec.requires_arc 	     = true

  spec.source              = { :http => "file://somefile" }

  spec.frameworks	         = "UIKit", "Foundation"

  spec.dependency 'PromiseKit/CorePromise', '~> 6.0'
  spec.dependency 'YandexLoginSDK', '~> 2.0.2'

  spec.subspec 'Static' do |subspec|
    subspec.vendored_frameworks = 'Static/YandexPaySDK.xcframework', 'Static/XPlatPaySDK.xcframework'
    subspec.resource = "Static/YandexPaySDKResources.bundle"
  end

  spec.subspec 'Dynamic' do |subspec|
    subspec.vendored_frameworks = 'Dynamic/YandexPaySDK.xcframework', 'Dynamic/XPlatPaySDK.xcframework'
  end
end
