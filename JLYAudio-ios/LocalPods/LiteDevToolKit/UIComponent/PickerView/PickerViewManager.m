//
//  PickerViewManager.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/9/28.
//


#import "PickerViewManager.h"
#import "UIColor+Additions.h"


@interface PickerViewManager ()

@end

@implementation PickerViewManager

+ (instancetype)sharedManager {
    static PickerViewManager *instance = nil;
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
    _backgroundColor = [UIColor whiteColor];
    _textColor = kColorHex(@"#3D3D3D");
    _rowHeight = 43;

}


@end
