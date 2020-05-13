//
//  FeedbackRequestHelper.m
//  FeedbackComponent
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "FeedbackRequestHelper.h"
#import "SSZipArchive.h"
#import <AFNetworking/AFNetworking.h>
#import "CommonMacros.h"
#import "Utils.h"
#import "FeedbackManager.h"



@interface FeedbackRequestHelper ()

@end

@implementation FeedbackRequestHelper

+ (void)requestWithFeedbackContent:(NSString *)content uid:(NSString *)uid success:(RequestSuccessedBlock)success failure:(RequestFailedBlock)failure {
    
    FeedbackManager *feedbackManager = [FeedbackManager sharedManager];
    if (kIsUnAvailableString(feedbackManager.appId) || kIsUnAvailableString(uid)) {
        if (failure) {
            failure(RequestFailedReasonMissingParameter);
        }
        return;
    }
    
    
    NSString *logFile = feedbackManager.logFilePath;
    
    // 创建临时文件
    NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"feedback.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:logFile]) {
        
        BOOL isSuccess = NO;
        if ([self isDirectory:logFile]) {
            isSuccess = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:logFile];
        } else {
            NSArray *files = @[logFile];
            isSuccess = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:files];
        }
        
        if (!isSuccess) {
            if (failure) {
                failure(RequestFailedReasonZipArchiveFailed);
            }
            return;
        }
    }
    
    
    NSString *uploadContent = content;
    if (uploadContent.length == 0) {
        uploadContent = uid;
    }
    
    NSString *networkState = [Utils networkTypeSting];
    NSString *marketChannel = feedbackManager.marketChannel;
    NSString *serviceProvider = [Utils carrierName];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *guid = @"";
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSString *reportType = @"UFB";
    NSString *deviceName = [[UIDevice currentDevice] systemName];
    NSString *contact = @"";
    
    
    // data
    NSDictionary *dataDict = @{
                               @"feedback" : uploadContent,
                               @"uid" : uid,
                               @"networkState" : networkState,
                               @"marketChannel" : marketChannel,
                               @"serviceProvider" : serviceProvider,
                               @"productVer" : appVersion,
                               @"guid" : guid,
                               @"osVer" : systemVersion,
                               @"reportType" : reportType,
                               @"phoneType" : deviceName,
                               @"contactInfo" : contact
                               };
    
    // post data
    NSString *postData = [NSString
                          stringWithFormat:@"{\"appId\":\"%@\",\"sign\":\"\",\"data\":%@}", feedbackManager.appId, [self jsonStringFromObject:dataDict]];
    
    kLog(@"feedback post data:%@", postData);
    
    void (^multipartFormBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        // 上传日志文件
        [formData appendPartWithFormData:[postData dataUsingEncoding:NSUTF8StringEncoding] name:@"nyy"];
        
        if (zipPath) {
            NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
            if (zipData == nil || zipData.length == 0) {
                return;
            }
            
            [formData appendPartWithFileData:zipData
                                        name:@"file"
                                    fileName:@"sylog.zip"
                                    mimeType:@"multipart/form-data"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath isDirectory:nil]) {
                [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
            }
        }
    };
    
    [[AFHTTPSessionManager manager] POST:feedbackManager.requestUrl parameters:nil constructingBodyWithBlock:multipartFormBlock progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
        
        if (statusCode == 204 || statusCode == 206) {
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure(RequestFailedReasonRequestFailed);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(RequestFailedReasonRequestFailed);
        }
    }];
}

+ (BOOL)isDirectory:(NSString *)filePath {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}


+ (NSString *)jsonStringFromObject:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        kLog(@"object to json faile, object: %@, error: %@", object, error.localizedDescription);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end

