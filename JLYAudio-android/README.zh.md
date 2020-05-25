## 使用 ThunderBolt SDK 实现音视频连麦功能
*English Version: [English](README.md)*

### 概述
本文主要介绍如何使用ThunderBolt Android版本实现音视频连麦的功能，首先请确保已将ThunderBolt SDK正确集成到你的开发环境。

我们提供全面的用户接入文档，来方便用户实现音视频能力的快速接入，如果您想了解具体集成方法、接口说明、相关场景Demo，可点击如下链接了解：

> 集成SDK到APP，请参考：[SDK集成方法](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/integration_and_start/integration_and_start_android.html)

> API开发手册，请访问： [Android API](https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Android/v2.7.0/category.html)

> 相关Demo下载，请访问：[SDK及Demo下载](https://docs.aivacom.com/download)

### 实现步骤
（1）首先创建一个`IThunderEngine`实例，并进行初始化操作。

```
 thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
```

（2）加入房间。token需要参考文档从业务服务器获取。

```
thunderEngine.joinRoom(token, channelName, uid);	
```

（3）在进入房间成功后，发布本地音频流加入连麦。

```
//开播 音频
thunderEngine.stopLocalAudioStream(false);

```

（4）在 ThunderEnentHandler.onRemoteAudioStopped 中收到远端用户的音频回调通知。

```
@Override
public void onRemoteAudioStopped(String uid, boolean muted) {};
```

（5）您还可以停止发送本地音视频流，这样远端用户将听不到你的声音。

```
  thunderEngine.stopLocalAudioStream(false);
```
（6）耳返接口的使用，leaveRoom会清理为默认。

```
    thunderEngine.setEnableInEarMonitor(enable);
```
（7）音效和变声接口的使用，leaveRoom不会清理。

```
   //音效和变声逻辑，SDK内部为互斥逻辑。
   thunderEngine.setSoundEffect(mode);
   thunderEngine.setVoiceChanger(mode);
```

（8）设置是否外放和音筒模式。

```
    thunderEngine.enableLoudspeaker(enabled);
```
（9）您也可以选择不接收远端用户的音视频流。

```
  thunderEngine.stopRemoteAudioStream(uid, muted);
```

（10）连麦结束后，退出房间。

```
thunderEngine.leaveRoom();
```
