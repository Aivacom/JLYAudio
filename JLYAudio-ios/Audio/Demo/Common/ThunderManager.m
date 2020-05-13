//
//  ThunderManager.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/18.
//  Copyright © 2019 JLY. All rights reserved.
//


#import "ThunderManager.h"
#import "Utils.h"
#import "TokenHelper.h"
#import "CommonMacros.h"


static NSString * const kThunderAppId = @"1470236061"; // SDK AppID


@interface ThunderManager () <ThunderRtcLogDelegate>
@property (nonatomic, readwrite, strong) ThunderEngine *engine;
@property (nonatomic, readwrite, strong) NSString *logPath;
@property (nonatomic, readwrite, copy) NSString *localUid;          
@property (nonatomic, readwrite, copy) NSString *roomId;
@property (nonatomic, readwrite, assign) NSUInteger selectedSoundEffectIndex;    // 已选择的音效和变声效果/Selected sound effects and voice change effects


@end

@implementation ThunderManager

+ (instancetype)sharedManager {
    static ThunderManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认通话模式 44.1KHz采样率 40K码率
        // Default call mode 44.1KHz sampling rate 40K
        _liveConfig = ThunderLiveConfigCommunicationWithMusicStandard;
        _selectedSoundEffectIndex = 0;
    }
    return self;
}


#pragma mark - Public

- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate {
    self.engine = [ThunderEngine createEngine:kThunderAppId sceneId:0 delegate:delegate];
    
    // 设置区域：默认值（国内）
    // Set area: Default value(domestic)
    [_engine setArea:THUNDER_AREA_DEFAULT];

    // 打开用户音量回调，500毫秒回调一次
    // Turn on user volume callback, once every 500 milliseconds
    [_engine setAudioVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];
    
    // 打开麦克风音量回调
    // Turn on microphone volume callback
    [_engine enableCaptureVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];

    // 处理App退出时未退出房间的异常
    // Handle the exception of not exiting the room when the app exits
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.engine leaveRoom];
        
        // 销毁引擎
        // Destroy engine
        [ThunderEngine destroyEngine];
    }];
    
    // 设置SDK日志存储路径
    // Set SDK log storage path
    NSString* logPath = NSHomeDirectory();
    self.logPath = [logPath stringByAppendingString:@"/Documents/Log/Thunder"];
    [_engine setLogFilePath: _logPath];
    
    // Debug模式下直接打印日志
    // Print logs directly in Debug mode
#ifdef DEBUG
    [_engine setLogCallback:self];
#endif

}

- (void)destroyEngine {
    // 销毁引擎
    // Destroy engine
    [ThunderEngine destroyEngine];
}



- (void)updateLocalUid:(NSString *)localUid roomId:(NSString *)roomId {
    self.localUid = localUid;
    self.roomId = roomId;
}



- (void)requestTokenWithCompletionHandler:(void (^)(BOOL success))completionHandler {
    TokenRequestParams *params = [TokenRequestParams defaultParams];
    params.appId = self.appId;
    params.uid = _localUid;
    params.roomId = _roomId;
    
    [TokenHelper requestTokenWithParams:params completionQueue:dispatch_get_main_queue() completionHandler:^(BOOL success, NSString *token) {
        if (token.length > 0) {
            self.token = token;
        }
        
        if (completionHandler) {
            completionHandler(success);
        }
    }];
}



- (void)joinRoom {
    // 设置纯音频模式，并配置房间和音频相关参数
    // Set audio-only mode and configure room and audio related parameters
    [self setupliveConfig];
    
    // 加入房间
    // Join room
    [_engine joinRoom:_token roomName:_roomId uid:_localUid];
}


- (void)setupliveConfig {
    switch (_liveConfig) {
        case ThunderLiveConfigCommunicationWithSpeechStandard:
            // 设置房间属性
            // Set room config
            [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];     
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_COMMUNICATION];
            
            // 设置音频属性
            // set audio Config
            [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_SPEECH_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];

            break;
        case ThunderLiveConfigCommunicationWithMusicStandard:
            [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_COMMUNICATION];
            
            [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];

            break;
        case ThunderLiveConfigLiveWithMusicStandard:
            [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_LIVE];
            
            [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            
            break;
        case ThunderLiveConfigLiveWithMusicHighQualityStero:
            [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_LIVE];
            
            [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];
            
            break;
    }
}


- (void)leaveRoom {
    [_engine leaveRoom];
}

- (void)enableAudioLive {
    // 推送本地音频流
    // Push local audio streams
    [_engine stopLocalAudioStream:NO];
    
    // 默认使用扬声器和不使用耳返
    // Use speaker by default and don't use ear
    [_engine enableLoudspeaker:YES];
    [_engine setEnableInEarMonitor:NO];
}

- (BOOL)enableLoudspeaker:(BOOL)enabled {
    // 开启扬声器
    // On or off Speaker
    return [_engine enableLoudspeaker:enabled] == 0;
}

- (BOOL)enableEarReturn:(BOOL)enabled {
    // 开启耳返
    // On or off Ear
    return [_engine setEnableInEarMonitor:enabled] == 0;
}


- (void)setSoundEffectAndVoiceChanger:(NSUInteger)mode {
    _selectedSoundEffectIndex = mode;
    if (mode == 0) {
        // 设置音效
        // Set sound effects
        [_engine setSoundEffect:THUNDER_SOUND_EFFECT_MODE_NONE];
        // 设置变声
        // Set voice change
        [_engine setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
    } else if (mode < 10) {
        [_engine setSoundEffect:(int32_t)mode];
        [_engine setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
    } else if (mode >= 10) {
        [_engine setSoundEffect:THUNDER_SOUND_EFFECT_MODE_NONE];
        [_engine setVoiceChanger:(int32_t)(mode - 9)];
    }

}


- (void)disableLocalAudio:(BOOL)disabled {
    // 开关本地音频流
    // On or off local Audio Stream
    [_engine stopLocalAudioStream:disabled];
    
}

- (void)disableRemoteAudio:(NSString *)uid disabled:(BOOL)disabled {
    // 开关远端音频流
    // On or off Remote Audio Stream
    [_engine stopRemoteAudioStream:uid stopped:disabled];
}

- (void)recoveryRemoteAudioStream:(NSString *)uid {
    [_engine stopRemoteAudioStream:uid stopped:NO];
}

- (void)recoveryAllRemoteAudioStream {
    // 关闭的流进行恢复
    // Closed stream for recovery
    [_engine stopAllRemoteAudioStreams:YES]; // 为了让下面的stopAllRemoteVideoStreams生效/In order for the following stopAllRemoteVideoStreams to take effect
    [_engine stopAllRemoteAudioStreams:NO];
}


- (void)updateToken {
    [_engine updateToken:_token];
}


#pragma mark - ThunderRtcLogDelegate

- (void)onThunderRtcLogWithLevel:(ThunderRtcLogLevel)level message:(nonnull NSString*)msg {
    kLog(@"【RTC】level=%ld, %@", (long)level, msg);
}


#pragma mark - Get and Set

- (NSString *)appId {
    return kThunderAppId;
}

- (NSString *)localUid {
    if (_localUid == nil) {
        _localUid = [Utils generateUid];
    }
    
    return _localUid;
}


@end
