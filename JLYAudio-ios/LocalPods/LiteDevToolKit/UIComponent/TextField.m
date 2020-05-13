//
//  TextField.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "TextField.h"


@interface TextField ()

@end

@implementation TextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _canPerformAction = YES;
        _canPaste = YES;
        [self addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_canPerformAction) {
        if (action == @selector(paste:)) {
            return _canPaste;
        }
        return [super canPerformAction:action withSender:sender];
    } else {
        return NO;
    }

    return YES;
}


- (void)textFieldEditingChanged {
    if (self.maxInputLength && self.text.length > self.maxInputLength) {
        self.text = [self.text substringToIndex:self.maxInputLength];
    }
}



@end
