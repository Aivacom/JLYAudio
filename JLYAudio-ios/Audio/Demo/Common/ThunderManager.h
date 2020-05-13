//
//  ThunderManager.h
//  JLYAudio
//
//  Created by iPhuan on 2019/10/18.
//  Copyright © 2019 JLY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ThunderEngine.h"


typedef NS_ENUM(NSUInteger, ThunderLiveConfig) {
    ThunderLiveConfigCommunicationWithSpeechStandard = 0,          // 通话模式 16KHz采样率 18K码率/Call mode 16KHz sampling rate 18K
    ThunderLiveConfigCommunicationWithMusicStandard,               // 通话模式 44.1KHz采样率 40K码率/Call mode 44.1KHz sampling rate 40K
    ThunderLiveConfigLiveWithMusicStandard,                        // 娱乐模式 44.1KHz采样率 40K码率/Entertainment mode 44.1KHz sampling rate 40K
    ThunderLiveConfigLiveWithMusicHighQualityStero                 // 娱乐模式 44.1KHz采样率 128K码率/Entertainment mode 44.1KHz sampling rate 128K
};


@interface ThunderManager : NSObject

@property (nonatomic, readonly, strong) ThunderEngine *engine;            // SDK引擎/SDK Engine
@property (nonatomic, readonly, strong) NSString *logPath;                // 日志路径/logPath
@property (nonatomic, readonly, copy) NSString *appId;                    // AppId
@property (nonatomic, readonly, copy) NSString *localUid;                 // 本地用户uid/Local uid
@property (nonatomic, readonly, copy) NSString *roomId;                   // 房间Id/RoomId
@property (nonatomic, copy) NSString *token;                              // token
@property (nonatomic, assign) ThunderLiveConfig liveConfig;               // 开播配置/Live Configuration

@property (nonatomic, assign) BOOL hasJoinedRoom;                          // 是否已加入房间/Judge to join the room
@property (nonatomic, readonly, assign) NSUInteger selectedSoundEffectIndex;    // 已选择的音效和变声效果/Selected sound effects and voice change effects



+ (instancetype)sharedManager;

// 初始化SDK
// initialization SDK
- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate;

// 销毁SDK
// destroy SDK
- (void)destroyEngine;

// 更新用户Uid和房间Id
// Update user Uid and room Id
- (void)updateLocalUid:(NSString *)localUid roomId:(NSString *)roomId;

// 请求token
// Get token
- (void)requestTokenWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// 加入房间
// join Room
- (void)joinRoom;

// 退出房间
// leave Room
- (void)leaveRoom;

// 开启语音直播
// Audio live
- (void)enableAudioLive;

// 开启扬声器
// Operate LoudSpeaker
- (BOOL)enableLoudspeaker:(BOOL)enabled;

// 开启耳返
// Operate Ear
- (BOOL)enableEarReturn:(BOOL)enabled;

// 开启音效或者变声，两种效果只才开启一种
// Turn on the sound effect or change the sound, only one of the two effects is turned on
- (void)setSoundEffectAndVoiceChanger:(NSUInteger)mode;


// 关闭本地音频流推送
// Turn off local audio streaming
- (void)disableLocalAudio:(BOOL)disabled;

// 关闭接收远程音频流
// Turn off receiving remote audio streams
- (void)disableRemoteAudio:(NSString *)uid disabled:(BOOL)disabled;

// 恢复远程用户的音频流
// Resume audio stream from remote user
- (void)recoveryRemoteAudioStream:(NSString *)uid;

// SDK退出房间后依然会保持之前停止流的状态，所以退出房间时对所有流进行恢复
// After exiting the room, the SDK will still maintain the state of the previous stop flow, so all flows are restored when exiting the room
- (void)recoveryAllRemoteAudioStream;

// 更新token
// Update token
- (void)updateToken;



@end
