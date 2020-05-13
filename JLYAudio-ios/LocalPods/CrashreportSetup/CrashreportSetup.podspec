#
# Be sure to run `pod lib lint Categories.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CrashreportSetup"
  s.version          = "1.0.0"
  s.summary          = "CrashreportSetup"
  s.description      = <<-DESC
        CrashreportSetup
                       DESC
  s.homepage         = "https://www.sunclouds.com/"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "iPhuan"
  s.source           = { :git => "https://www.sunclouds.com/", :tag => s.version }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.source_files  = "*.{h,m}"
  s.public_header_files = "*.h"

  s.dependency 'crashreportsdk/staticCore', '2.0.5'

end
