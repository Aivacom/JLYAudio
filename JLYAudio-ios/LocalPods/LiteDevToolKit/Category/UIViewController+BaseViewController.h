//
//  UIViewController+BaseViewController.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/21.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BaseSetup)

+ (void)setGlobalBackBarButtonItemImage:(UIImage *)image;  // 设置全局返回按钮图标，默认使用nav_btn_back
+ (void)setGlobalBackgroundColor:(UIColor *)color;         // 设置全局背景色，默认白色

- (void)setupNavigationBarWithBarTintColor:(UIColor *)barTintColor
                                titleColor:(UIColor *)titleColor
                                 titleFont:(UIFont *)font
                    eliminateSeparatorLine:(BOOL)yesOrNo;

- (void)setupBackBarButtonItem;  // 设置返回按钮并关联默认的返回操作Action：自动识别pop或者dismiss
- (void)setBackBarButtonItemAction:(SEL)action; // 设置后将不执行默认的返回Action
- (void)setupBaseSetting;        // 初始化基础设置，背景色，布局标准等
- (void)setupCommonSetting;      // 初始化通用设置，包含setupBackButtonBarItem和setupBaseSetting


@end
