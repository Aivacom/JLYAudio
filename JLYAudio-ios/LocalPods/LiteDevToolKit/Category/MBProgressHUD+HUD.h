//
//  MBProgressHUD+HUD.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/26.
//


#import "MBProgressHUD.h"

@interface MBProgressHUD (HUD)

// 显示toast提示
+ (void)showToast:(NSString *)message;

+ (void)showToast:(NSString *)message duration:(NSTimeInterval)duration;

// margin设置边距
+ (void)showToast:(NSString *)message margin:(CGFloat)margin duration:(NSTimeInterval)duration;

// 显示loading
+ (void)showActivityIndicator;

// 显示带”加载中...“的loading
+ (void)showLoadingActivityIndicator;

// 显示指定提示语的loading
+ (void)showActivityIndicatorWithMessage:(NSString *)message;


+ (void)hideActivityIndicator;

@end
