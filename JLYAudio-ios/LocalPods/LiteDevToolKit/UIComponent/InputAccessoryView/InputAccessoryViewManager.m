/*
 ***********************************************************************************
 *
 *  File     : InputAccessoryViewManager.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/11/15.
 ***********************************************************************************
 */

#import "InputAccessoryViewManager.h"
#import "UIColor+Additions.h"


@interface InputAccessoryViewManager ()

@end

@implementation InputAccessoryViewManager

+ (instancetype)sharedManager {
    static InputAccessoryViewManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_setup];
    }
    return self;
}

- (void)p_setup {
    _backgroundColor = kColorHex(@"#F2F2F2");
    _cancelButtonTitle = @"取消";
    _cancelButtonTitleColor = kColorHex(@"#999999");
    _cancelButtonFont = [UIFont systemFontOfSize:14];
    
    _confirmButtonTitle = @"确定";
    _confirmButtonTitleColor = kColorHex(@"#3D3D3D");
    _confirmButtonFont = [UIFont systemFontOfSize:14];
    
    _titleLabelTextColor = kColorHex(@"#3D3D3D");
    _titleLabelFont = [UIFont systemFontOfSize:17];
    
    _separatorLineBackgroundColor = kColorHex(@"#F9F9F9");
}

@end
