package com.mediaroom.facade;

import android.arch.lifecycle.MutableLiveData;
import android.content.Context;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.View;

import com.mediaroom.utils.Constant;
import com.mediaroom.utils.FileUtil;
import com.mediaroom.utils.LogUtil;
import com.thunder.livesdk.LiveTranscoding;
import com.thunder.livesdk.ThunderCustomVideoSource;
import com.thunder.livesdk.ThunderEngine;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderNotification;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderRtcConstant.ThunderPublishCDNErrorCode;
import com.thunder.livesdk.ThunderVideoCanvas;
import com.thunder.livesdk.ThunderVideoEncoderConfiguration;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 *
 * Room Management Class
 *
 * ZH：
 * 房间管理控制类
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019年12月18日
 */
public class RoomManager {

    public static final String TAG = RoomManager.class.getSimpleName();

    public static final int ERROR_UN_INI = -1000;
    public static final int ERROR_DISABLE_VIDEO = -1001;
    public static final int ERROR_DISABLE_AUDIO = -1002;

    private static volatile RoomManager instance;

    private Context context;

    //The state of push stream to CDN
    //推流状态
    public volatile static Integer publishStreamToCDNStatus = null;

    //is pushing stream to CDN
    //是否正在推流
    public volatile static boolean isPublishStreamToCDN = false;

    //Whether local users join the room
    //本地用户是否加入房间
    public MutableLiveData<Boolean> isJoinRoom = new MutableLiveData<>();

    //Whether the front camera, if null means not available
    //是否前置摄像头，如果null表示不可用
    public MutableLiveData<Boolean> mIsFrontCamera = new MutableLiveData<>();

    //is Front Camera Last
    //上一次的
    public Boolean mIsFrontCameraLast = true;

    //Whether the local voice is turned off, if null means unavailable
    //本地语音是否关闭，如果null表示不可用
    public MutableLiveData<Boolean> isLocalAudioStreamStop = new MutableLiveData<>();

    //Whether the local video is closed, if null means unavailable
    //本地视频是否关闭，如果null表示不可用
    public MutableLiveData<Boolean> isLocalVidioStreamStop = new MutableLiveData<>();

    //Whether to put it outside, if null means unavailable
    //是否在外放，如果null表示不可用
    public MutableLiveData<Boolean> enableLoudspeaker = new MutableLiveData<>();

    //Whether to turn on the earback, if null means unavailable
    //是否开启耳返，如果null表示不可用
    public MutableLiveData<Boolean> enableInEarMonitor = new MutableLiveData<>();

    //current token
    //我当前的Token
    private String token;

    //current roomId
    //我当前的RoomId
    private String roomId;

    //current uid
    //我当前的UID
    private String uid;

    private List<MyThunderEventHandler> myThunderEventHandlers = new CopyOnWriteArrayList<>();

    private ThunderEngine thunderEngine = null;
    private ThunderEventHandler mThunderEventHandler = new ThunderEventHandler() {

        @Override
        public void onError(int error) {
            LogUtil.e(TAG, "onError: " + error);
        }

        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            LogUtil.d(TAG,
                    "onJoinRoomSuccess: room=" + room + " uid =" + uid + " elapsed =" + elapsed);

            mIsFrontCamera.postValue(null);
            isLocalAudioStreamStop.postValue(null);
            isLocalVidioStreamStop.postValue(null);
            isJoinRoom.postValue(true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onJoinRoomSuccess(room, uid, elapsed);
            }
        }

        @Override
        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
            LogUtil.d(TAG, "onLeaveRoom: " + status.temp);

