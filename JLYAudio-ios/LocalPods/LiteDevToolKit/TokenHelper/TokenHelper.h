//
//  TokenHelper.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface TokenRequestParams : NSObject

@property (nonatomic, assign) NSUInteger validTime;      // 鉴权有效期，单位秒。默认30分钟
@property (nonatomic, copy) NSString *requestUrl;        // token请求接口url，默认https://webapi.sunclouds.com/webservice/app/v2/auth/genToken

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *uid;              // 用户uid
@property (nonatomic, copy) NSString *roomId;           // 房间号，非必须


// 获取默认对象，validTime和requestUrl使用默认值，其他参数需要单独设置
+ (instancetype)defaultParams;


@end




typedef void(^RequestTokenHandler)(BOOL success, NSString *token);


@interface TokenHelper : NSObject


// 请求Token，completionQueue使用dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
+ (void)requestTokenWithParams:(TokenRequestParams *)params completionHandler:(RequestTokenHandler)completionHandler;

+ (void)requestTokenWithParams:(TokenRequestParams *)params completionQueue:(dispatch_queue_t)completionQueue completionHandler:(RequestTokenHandler)completionHandler;


@end
