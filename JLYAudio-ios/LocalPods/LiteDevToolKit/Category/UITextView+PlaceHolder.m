/*
 ***********************************************************************************

 *  File     : UITextView+PlaceHolder.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/7/2.
 ***********************************************************************************
 */

#import "UITextView+PlaceHolder.h"
#include <objc/message.h>


static char const * const kPlaceHolderTextViewKey = "kPlaceHolderTextViewKey";


@implementation UITextView (PlaceHolder)

+ (void)load {
    [super load];
    
    Method setTextMethod = class_getInstanceMethod([UITextView class], @selector(setText:));
    Method toSetTextMethod = class_getInstanceMethod([UITextView class], @selector(swizzing_setText:));
    method_exchangeImplementations(setTextMethod, toSetTextMethod);
    
    Method setFontMethod = class_getInstanceMethod([UITextView class], @selector(setFont:));
    Method toSetFontMethod = class_getInstanceMethod([UITextView class], @selector(swizzing_setFont:));
    method_exchangeImplementations(setFontMethod, toSetFontMethod);
    
    Method setTextContainerInsetMethod = class_getInstanceMethod([UITextView class], @selector(setTextContainerInset:));
    Method toSetTextContainerInsetMethod = class_getInstanceMethod([UITextView class], @selector(swizzing_setTextContainerInset:));
    method_exchangeImplementations(setTextContainerInsetMethod, toSetTextContainerInsetMethod);
}

- (void)swizzing_setText:(NSString *)text {
    [self swizzing_setText:text];
    self.placeHolderTextView.hidden = self.text.length;
}

- (void)swizzing_setFont:(UIFont *)font {
    [self swizzing_setFont:font];
    self.placeHolderView.font = self.font;
}

- (void)swizzing_setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [self swizzing_setTextContainerInset:textContainerInset];
    self.placeHolderView.textContainerInset = self.textContainerInset;
}


- (void)setPlaceholder:(NSString *)placeholder {
    self.placeHolderTextView.text = placeholder;
}

- (NSString *)placeholder {
    return self.placeHolderTextView.text;
}


- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    self.placeHolderTextView.attributedText = attributedPlaceholder;
}

- (NSAttributedString *)attributedPlaceholder {
    return self.placeHolderTextView.attributedText;
}


- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeHolderTextView.textColor = placeholderColor;
}

- (UIColor *)placeholderColor {
    return self.placeHolderTextView.textColor;
}


- (void)setPlaceholderTextAlignment:(NSTextAlignment)placeholderTextAlignment {
    self.placeHolderTextView.textAlignment = placeholderTextAlignment;
}

- (NSTextAlignment)placeholderTextAlignment {
    return self.placeHolderTextView.textAlignment;
}


- (UITextView *)placeHolderView {
    return objc_getAssociatedObject(self, kPlaceHolderTextViewKey);
}

- (UITextView *)placeHolderTextView {
    UITextView *textView = objc_getAssociatedObject(self, kPlaceHolderTextViewKey);
    
    if (textView == nil) {
        textView = [[UITextView alloc] initWithFrame:self.frame];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
        textView.font = self.font;
        textView.textContainerInset = self.textContainerInset;
        textView.backgroundColor = [UIColor clearColor];
        textView.userInteractionEnabled = NO;
        [self addSubview:textView];
        objc_setAssociatedObject(self, kPlaceHolderTextViewKey, textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:self queue:nil usingBlock:^(NSNotification *note) {
            if (note.object == self) {
                self.placeHolderTextView.hidden = self.text.length;
            }
        }];
    }
    return textView;
}


@end