            mIsFrontCamera.postValue(null);
            isLocalAudioStreamStop.postValue(null);
            isLocalVidioStreamStop.postValue(null);
            enableLoudspeaker.postValue(null);
            enableInEarMonitor.postValue(null);
            RoomManager.this.token = null;
            RoomManager.this.roomId = null;
            RoomManager.this.uid = null;
            isJoinRoom.postValue(false);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onLeaveRoom(status);
            }
        }

        @Override
        public void onBizAuthResult(boolean bPublish, int result) {
            LogUtil.d(TAG, "onBizAuthResult: bPublish = " + bPublish + "::::result =" + result);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onBizAuthResult(bPublish, result);
            }
        }

        @Override
        public void onSdkAuthResult(int result) {
            LogUtil.d(TAG, "onSdkAuthResult: result = " + result);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onSdkAuthResult(result);
            }
        }

        @Override
        public void onUserBanned(boolean status) {
            LogUtil.d(TAG, "onUserBanned: status = " + status);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserBanned(status);
            }
        }

        @Override
        public void onUserJoined(String uid, int elapsed) {
            LogUtil.d(TAG, "onUserJoined: uid = " + uid + "::::elapsed =" + elapsed);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserJoined(uid, elapsed);
            }
        }

        @Override
        public void onUserOffline(String uid, int reason) {
            LogUtil.d(TAG, "onUserOffline: uid = " + uid + "::::reason =" + reason);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserOffline(uid, reason);
            }
        }

        @Override
        public void onTokenWillExpire(byte[] token) {
            LogUtil.d(TAG, "onTokenWillExpire: token = " + token);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onTokenWillExpire(token);
            }
        }

        @Override
        public void onTokenRequested() {
            LogUtil.d(TAG, "onTokenRequested: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onTokenRequested();
            }
        }

        @Override
        public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
            LogUtil.d(TAG, "onNetworkQuality: uid = " + uid + ":::txQuality=" + txQuality +
                    ":::rxQuality=" + rxQuality);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onNetworkQuality(uid, txQuality, rxQuality);
            }
        }

        @Override
        public void onRoomStats(ThunderNotification.RoomStats stats) {
            LogUtil.d(TAG, "onRoomStats: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRoomStats(stats);
            }
        }

        @Override
        public void onPlayVolumeIndication(ThunderEventHandler.AudioVolumeInfo[] speakers,
                                           int totalVolume) {
            LogUtil.d(TAG, "onPlayVolumeIndication: totalVolume = " + totalVolume);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onPlayVolumeIndication(speakers, totalVolume);
            }
        }

        @Override
        public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
            LogUtil.d(TAG, "onCaptureVolumeIndication: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i)
                        .onCaptureVolumeIndication(totalVolume, cpt, micVolume);
            }
        }

        @Override
        public void onAudioQuality(String uid, int quality, short delay, short lost) {
            LogUtil.d(TAG, "onAudioQuality: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioQuality(uid, quality, delay, lost);
            }
        }

        @Override
        public void onConnectionLost() {
            LogUtil.d(TAG, "onConnectionLost: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionLost();
            }
        }

        @Override
        public void onConnectionInterrupted() {
            LogUtil.d(TAG, "onConnectionInterrupted: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionInterrupted();
            }
        }

        @Override
        public void onAudioRouteChanged(int routing) {
            LogUtil.d(TAG, "onAudioRouteChanged: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioRouteChanged(routing);
            }
        }

        @Override
        public void onAudioPlayData(byte[] data, long cpt, long pts, String uid, long duration) {
            LogUtil.d(TAG, "onAudioPlayData: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioPlayData(data, cpt, pts, uid, duration);
            }
        }

        @Override
        public void onAudioPlaySpectrumData(byte[] data) {
            LogUtil.d(TAG, "onAudioPlaySpectrumData: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioPlaySpectrumData(data);
            }
        }

        @Override
        public void onAudioCapturePcmData(byte[] data, int dataSize, int sampleRate, int channel) {
            LogUtil.d(TAG, "onAudioCapturePcmData: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i)
                        .onAudioCapturePcmData(data, dataSize, sampleRate, channel);
            }
        }

        @Override
        public void onAudioRenderPcmData(byte[] data, int dataSize, long duration, int sampleRate,
                                         int channel) {
            LogUtil.d(TAG, "onAudioRenderPcmData: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i)
                        .onAudioRenderPcmData(data, dataSize, duration, sampleRate, channel);
            }
        }

        @Override
        public void onRecvUserAppMsgData(byte[] data, String uid) {
            LogUtil.d(TAG, "onRecvUserAppMsgData: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRecvUserAppMsgData(data, uid);
            }
        }

        @Override
        public void onSendAppMsgDataFailedStatus(int status) {
            LogUtil.d(TAG, "onSendAppMsgDataFailedStatus: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onSendAppMsgDataFailedStatus(status);
            }
        }

        @Override
        public void onFirstLocalAudioFrameSent(int elapsed) {
            LogUtil.d(TAG, "onFirstLocalAudioFrameSent: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onFirstLocalAudioFrameSent(elapsed);
            }
        }

        @Override
        public void onFirstLocalVideoFrameSent(int elapsed) {
            LogUtil.d(TAG, "onFirstLocalVideoFrameSent: ");

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onFirstLocalVideoFrameSent(elapsed);
            }
        }

        @Override
        public void onPublishStreamToCDNStatus(String url, int errorCode) {
            LogUtil.d(TAG, "onPublishStreamToCDNStatus: ");

            publishStreamToCDNStatus = errorCode;
            isPublishStreamToCDN = publishStreamToCDNStatus ==
                    ThunderPublishCDNErrorCode.THUNDER_PUBLISH_CDN_ERR_SUCCESS;

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onPublishStreamToCDNStatus(url, errorCode);
            }
        }

        @Override
        public void onNetworkTypeChanged(int type) {
            LogUtil.d(TAG, "onNetworkTypeChanged: " + type);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onNetworkTypeChanged(type);
            }
        }

        @Override
        public void onConnectionStatus(int status) {
            LogUtil.d(TAG, "onConnectionStatus: " + status);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionStatus(status);
            }
        }

        @Override
        public void onAudioCaptureStatus(int status) {
            LogUtil.d(TAG, "onAudioCaptureStatus: " + status);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioCaptureStatus(status);
            }
        }

        @Override
        public void onVideoCaptureStatus(int status) {
            LogUtil.d(TAG, "onVideoCaptureStatus: " + status);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onVideoCaptureStatus(status);
            }
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            LogUtil.d(TAG, "onRemoteAudioStopped: " + "uid=" + uid + " stop=" + stop);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteAudioStopped(uid, stop);
            }
        }

        @Override
        public void onRemoteVideoStopped(String uid, boolean stop) {
            LogUtil.d(TAG, "onRemoteVideoStopped: " + "uid=" + uid + " stop=" + stop);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteVideoStopped(uid, stop);
            }
        }

        @Override
        public void onRemoteVideoPlay(String uid, int width, int height, int elapsed) {
            LogUtil.d(TAG,
                    "onRemoteVideoPlay: " + "uid=" + uid + " width=" + width + " height=" + height +
                            " elapsed=" + elapsed);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteVideoPlay(uid, width, height, elapsed);
            }
        }

        @Override
        public void onVideoSizeChanged(String uid, int width, int height, int rotation) {
            LogUtil.d(TAG,
                    "onVideoSizeChanged: " + "uid=" + uid + " width=" + width + " height=" +
                            height + " rotation=" + rotation);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onVideoSizeChanged(uid, width, height, rotation);
            }
        }
    };

    private RoomManager(Context context) {
        this.context = context;

        isJoinRoom.postValue(false);
        mIsFrontCamera.postValue(null);
        isLocalAudioStreamStop.postValue(null);
        isLocalVidioStreamStop.postValue(null);
    }

    public synchronized static RoomManager getInstance(Context context) {
        if (instance == null) {
            synchronized (RoomManager.class) {
                if (instance == null) {
                    instance = new RoomManager(context.getApplicationContext());
                }
            }
        }
        return instance;
    }

    public void register(MyThunderEventHandler myThunderEventHandler) {
        this.myThunderEventHandlers.add(myThunderEventHandler);
    }

    public void unRegister(MyThunderEventHandler myThunderEventHandler) {
        this.myThunderEventHandlers.remove(myThunderEventHandler);
    }

    /**
     * Create instance
     *
     * ZH:
     * 创建实例
     */
    public void createEngine() {
        if (thunderEngine != null) {
            return;
        }

        thunderEngine =
                ThunderEngine.createEngine(context, Constant.APPID, 0, mThunderEventHandler);

        ThunderEngine.setLogFilePath(FileUtil.getLog(context));
        //也可以自己封装日志
        // ThunderEngine.setLogCallback(new IThunderLogCallback() {
        //     @Override
        //     public void onThunderLogWithLevel(int level, String tag, String msg) {
        //
        //     }
        // });

        LogUtil.d(TAG, "createEngine");
    }

    /**
     * Destroy instance
     *
     * ZH:
     * 销毁实例
     */
    public void destroyEngine() {
        if (thunderEngine == null) {
            return;
        }

        ThunderEngine.destroyEngine();
        thunderEngine = null;
        LogUtil.d(TAG, "destroyEngine");
    }

    /**
     * Enable speaker volume prompt
     *
     * ZH:
     * 启用说话者音量提示
     */
    public int setAudioVolumeIndication() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setAudioVolumeIndication 未初始化");
            return ERROR_UN_INI;
        }

        int result = thunderEngine.setAudioVolumeIndication(500, 0, 0, 0);
        LogUtil.d(TAG, "setAudioVolumeIndication result=" + result);
        return result;
    }

    /**
     * Turn on capture volume callback
     *
     * ZH:
     * 打开采集音量回调
     */
    public int enableCaptureVolumeIndication() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "enableCaptureVolumeIndication 未初始化");
            return ERROR_UN_INI;
        }

        int result = thunderEngine.enableCaptureVolumeIndication(500, 0, 0, 0);
        LogUtil.d(TAG, "enableCaptureVolumeIndication result=" + result);
        return result;
    }

    public int setLiveTranscodingTask(String taskId, LiveTranscoding transcoding) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "joinRoom 未初始化");
            return ERROR_UN_INI;
        }

        return thunderEngine.setLiveTranscodingTask(taskId, transcoding);
    }

    /**
     * Join the room
     *
     * ZH:
     * 加入房间
     *
     */
    public int joinRoom(String token, String roomId, String uid) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "joinRoom 未初始化");
            return ERROR_UN_INI;
        }

        if (TextUtils.isEmpty(token)) {
            LogUtil.d(TAG, "joinRoom token empty");
            return ERROR_UN_INI;
        }

        if (TextUtils.isEmpty(roomId)) {
            LogUtil.d(TAG, "joinRoom roomId empty");
            return ERROR_UN_INI;
        }

        if (TextUtils.isEmpty(uid)) {
            LogUtil.d(TAG, "joinRoom uid empty");
            return ERROR_UN_INI;
        }

        this.token = token;
        this.roomId = roomId;
        this.uid = uid;
        int result = thunderEngine.joinRoom(token.getBytes(), roomId, uid);
        LogUtil.d(TAG,
                "joinRoom：" + "token=" + token + " roomId=" + roomId + " uid=" + uid + " result=" +
                        result);
        return result;
    }

    /**
     *
     * Leave the room
     *
     * ZH:
     * 离开房间
     *
     */
    public int leaveRoom() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "leaveRoom 未初始化");
            return 0;
        }

        int result = 0;
        if (isJoinRoom.getValue() == true) {
            result = thunderEngine.leaveRoom();
        }
        LogUtil.d(TAG,
                "leaveRoom：" + "roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    public String getToken() {
        return token;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getUid() {
        return uid;
    }

    /**
     * Set sdk media mode
     *
     * ZH:
     * 设置sdk媒体模式
     */
    public int setMediaMode(int mode) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setMediaMode 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG, "setMediaMode mode=" + mode);
        int result = thunderEngine.setMediaMode(mode);
        LogUtil.d(TAG, "setMediaMode result=" + result);
        return result;
    }

    /**
     * Set room scene mode
     *
     * ZH:
     * 设置房间场景模式
     */
    public int setRoomMode(int mode) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setRoomMode 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG, "setRoomMode mode=" + mode);
        int result = thunderEngine.setRoomMode(mode);
        LogUtil.d(TAG, "setRoomMode result=" + result);
        return result;
    }

    /**
     * Set audio mode
     *
     * ZH:
     * 设置音频模式
     */
    public int setAudioConfig(int profile, int commutMode, int scenarioMode) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setAudioConfig 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG, "setAudioConfig profile=" + profile + " commutMode=" + commutMode + " " +
                "scenarioMode=" + scenarioMode);
        int result = thunderEngine.setAudioConfig(profile, commutMode, scenarioMode);
        LogUtil.d(TAG, "setAudioConfig result=" + result);
        return result;
    }

    /**
     * Set local preview
     *
     * ZH:
     * 设置本地预览视图
     */
    public void setLocalVideoCanvas(View mPreviewContainer, String uid) {
        if (thunderEngine == null) {
            return;
        }

        ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS,
                uid);
        thunderEngine.setLocalVideoCanvas(mPreviewView);
        thunderEngine.setLocalCanvasScaleMode(
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS);
    }

    /**
     * Subscription across rooms
     *
     * ZH:
     * 跨房间订阅
     */
    public int addSubscribe(String roomId, String uid) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "addSubscribe 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG, "addSubscribe roomId=" + roomId + " uid=" + uid);
        int result = thunderEngine.addSubscribe(roomId, uid);
        LogUtil.d(TAG, "addSubscribe roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * unsubscribe
     *
     * ZH:
     * 取消订阅
     */
    public int removeSubscribe(String roomId, String uid) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "removeSubscribe 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG, "removeSubscribe roomId=" + roomId + " uid=" + uid);
        int result = thunderEngine.removeSubscribe(roomId, uid);
        LogUtil.d(TAG, "removeSubscribe roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * Open audio
     *
     * ZH:
     * 开启音频
     */
    public int startAudio() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "startAudio 未初始化");
            return ERROR_UN_INI;
        }

        //启用音频模块
        int result = thunderEngine.stopLocalAudioStream(false);
        if (result != 0) {
            LogUtil.d(TAG, "startAudio stopLocalAudioStream error=" + result);
            return result;
        }
        thunderEngine
                .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);
        isLocalAudioStreamStop.postValue(false);

        LogUtil.d(TAG, "startAudio result=" + result);
        return result;
    }

    /**
     * Open audio and video
     *
     * ZH:
     * 开启音视频
     */
    public int startAudioAndVideo() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "startAudioAndVideo 未初始化");
            return ERROR_UN_INI;
        }

        //start preview
        //开启预览
        int result = thunderEngine.startVideoPreview();
        if (result != 0) {
            LogUtil.d(TAG, "startAudioAndVideo startVideoPreview error=" + result);
            return result;
        }

        //Start to push local video stream
        //开始推送本地视频流
        result = thunderEngine.stopLocalVideoStream(false);
        if (result != 0) {
            LogUtil.d(TAG, "startAudioAndVideo stopLocalVideoStream error=" + result);
            return result;
        }

        //Switch to front camrea
        //切换到前置
        result = thunderEngine.switchFrontCamera(true);
        if (result != 0) {
            LogUtil.d(TAG, "startAudioAndVideo switchFrontCamera error=" + result);
            return result;
        }
        mIsFrontCamera.postValue(true);
        isLocalVidioStreamStop.postValue(false);

        //Start pushing local audio stream
        //开始推送本地音频流
        result = thunderEngine.stopLocalAudioStream(false);
        if (result != 0) {
            LogUtil.d(TAG, "startAudioAndVideo stopLocalAudioStream error=" + result);
            return result;
        }
        thunderEngine
                .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);
        isLocalAudioStreamStop.postValue(false);

        LogUtil.d(TAG, "startAudioAndVideo result=" + result);
        return result;
    }

    /**
     * Set different sound modes
     *
     * ZH:
     * 设置不同的音效模式
     *
     * @param mode
     */
    public void setSoundEffect(int mode) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setSoundEffect 未初始化");
            return;
        }

        thunderEngine.setSoundEffect(mode);
    }

    /**
     * Set voice change mode
     *
     * ZH:
     * 设置变声模式
     *
     * @param mode
     */
    public void setVoiceChanger(int mode) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setVoiceChanger 未初始化");
            return;
        }

        thunderEngine.setVoiceChanger(mode);
    }

    /**
     * Turn on or off ear monitor
     *
     * ZH:
     * 打开关闭耳返
     *
     * @return
     */
    public int setEnableInEarMonitor(boolean enabled) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setEnableInEarMonitor 未初始化");
            return 0;
        }

        LogUtil.d(TAG, "setEnableInEarMonitor enabled=" + enabled);
        int result = thunderEngine.setEnableInEarMonitor(enabled);
        if (result == 0) {
            enableInEarMonitor.postValue(enabled);
        }
        LogUtil.d(TAG, "setEnableInEarMonitor enabled=" + enabled + " result=" + result);
        return result;
    }

    /**
     * enable speaker
     *
     * ZH:
     * 设置是否外放
     *
     * @return
     */
    public int enableLoudspeaker(boolean enabled) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "enableLoudspeaker 未初始化");
            return 0;
        }

        LogUtil.d(TAG, "enableLoudspeaker enabled=" + enabled);
        int result = thunderEngine.enableLoudspeaker(enabled);
        if (result == 0) {
            enableLoudspeaker.postValue(enabled);
        }
        LogUtil.d(TAG, "enableLoudspeaker enabled=" + enabled + " result=" + result);
        return result;
    }

    /**
     * Whether speakers is playing
     *
     * ZH:
     * 是否外放
     *
     * @return
     */
    public boolean isLoudspeakerEnabled() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "isLoudspeakerEnabled 未初始化");
            return false;
        }

        boolean enabled = thunderEngine.isLoudspeakerEnabled();
        LogUtil.d(TAG, "isLoudspeakerEnabled enabled=" + enabled);
        return enabled;
    }

    /**
     * stop audio
     *
     * ZH:
     * 停止音频
     */
    public int stopAudio() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "stopAudio 未初始化");
            return 0;
        }

        if (isJoinRoom.getValue() == null || isJoinRoom.getValue() == false) {
            return 0;
        }

        //stop push audio stream
        //停止推送音频流
        int result = thunderEngine.stopLocalAudioStream(true);
        if (result != 0) {
            LogUtil.d(TAG, "stopAudio stopLocalAudioStream error=" + result);
            return result;
        }
        isLocalAudioStreamStop.postValue(true);
        LogUtil.d(TAG, "stopAudio result=" + result);
        return result;
    }

    /**
     * Receive / stop receiving specified audio stream
     *
     * ZH:
     * 接收/停止接收指定音频流
     */
    public int stopRemoteAudioStream(String uid, boolean stop) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "stopRemoteAudioStream 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG,
                "stopRemoteAudioStream uid=" + uid + " stop=" + stop);
        int result = thunderEngine.stopRemoteAudioStream(uid, stop);
        LogUtil.d(TAG, "stopRemoteAudioStream result=" + result);
        return result;
    }

    /**
     * Set video encoding configuration
     *
     * ZH:
     * 设置视频编码配置
     */
    public int setVideoEncoderConfig(ThunderVideoEncoderConfiguration configuration) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setVideoEncoderConfig 未初始化");
            return ERROR_UN_INI;
        }

        LogUtil.d(TAG,
                "setVideoEncoderConfig configuration=" + configuration);
        int result = thunderEngine.setVideoEncoderConfig(configuration);
        LogUtil.d(TAG,
                "setVideoEncoderConfig result=" + result);
        return result;
    }

    /**
     * Stop audio and video
     *
     * ZH:
     * 停止音视频
     */
    public int stopAudioAndVideo() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "stopAudioAndVideo 未初始化");
            return 0;
        }

        if (isJoinRoom.getValue() == null || isJoinRoom.getValue() == false) {
            return 0;
        }

        //Stop pushing local audio streams
        //停止推送本地音频流
        int result = thunderEngine.stopLocalAudioStream(true);
        if (result != 0) {
            LogUtil.d(TAG, "stopAudioAndVideo stopLocalAudioStream error=" + result);
            return result;
        }
        isLocalAudioStreamStop.postValue(true);

        //Stop pushing local video stream
        //停止推送本地视频流
        result = thunderEngine.stopLocalVideoStream(true);
        if (result != 0) {
            LogUtil.d(TAG, "stopAudioAndVideo stopLocalVideoStream error=" + result);
            return result;
        }

        //Close preview
        //关闭预览
        result = thunderEngine.stopVideoPreview();
        if (result != 0) {
            LogUtil.d(TAG, "stopAudioAndVideo stopVideoPreview error=" + result);
            return result;
        }

        isLocalVidioStreamStop.postValue(true);
        mIsFrontCameraLast = mIsFrontCamera.getValue();
        mIsFrontCamera.postValue(null);

        LogUtil.d(TAG, "stopAudioAndVideo result=" + result);
        return result;
    }

    /**
     * Add push address of transcode stream
     *
     * ZH:
     * 添加转码流的推流地址
     */
    public int addPublishTranscodingStreamUrl(String taskId, String url) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "addPublishTranscodingStreamUrl 未初始化");
            return ERROR_UN_INI;
        }

        isPublishStreamToCDN = true;
        return thunderEngine.addPublishTranscodingStreamUrl(taskId, url);
    }

    /**
     * Delete the push address of the transcoded stream
     *
     * ZH:
     * 删除转码流的推流地址
     */
    public int removePublishTranscodingStreamUrl(String taskId, String url) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "removePublishTranscodingStreamUrl 未初始化");
            return ERROR_UN_INI;
        }

        isPublishStreamToCDN = false;
        return thunderEngine.removePublishTranscodingStreamUrl(taskId, url);
    }

    /**
     * Front and rear camera switching
     *
     * ZH:
     * 前后摄像头切换
     */
    public int switchFrontCamera() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "switchFrontCamera 未初始化");
            return ERROR_UN_INI;
        }

        if (mIsFrontCamera.getValue() == null) {
            LogUtil.d(TAG, "switchFrontCamera 未启用");
            return ERROR_DISABLE_AUDIO;
        }

        boolean newValue = !mIsFrontCamera.getValue();
        int result = thunderEngine.switchFrontCamera(newValue);
        if (result == 0) {
            mIsFrontCamera.postValue(newValue);
        }
        LogUtil.d(TAG, "switchFrontCamera：" + "newValue=" + newValue + " result=" + result);
        return result;
    }

    /**
     * On / off local audio sending
     *
     * ZH:
     * 开/关本地音频发送
     */
    public int switchLocalAudioStreamStop() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "switchLocalAudioStreamStop 未初始化");
            return ERROR_UN_INI;
        }

        if (isLocalAudioStreamStop.getValue() == null) {
            LogUtil.d(TAG, "switchLocalAudioStreamStop 未启用Audio");
            return ERROR_DISABLE_AUDIO;
        }

        boolean newValue = !isLocalAudioStreamStop.getValue();
        int result = thunderEngine.stopLocalAudioStream(newValue);
        if (result == 0) {
            isLocalAudioStreamStop.postValue(newValue);
        }
        LogUtil.d(TAG,
                "switchLocalAudioStreamStop：" + "newValue=" + newValue + " result=" + result);
        return result;
    }

    /**
     * Set remote view
     *
     * ZH:
     * 设置远程视图
     */
    public void setRemotePlayerView(View remoteView, @NonNull String uid) {
        if (thunderEngine == null) {
            return;
        }

        ThunderVideoCanvas canvas = new ThunderVideoCanvas(remoteView,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS,
                uid);
        thunderEngine.setRemoteVideoCanvas(canvas);
        thunderEngine.setRemoteCanvasScaleMode(uid,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS);
    }

    /**
     * Set up a custom video source
     *
     * ZH:
     * 设置外部视频源
     */
    public void setCustomVideoSource(ThunderCustomVideoSource videoSource) {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "setCustomVideoSource 未初始化");
            return;
        }
        thunderEngine.setCustomVideoSource(videoSource);
    }

    public void resumeVideoPreview() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "resumeVideoPreview 未初始化");
            return;
        }

        thunderEngine.enableLocalVideoCapture(true);
        thunderEngine.startVideoPreview();
        thunderEngine.stopLocalVideoStream(false);
    }

    /**
     * Open local video capture
     *
     * ZH:
     * 打开本地视频采集
     */
    public void startLocalVidioStream() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "startLocalVidioStream 未初始化");
            return;
        }

        int result = thunderEngine.enableLocalVideoCapture(true);
        if (result != 0) {
            LogUtil.d(TAG, "startLocalVidioStream enableLocalVideoCapture error=" + result);
            return;
        }
        result = thunderEngine.startVideoPreview();
        if (result != 0) {
            LogUtil.d(TAG, "startLocalVidioStream startVideoPreview error=" + result);
            return;
        }
        result = thunderEngine.stopLocalVideoStream(false);

        if (result == 0) {
            isLocalVidioStreamStop.postValue(false);
            mIsFrontCamera.postValue(mIsFrontCameraLast);
        }

        LogUtil.d(TAG,
                "startLocalVidioStream result=" + result);
    }

    /**
     * Turn on / off local video capture
     *
     * ZH:
     * 开/关本地视频采集
     */
    public int switchLocalVidioStreamStop() {
        if (thunderEngine == null) {
            LogUtil.d(TAG, "switchLocalVidioStreamStop 未初始化");
            return ERROR_UN_INI;
        }

        if (isLocalVidioStreamStop.getValue() == null) {
            LogUtil.d(TAG, "switchLocalVidioStreamStop 未启用Video");
            return ERROR_DISABLE_VIDEO;
        }

        boolean newValue = !isLocalVidioStreamStop.getValue();
        int result = 0;
        if (newValue) {
            result = thunderEngine.enableLocalVideoCapture(false);
        } else {
            result = thunderEngine.enableLocalVideoCapture(true);
            if (result != 0) {
                LogUtil.d(TAG,
                        "switchLocalVidioStreamStop enableLocalVideoCapture error=" + result);
                return result;
            }

            result = thunderEngine.startVideoPreview();
            if (result != 0) {
                LogUtil.d(TAG, "switchLocalVidioStreamStop startVideoPreview error=" + result);
                return result;
            }

            result = thunderEngine.stopLocalVideoStream(false);
        }

        if (result == 0) {
            isLocalVidioStreamStop.postValue(newValue);

            if (newValue) {
                mIsFrontCameraLast = mIsFrontCamera.getValue();
                mIsFrontCamera.postValue(null);
            } else {
                mIsFrontCamera.postValue(mIsFrontCameraLast);
            }
        }

        LogUtil.d(TAG,
                "switchLocalVidioStreamStop：" + "newValue=" + newValue + " result=" + result);
        return result;
    }
}
