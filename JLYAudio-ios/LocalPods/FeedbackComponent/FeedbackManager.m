//
//  FeedbackManager.m
//  FeedbackComponent
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "FeedbackManager.h"

static NSString * const kFeedbackRequestUrl = @"https://isoda-inforeceiver.yy.com/userFeedback"; // 反馈接口URL


@interface FeedbackManager ()

@end

@implementation FeedbackManager

+ (instancetype)sharedManager {
    static FeedbackManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultValue];
    }
    return self;
}

- (void)setupDefaultValue {
    self.requestUrl = kFeedbackRequestUrl;
    self.marketChannel = @"Demo";
    self.submitButtonNormalHexColor = @"#6485F9";
    self.submitButtonhighlightedHexColor = @"#3A61ED";
}



@end
