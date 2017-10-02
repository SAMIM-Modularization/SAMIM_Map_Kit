#
# Be sure to run `pod lib lint SAMIM_Map_Kit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SAMIM_Map_Kit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of SAMIM_Map_Kit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/SAMIM-Modularization/SAMIM_Map_Kit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '811528603@qq.com' => '811528603@qq.com' }
  s.source           = { :git => 'https://github.com/SAMIM-Modularization/SAMIM_Map_Kit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SAMIM_Map_Kit/Classes/**/*'
  
  s.resource_bundles = {
     'SAMIM_Map_Kit' => ['SAMIM_Map_Kit/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency "MJRefresh","~> 1.4.6"
  s.dependency "AMapLocation-NO-IDFA"
  s.dependency "AMapSearch-NO-IDFA"
  s.dependency "AMap2DMap-NO-IDFA"

end
