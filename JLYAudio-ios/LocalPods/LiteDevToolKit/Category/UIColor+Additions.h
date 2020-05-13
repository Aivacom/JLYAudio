//
//  UIColor+Additions.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




#pragma mark - UIColor

#ifndef SYColorHex
#define kColorHex(HEX)   [UIColor colorWithHexString:HEX]
#endif

@interface UIColor (Additions)


//RGB,RGBA,RRGGBB,RRGGBBAA
+ (instancetype)colorWithHexString:(NSString *)hexString;

@end



