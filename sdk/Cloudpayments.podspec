#
#  Be sure to run `pod spec lint SDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "Cloudpayments"
  spec.version      = "1.2.13"
  spec.summary      = "Core library that allows you to use internet acquiring from CloudPayments in your app"
  spec.description  = "Core library that allows you to use internet acquiring from CloudPayments in your app!"

  spec.homepage     = "https://cp.ru/"

  spec.license      = "{ :type => 'Apache 2.0' }"

  spec.author       = { "Anton Ignatov" => "a.ignatov@cp.ru" }
	
  spec.platform     = :ios
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/cloudpayments/CloudPayments-SDK-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = 'Sources/**/*.swift'

  spec.resource_bundles = { 'CloudpaymentsSDK' => ['Resources/**/*.{txt,json,png,jpeg,jpg,storyboard,xib,xcassets}']} 
  
  spec.requires_arc = true

  spec.dependency 'CloudpaymentsNetworking'  
  spec.dependency 'YandexLoginSDK'
  spec.dependency 'YandexPaySDK/Dynamic'

  spec.swift_version = '5.0'

end
