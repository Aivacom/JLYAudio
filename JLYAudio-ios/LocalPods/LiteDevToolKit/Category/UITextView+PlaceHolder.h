/*
 ***********************************************************************************

 *  File     : UITextView+PlaceHolder.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/7/2.
 ***********************************************************************************
 */

#import <UIKit/UIKit.h>

@interface UITextView (PlaceHolder)

@property (nullable, nonatomic, copy) NSString *placeholder;
@property (nullable, nonatomic, copy) NSAttributedString *attributedPlaceholder;
@property (nonnull, nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, assign) NSTextAlignment placeholderTextAlignment;


@end
