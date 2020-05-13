//
//  FeedbackRequestHelper.h
//  FeedbackComponent
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RequestFailedReason) {
    RequestFailedReasonZipArchiveFailed = 0,
    RequestFailedReasonRequestFailed,
    RequestFailedReasonMissingParameter
};

typedef void (^RequestSuccessedBlock)(void);
typedef void (^RequestFailedBlock)(RequestFailedReason failedReason);


@interface FeedbackRequestHelper : NSObject

+ (void)requestWithFeedbackContent:(NSString *)content uid:(NSString *)uid success:(RequestSuccessedBlock)success failure:(RequestFailedBlock)failure;


@end
