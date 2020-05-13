//
//  TokenHelper.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "TokenHelper.h"
#import "CommonMacros.h"
#import "AFNetworking.h"



static const NSUInteger kTokenValidTime = 30*60;    // 鉴权有效期，单位秒
static NSString * const kTokenRequestUrl = @"https://webapi.sunclouds.com/webservice/app/v2/auth/genToken"; // 请求token接口

@implementation TokenRequestParams

+ (instancetype)defaultParams {
    TokenRequestParams *params = [[TokenRequestParams alloc] init];
    params.validTime = kTokenValidTime;
    params.requestUrl = kTokenRequestUrl;
    return params;
}


@end




@interface TokenHelper ()

@end

@implementation TokenHelper



+ (void)requestTokenWithParams:(TokenRequestParams *)params completionHandler:(RequestTokenHandler)completionHandler {
    [self requestTokenWithParams:params completionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:completionHandler];
}

+ (void)requestTokenWithParams:(TokenRequestParams *)params completionQueue:(dispatch_queue_t)completionQueue completionHandler:(RequestTokenHandler)completionHandler {
    if (params == nil || kIsUnAvailableString(params.requestUrl) || params.validTime <= 0 || kIsUnAvailableString(params.appId) || kIsUnAvailableString(params.uid)) {
        if (completionHandler) {
            dispatch_async(completionQueue, ^{
                completionHandler(NO, nil);
            });
        }

        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.completionQueue = completionQueue;


    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 即将失效到失效的时间是30s
    [manager.requestSerializer setTimeoutInterval:20.0];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json", @"text/json", @"text/html"]];
    
    NSString *validTime = [NSString stringWithFormat:@"%lu", (unsigned long)params.validTime];
    NSMutableDictionary *parameters = [@{@"appId":params.appId, @"uid":params.uid, @"validTime":validTime} mutableCopy];
    if (params.roomId.length) {
        parameters[@"channelName"] = params.roomId;
    }
    
    // 测试服务器，业务可以根据自己的情况获取自己服务器的token
    [manager POST:kTokenRequestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        NSNumber *code = responseObject[@"code"];
        NSString *message = responseObject[@"message"];
        NSString *token = responseObject[@"object"];
        BOOL success = [responseObject[@"success"] boolValue];
        kLog(@"response json, code: %@ message: %@ token: %@ success: %@", code, message, token, success ? @"true" : @"false");
        
        if (completionHandler) {
            completionHandler(code.integerValue == 0 && token.length, token);
        }
                
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(NO, nil);
        }
    }];
}





@end

