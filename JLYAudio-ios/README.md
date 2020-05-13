Use Thunder SDK to realize audio link function
======================================

中文版本：[简体中文](README.zh.md)

<br />

Overview
-------------------------------------------------------------
- This article mainly introduces how to use Thunder The iOS version SDK implements the same channel audio and video functions. Based on this scenario, the implementation steps will be briefly explained. 
- Note that we only use the SDK service in audio-only mode, so you only need to refer to the child Pod with `pod 'thunder / thunder', '2.8.0'` when referencing the SDK. In addition, camera permissions do not need to be turned on.

<br />
   
Reference API
-------------------------------------------------------------

### Method interface

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


### Delegate
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


Implementation steps
-------------------------------------------------------------
（1）First initialize the SDK and create a global instance of `ThunderEngine`

```objective-c

    self.engine = [ThunderEngine createEngine:kThunderAppId sceneId:0 delegate:delegate];

```  

（2）Initialize some global configuration

```objective-c

    // Setting area: default value (domestic)
    [_engine setArea:THUNDER_AREA_DEFAULT];

    // Turn on user volume callback, once every 500 milliseconds
    [_engine setAudioVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];

    // Turn on microphone volume callback
    [_engine enableCaptureVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];

```

（3）To join a room, you need to configure room properties and audio properties as needed before joining the room

```objective-c
    // Set room properties
    [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];     
    [_engine setRoomMode:THUNDER_ROOM_CONFIG_COMMUNICATION];
    
    // Set audio properties
    [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_SPEECH_STANDARD commutMode:THUNDER_COMMUT_MODE_HIGH scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];

    // Join room
    [_engine joinRoom:_token roomName:roomId uid:self.localUid];

```

（4）After receiving the successful callback to join the room (`thunderEngine: onJoinRoomSuccess: withUid: elapsed:`), publish the local audio stream

```objective-c
    
    // Push local audio stream
    [_engine stopLocalAudioStream:NO];
    
    // Use speaker by default and don't use ear return
    [_engine enableLoudspeaker:YES];
    [_engine setEnableInEarMonitor:NO];

```


（5）You can monitor the local microphone volume in the `thunderEngine: onCaptureVolumeIndication: cpt: micVolume:` callback

```objective-c

    // Set local volume
    self.localAudioVolumeInfo.volume = micVolume;

```


（6）In the `thunderEngine: onPlayVolumeIndication: totalVolume:` callback, you can get the list of users who currently have audio streams and their audio volume

```objective-c

    // add speakers
    [self.speakers addObjectsFromArray:speakers];

```
>  Note that the current list is not a list of users who entered the room. If the user is muted and there is no audio stream, it will not be displayed in this list.



（7）In the `thunderEngine: onUserJoined: elapsed:` callback, you can listen for the user to join the room

（8）In the `thunderEngine: onUserOffline: reason:` callback, you can monitor the user exiting the room



（9）Can switch between speaker or handset mode

```objective-c

    // On or off speaker
    [_engine enableLoudspeaker:enabled];

```

（10）Turn on the ear

```objective-c

    // On or off ear
    [_engine setEnableInEarMonitor:enabled];

```

（11）Can change the local audio stream or remote user audio stream

```objective-c

    // Switch local audio stream
    [_engine stopLocalAudioStream:disabled];
    
    // Switch remote audio stream
    [_engine stopRemoteAudioStream:uid stopped:disabled];

```


（12）Can set sound effects or change voice

```objective-c

    // Set sound effects
    [_engine setSoundEffect:THUNDER_SOUND_EFFECT_MODE_NONE];
    
    // Set voice change
    [_engine setVoiceChanger:THUNDER_VOICE_CHANGER_LORIE];

```

>  In general, we only use one effect for sound effect or voice change.



（13）Left the room after the live video call end

```objective-c

    [_engine leaveRoom];

```

（14）Finally, upon receiving the notification that the program wants to exit, destroy the `ThunderEngine` instance and do some exception handling

```objective-c

    // Handle the exception of not exiting the room when the app exits
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.engine leaveRoom];
        
        // Destroy engine
        [ThunderEngine destroyEngine];
    }];

```

