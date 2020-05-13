#
# Be sure to run `pod lib lint Categories.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/ntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LiteDevToolKit"
  s.version          = "1.0.0"
  s.summary          = "LiteDevToolKit"
  s.description      = <<-DESC
        LiteDevToolKit
                       DESC
  s.homepage         = "https://www.sunclouds.com/"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "iPhuan"
  s.source           = { :git => "https://www.sunclouds.com/", :tag => s.version }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.frameworks       = "Foundation", "UIKit"


#*********************************Common******************************#
    s.subspec 'Common' do |common|
        common.source_files        = "Common/**/*.{h,m}"
        common.public_header_files = "Common/**/*.h"
        common.frameworks  = "AVFoundation", "CoreTelephony"

        common.dependency 'AFNetworking'

    end

#*********************************Category******************************#
    s.subspec 'Category' do |category|
        category.source_files        = "Category/**/*.{h,m}"
        category.public_header_files = "Category/**/*.h"
        category.resource            = "Category/Images/*.png"

        category.dependency 'MBProgressHUD'
        category.dependency 'LiteDevToolKit/Common'
    end


#*********************************TokenHelper******************************#
    s.subspec 'TokenHelper' do |token|
        token.source_files        = "TokenHelper/**/*.{h,m}"
        token.public_header_files = "TokenHelper/**/*.h"

        token.dependency 'LiteDevToolKit/Common'
        token.dependency 'LiteDevToolKit/Category'

    end
    
    
#*********************************UIComponent******************************#
    s.subspec 'UIComponent' do |ui|
        ui.source_files        = "UIComponent/**/*.{h,m}"
        ui.public_header_files = "UIComponent/**/*.h"

        ui.dependency 'Masonry'
        ui.dependency 'LiteDevToolKit/Common'
        ui.dependency 'LiteDevToolKit/Category'

    end



end
