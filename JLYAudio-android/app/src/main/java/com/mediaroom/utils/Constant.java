package com.mediaroom.utils;

import tv.athena.core.axis.Axis;
import tv.athena.crash.api.ICrashService;

public class Constant {
    public static final int STATUS_FORCE_KILLED = -1;//应用在后台被强杀（The app was killed in the background）
    public static final int STATUS_NORMAL = 2; //APP正常态（APP normal state）

    public static final String TAG = "mediaroom";
    public static final String APPID = "1470236061";
    public static final String FEEDBACK_CRASHLOGID = "JLYAudio-android";

    public static long mSceneId = 0;
    public static String mLocalUid = null;
    public static String mLocalRoomId = null;

    public static int soundEffectPostion = 0;

    /**
     * Set local UID
     *
     * ZH:
     * 设置本地UID
     *
     * @param uid
     */
    public static void setUID(String uid) {
        Constant.mLocalUid = uid;

        //Crash capture report
        //崩溃捕捉上报
        Axis.Companion.getService(ICrashService.class).config().setGUid(Constant.mLocalUid)
                .setAppId(Constant.FEEDBACK_CRASHLOGID);
    }

    /**
     * Set local room number
     *
     * ZH:
     * 设置本地房间号
     *
     * @param roomId
     */
    public static void setRoomId(String roomId) {
        Constant.mLocalRoomId = roomId;
    }
}
