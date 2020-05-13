//
//  Utils.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "Utils.h"
#import "AFNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "UIViewController+AlertController.h"
#include "math.h"



@interface Utils ()

@end

@implementation Utils

+ (NSString *)generateUid {
//    NSUInteger num = 999999 - 100000 + 1;
//    NSUInteger uidNumber = (NSUInteger)(100000 + (arc4random() % num));
//    return [NSString stringWithFormat:@"%lu", (unsigned long)uidNumber];
    return [self generateRandomNumberWithDigitCount:6];
}

+ (NSString *)generateRoomId {
    return [self generateRandomNumberWithDigitCount:4];
}

+ (NSString *)generateRandomNumberWithDigitCount:(NSInteger)count {
    NSUInteger num = pow(10, count) - 1 - pow(10, count - 1) + 1;
    NSUInteger uidNumber = (NSUInteger)(pow(10, count - 1) + (arc4random() % num));
    return [NSString stringWithFormat:@"%lu", (unsigned long)uidNumber];
}

+ (NSString *)appVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return infoDic[@"CFBundleShortVersionString"];
}


+ (NSString *)appBuildVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    return infoDic[@"CFBundleVersion"];
}


#pragma mark - requestMediaAccess


+ (void)requestMediaAccessInViewController:(UIViewController *)viewController completionHandler:(void (^)(BOOL isAvailable))handler {
    [self requestAccessForMediaType:AVMediaTypeAudio viewController:viewController completionHandler:nil];
    [self requestAccessForMediaType:AVMediaTypeVideo viewController:viewController completionHandler:handler];
}

+ (void)requestAccessForMediaType:(AVMediaType)mediaType viewController:(UIViewController *)viewController completionHandler:(void (^)(BOOL isAvailable))handler {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (viewController && !granted) {
                    [self popupMediaAccessTipsViewController:viewController ForMediaType:mediaType];
                }
                
                if (handler) {
                    handler(granted);
                }
            });
        }];
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        if (viewController) {
            [self popupMediaAccessTipsViewController:viewController ForMediaType:mediaType];
        }
        
        if (handler) {
            handler(NO);
        }
    } else {
        if (handler) {
            handler(YES);
        }
    }
}


+ (void)popupMediaAccessTipsViewController:(UIViewController *)viewController ForMediaType:(AVMediaType)mediaType {
    // 支持弹两窗
    UIViewController *vc = viewController;
    if (viewController.presentedViewController) {
        vc = viewController.presentedViewController;
    }
    
    if (mediaType == AVMediaTypeAudio) {
        [vc popupAlertViewWithMessage:@"您没有开启麦克风权限， 将无法进行语音通话，请在设备的“设置-隐私-麦克风”选项中开启麦克风权限。"];
    } else if (mediaType == AVMediaTypeVideo) {
        [vc popupAlertViewWithMessage:@"您没有开启相机权限， 将无法进行视频通话，请在设备的“设置-隐私-相机”选项中开启相机权限。"];
    }
}




#pragma mark - Network info

+ (NSString *)networkTypeSting {
    AFNetworkReachabilityStatus networkReachabilityStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    switch (networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown:
            return @"unknown";
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return @"noNetwork";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return [self WANNetworkTypeSting];
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"wifi";
            break;
    }
    
    return @"unknown";
}

+ (NSString *)WANNetworkTypeSting {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *networkType = @"unknown";
    if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
        NSString *currentStatus = info.currentRadioAccessTechnology;
        NSArray *network2G = @[CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x];
        NSArray *network3G = @[CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD];
        NSArray *network4G = @[CTRadioAccessTechnologyLTE];
        
        if ([network2G containsObject:currentStatus]) {
            networkType = @"2g";
        }else if ([network3G containsObject:currentStatus]) {
            networkType = @"3g";
        }else if ([network4G containsObject:currentStatus]){
            networkType = @"4g";
        }else {
            networkType = @"unknown";
        }
    }
    return networkType;
}

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *code = carrier.mobileNetworkCode;
    if (code == nil) {
        return @"nosp";
    } else if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        return @"chinamobile";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        return @"chinaunicom";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        return @"chinatelecom";
    } else if ([code isEqualToString:@"20"]) {
        return @"chinatietong";
    }
    
    return @"";
}





@end


