//
//  kCommonMacros.h
//  iPhuanLib
//
//  Created by iPhuan on 2017/2/21.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "UIColor+Additions.h"



#pragma mark - Geometry
/*****************************************************************************************/
#define kScreenWidth         [UIScreen mainScreen].bounds.size.width
#define kScreenHeight        [UIScreen mainScreen].bounds.size.height
#define kScreenBounds        [UIScreen mainScreen].bounds

#define kXSizeMultiple      (kScreenHeight/667.0)
#define kXFitSize(X)        ((X) * kXSizeMultiple)   // 以6为参考，5，6，6P，X等比缩放，适应于纵向布局

#define k6PSizeMultiple      (kScreenWidth <= 375?1.0:(kScreenWidth/375.0))
#define k6PFitSize(X)        ((X) * k6PSizeMultiple)  // 以6为参考，5和6保持一样的值，6P等比缩放

#define kRatioMultiple       (kScreenWidth/375.0)
#define kRatioFitSize(X)     ((X) * kRatioMultiple)  // 以6为参考，5和6P等比缩放

#define k5SizeMultiple       (kScreenWidth >= 375?1.0:(kScreenWidth/375.0))
#define k5FitSize(X)         ((X) * k5SizeMultiple)   // 以6为参考，6和6P保持一样的值，5等比缩放



#pragma mark - UIAdapter
/*****************************************************************************************/

#define kIsIPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})



#define kTopOffset          (kIsIPhoneX ? 24 : 0)
#define kBottomOffset       (kIsIPhoneX ? 34 : 0)
#define kNavBarHeight       (kIsIPhoneX ? 88 : 64)
#define kStatusBarHeight    (kIsIPhoneX ? 44 : 20)
#define kTabBarHeight       (kIsIPhoneX ? 83 : 49)



#pragma mark - Conditional Judgment
/*****************************************************************************************/
#define kIsKindOfString(X)           ([X isKindOfClass:[NSString class]])
#define kIsAvailableString(X)        ([X isKindOfClass:[NSString class]] && ![@"" isEqualToString:X])
#define kIsUnAvailableString(X)      (![X isKindOfClass:[NSString class]] || [@"" isEqualToString:X])
#define kUnNilString(X)              ([X isKindOfClass:[NSString class]]?X:@"")
#define kSetAvailableValueForString(string, value)   if (kIsUnAvailableString(string)) { \
string = value; \
}

#define kIsKindOfArray(X)            ([X isKindOfClass:[NSArray class]])
#define kIsAvailableArray(X)         ([X isKindOfClass:[NSArray class]] && X.count)
#define kIsUnAvailableArray(X)       (![X isKindOfClass:[NSArray class]] || X.count == 0)

#define kIsKindOfDictionary(X)       ([X isKindOfClass:[NSDictionary class]])
#define kIsAvailableDictionary(X)    ([X isKindOfClass:[NSDictionary class]] && X.count)
#define kIsUnAvailableDictionary(X)  (![X isKindOfClass:[NSDictionary class]] || X.count == 0)




#pragma mark - Others
/*****************************************************************************************/
#define kImageNamed(name)           [UIImage imageNamed:name]
#define kColorHex(HEX)              [UIColor colorWithHexString:HEX]



#define kColorWithRGB(R, G, B)      [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define kColorWithRGBA(R, G, B, A)  [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]





#ifdef DEBUG
#define kLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define kLog(xx, ...)  ((void)0)
#endif


