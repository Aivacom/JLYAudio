//
//  FeedbackManager.h
//  FeedbackComponent
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface FeedbackManager : NSObject

@property (nonatomic, copy) NSString *requestUrl;   // 接口请求地址，默认https://isoda-inforeceiver.yy.com/userFeedback
@property (nonatomic, copy) NSString *marketChannel;  // 市场渠道，默认值Demo
@property (nonatomic, copy) NSString *submitButtonNormalHexColor;        // 提交按钮正常颜色，默认值#6485F9
@property (nonatomic, copy) NSString *submitButtonhighlightedHexColor;   // 提交按钮高亮颜色，默认值#3A61ED

@property (nonatomic, copy) NSString *appId;         // 意见反馈对接系统AppId，必须设置
@property (nonatomic, copy) NSString *logFilePath;   // log日志存储路径
@property (nonatomic, copy) NSString *appSceneName;  // 用于区分场景的app名称
@property (nonatomic, copy) NSString *functionDesc;  // app功能描述


+ (instancetype)sharedManager;


@end
