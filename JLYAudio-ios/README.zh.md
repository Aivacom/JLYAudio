使用 Thunder SDK 实现音频连麦功能
======================================

English Version： [English](README.md)

<br />

概述
-------------------------------------------------------------
本文主要介绍如何使用Thunder iOS版本SDK实现同频道音视频连麦功能，基于该场景，将对实现步骤做简要说明。
- 注意，我们只使用纯音频模式的SDK服务，所以引用SDK的时候只需要 `pod 'thunder/thunder','2.8.0' `引用子Pod即可。另外相机权限也不需要开启。

我们提供全面的用户接入文档，来方便用户实现音视频能力的快速接入，如果您想了解具体集成方法、接口说明、相关场景Demo，可点击如下链接了解：

> 集成SDK到APP，请参考：[SDK集成方法](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_ios.html)

> API开发手册，请访问： [IOS API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/iOS/v2.7.0/category.html)

> 相关Demo下载，请访问：[SDK及Demo下载](https://docs.aivacom.com/download)

<br />
   
引用API
-------------------------------------------------------------

### 方法接口

* `createEngine:sceneId:delegate:`
* `setArea:`
* `setAudioVolumeIndication:moreThanThd:lessThanThd:smooth:`
* `enableCaptureVolumeIndication:moreThanThd:lessThanThd:smooth:`
* `setLogFilePath:`
* `setLogCallback:`   

<br />

* `setMediaMode:`
* `setRoomMode:`
* `setAudioConfig:commutMode:scenarioMode:`
* `joinRoom:roomName:uid:`  

<br />

* `enableLoudspeaker:`   
* `setEnableInEarMonitor:`   
* `setSoundEffect:`   
* `setVoiceChanger:`   

<br />

* `stopLocalAudioStream:`
* `stopRemoteAudioStream:stopped:`  
* `stopAllRemoteAudioStreams:`   

<br />

* `updateToken:`   

<br />

* `leaveRoom`   

<br />

* `destroyEngine`   

<br />
<br />


### 代理接口
* `thunderEngine:onJoinRoomSuccess:withUid:elapsed:`
* `thunderEngine:onLeaveRoomWithStats:`
* `thunderEngine:onPlayVolumeIndication:totalVolume:`
* `thunderEngine:onCaptureVolumeIndication:cpt:micVolume:`
* `thunderEngine:onRemoteAudioStopped:byUid:`
* `thunderEngine:onTokenWillExpire:`
* `thunderEngineTokenRequest:`
* `thunderEngine:onUserJoined:elapsed:`
* `thunderEngine:onUserOffline:reason:`



<br />
<br />


实现步骤
-------------------------------------------------------------
（1）首先初始化SDK并创建一个`ThunderEngine`全局实例

```objective-c

    self.engine = [ThunderEngine createEngine:kThunderAppId sceneId:0 delegate:delegate];

```  

（2）初始化一些全局配置

```objective-c

    // 设置区域：默认值（国内）
    [_engine setArea:THUNDER_AREA_DEFAULT];

    // 打开用户音量回调，500毫秒回调一次
    [_engine setAudioVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];

    // 打开麦克风音量回调
    [_engine enableCaptureVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];

```

（3）加入房间，需在加入房间前根据需要配置房间属性和音频属性

```objective-c
    // 设置房间属性
    [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];     
    [_engine setRoomMode:THUNDER_ROOM_CONFIG_COMMUNICATION];
    
    // 设置音频属性
    [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_SPEECH_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];

    // 加入房间
    [_engine joinRoom:_token roomName:roomId uid:self.localUid];

```

（4）在收到加入房间成功回调后（`thunderEngine:onJoinRoomSuccess:withUid:elapsed:`），发布本地音频流

```objective-c
    
    // 每次开播默认打开，避免之前是静音状态而没有恢复
    [_engine stopLocalAudioStream:NO];
    
        
    // 默认使用扬声器和不使用耳返
    [_engine enableLoudspeaker:YES];
    [_engine setEnableInEarMonitor:NO];

```


（5）在`thunderEngine:onCaptureVolumeIndication:cpt:micVolume:`回调中可监听本地话筒音量

```objective-c

    // 设置本地音量
    self.localAudioVolumeInfo.volume = micVolume;

```


（6）在`thunderEngine:onPlayVolumeIndication:totalVolume:`回调中可以获取到当前连麦有音频流用户的列表以及他们音频的音量

```objective-c

    // 添加正在说话的人
    [self.speakers addObjectsFromArray:speakers];

```
>  注意，当前列表不是进入房间用户的列表，如果用户被静音后没有了音频流，则不会在该列表中展示。



（7）在`thunderEngine:onUserJoined:elapsed:`回调中可监听用户加入房间

（8）在`thunderEngine:onUserOffline:reason:`回调中可监听用户退出房间



（9）可以切换扬声器或者听筒模式

```objective-c

    // 开启扬声器
    [_engine enableLoudspeaker:enabled];

```

（10）可以开启耳返

```objective-c

    // 开启耳返
    [_engine setEnableInEarMonitor:enabled];

```

（11）可以关闭本地音频流或者远端用户音频流

```objective-c

    // 开关本地音频流
    [_engine stopLocalAudioStream:disabled];
    
    // 开关远端音频流
    [_engine stopRemoteAudioStream:uid stopped:disabled];

```


（12）可以设置音效或者变声

```objective-c

    // 设置音效
    [_engine setSoundEffect:THUNDER_SOUND_EFFECT_MODE_NONE];
    
    // 设置变声
    [_engine setVoiceChanger:THUNDER_VOICE_CHANGER_LORIE];

```

>  一般情况下音效或者变声我们只采用一种效果。



（13）连麦结束后离开房间

```objective-c

    [_engine leaveRoom];

```

（14）最后在收到程序要退出的通知时销毁`ThunderEngine`实例并做一些异常处理

```objective-c

    // 处理App退出时未退出房间的异常
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.engine leaveRoom];
        
        // 销毁引擎
        [ThunderEngine destroyEngine];
    }];

```

