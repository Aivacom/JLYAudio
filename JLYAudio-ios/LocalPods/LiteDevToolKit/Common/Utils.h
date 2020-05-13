//
//  Utils.h
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureDevice.h>

@class VideoCanvas;

@interface Utils : NSObject

// 生成6位Uid
+ (NSString *)generateUid;

// 生成4位房间Id
+ (NSString *)generateRoomId;

// 随机生成指定s位的数
+ (NSString *)generateRandomNumberWithDigitCount:(NSInteger)counta;


+ (NSString *)appVersion;

+ (NSString *)appBuildVersion;



#pragma mark - requestMediaAccess

// viewController为nil则不弹权限提示；请求麦克风和相机的权限，只要相机的权限有授权就认为isAvailable为可用状态
+ (void)requestMediaAccessInViewController:(UIViewController *)viewController completionHandler:(void (^)(BOOL isAvailable))handler;

// viewController为nil则不弹权限提示
+ (void)requestAccessForMediaType:(AVMediaType)mediaType viewController:(UIViewController *)viewController completionHandler:(void (^)(BOOL isAvailable))handler;

+ (void)popupMediaAccessTipsViewController:(UIViewController *)viewController ForMediaType:(AVMediaType)mediaType;


#pragma mark - Network info

// 获取网络类型，需要在使用之前调用[[AFNetworkReachabilityManager sharedManager] startMonitoring];
+ (NSString *)networkTypeSting;

// 获取蜂窝网网络类型
+ (NSString *)WANNetworkTypeSting;

+ (NSString *)carrierName;





@end
