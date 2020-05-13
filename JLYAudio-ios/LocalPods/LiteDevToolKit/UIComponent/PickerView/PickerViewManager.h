//
//  PickerViewManager.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/9/28.
//


#import <Foundation/Foundation.h>

@interface PickerViewManager : NSObject
@property (nonatomic, strong) UIColor *backgroundColor;      // 背景颜色，默认值白色
@property (nonatomic, strong) UIColor *textColor;      // 文字颜色，默认值#3D3D3D
@property (nonatomic, assign) CGFloat rowHeight;      // 每行高度，默认值43






+ (instancetype)sharedManager;


@end
