/*
 ***********************************************************************************
 *
 *  File     : InputAccessoryViewManager.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/11/15.
 ***********************************************************************************
 */

#import <Foundation/Foundation.h>

@interface InputAccessoryViewManager : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;             // 背景色，默认值#F2F2F2
@property (nonatomic, copy) NSString *cancelButtonTitle;            // 取消按钮标题，默认“取消”
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;      // 取消按钮标题颜色，默认值#999999
@property (nonatomic, strong) UIFont *cancelButtonFont;             // 取消按钮字体大小，默认14

@property (nonatomic, copy) NSString *confirmButtonTitle;           // 确定按钮标题，默认“确定”
@property (nonatomic, strong) UIColor *confirmButtonTitleColor;     // 确定按钮标题颜色，默认值#3D3D3D
@property (nonatomic, strong) UIFont *confirmButtonFont;            // 确定按钮字体大小，默认14

@property (nonatomic, strong) UIColor *titleLabelTextColor;         // titleLabel颜色，默认值#3D3D3D
@property (nonatomic, strong) UIFont *titleLabelFont;               // textLabel字体大小，默认17

@property (nonatomic, strong) UIColor *separatorLineBackgroundColor;// 底部分割线背景色，默认值#F9F9F9


+ (instancetype)sharedManager;


@end
