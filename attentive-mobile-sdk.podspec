#
# Be sure to run `pod lib lint mobile-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'attentive-mobile-sdk'
  s.version          = '0.1.0'
  s.summary          = 'Attentive Mobile SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Attentive Mobile SDK provides the functionality to render Attentive signup units in iOS mobile applications.
                       DESC

  s.homepage         = 'https://www.attentive.com/demo?utm_source=cocoapods.org'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ivan Loughman-Pawelko' => 'iloughman@attentivemobile.com' }
  s.source           = { :git => 'git@github.com:attentive-mobile/mobile-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Creative/**/*'
  
  # s.resource_bundles = {
  #   'mobile-sdk' => ['mobile-sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end