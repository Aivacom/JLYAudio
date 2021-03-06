## Use ThunderBolt SDK to realize audio and video connection function
*中文版本: [简体中文](README.zh.md)*

### Overview
This article mainly introduces how to use ThunderBolt Android version to realize the function of audio and video connection. First of all, please make sure that ThunderBolt SDK is correctly integrated into your development environment.

We provide comprehensive user access documentation so that users can quickly access audio and video capabilities.If you want to know the specific integration method, interface description, and related scenario Demo, you can click the following link to learn:

> Integrate SDK to APP, please click:[SDK integration instructions](https://docs.aivacom.com/cloud/en/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_android.html)

> API development manual, please click: [Android API](https://docs.aivacom.com/cloud/en/product_category/rtc_service/rt_video_interaction/api/Android/v2.7.0/category.html)

> For related Demo download, please click: [SDK and Demo Download](https://docs.aivacom.com/en/download)

### Implementation steps
（1）Create an instance of `IThunderEngine` and initialize it.

```
 thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
```

（2）Join the room. The token needs to be obtained from the business server by referring to the documentation.

```
thunderEngine.joinRoom(token, channelName, uid);	
```

（3）After entering the room successfully, publish the local audio stream to audio connection.

```
//start push audio stream
thunderEngine.stopLocalAudioStream(false);

```

（4）Receive audio callback from remote user in ThunderEnentHandler.onRemoteAudioStopped method.

```
@Override
public void onRemoteAudioStopped(String uid, boolean muted) {};
```

（5）You can also stop sending local audio and video streams so that other users will not hear your voice.

```
  thunderEngine.stopLocalAudioStream(false);
```
（6）The use of the earback interface will be cleared as the default setting after leaveRoom.

```
    thunderEngine.setEnableInEarMonitor(enable);
```
（7）The use of sound effects interface and voice change interface will not clean up after leaveRoom.

```
   //The sound effect and voice change logic are mutually exclusive logic inside the SDK.
   thunderEngine.setSoundEffect(mode);
   thunderEngine.setVoiceChanger(mode);
```

（8）Set whether to put out and sound tube mode.

```
    thunderEngine.enableLoudspeaker(enabled);
```
（9）You can also choose not to receive audio and video streams from remote users.

```
  thunderEngine.stopRemoteAudioStream(uid, muted);
```

（10）After audio connection ended, exit the room.

```
thunderEngine.leaveRoom();
```
