#
#  Be sure to run `pod spec lint SDK-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "CloudpaymentsNetworking"
  spec.version      = "1.0.0"
  spec.summary      = "Networking layer for Cloudpayments SDK's"
  spec.description  = "Networking layer for Cloudpayments SDK's"

  spec.homepage     = "https://cloudpayments.ru/"

  spec.license      = "{ :type => 'Apache 2.0' }"

  spec.author       = { "Anton Ignatov" => "a.ignatov@cloudpayments.ru",
			"Sergey Iskhakov" => "s.iskhakov@cloudpayments.ru" }
	
  spec.platform     = :ios
  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/cloudpayments/CloudPayments-SDK-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = 'networking/source/**/*.swift'

  spec.resource_bundles = { 'Cloudpayments' => ['sdk/Resources/**/*.{json,png,jpeg,jpg,storyboard,xib,xcassets}']} 
  
  spec.requires_arc = true
  
end
