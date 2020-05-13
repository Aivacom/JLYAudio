package com.mediaroom.ui;

import android.Manifest;
import android.arch.lifecycle.Observer;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.OrientationHelper;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;

import com.mediaroom.R;
import com.mediaroom.adapter.RoomAdapter;
import com.mediaroom.base.DataBindBaseActivity;
import com.mediaroom.bean.UserInfo;
import com.mediaroom.data.BaseError;
import com.mediaroom.data.DataRepository;
import com.mediaroom.data.HttpItemCallback;
import com.mediaroom.databinding.ActivityMainBinding;
import com.mediaroom.facade.MyThunderEventHandler;
import com.mediaroom.facade.RoomManager;
import com.mediaroom.utils.Constant;
import com.mediaroom.utils.LogUtil;
import com.mediaroom.utils.PermissionUtils;
import com.thunder.livesdk.ThunderRtcConstant;

import java.util.Arrays;
import java.util.Random;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 *
 * Homepage
 *
 * ZH:
 * 首页
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019年12月18日
 */
public class MainActivity extends DataBindBaseActivity<ActivityMainBinding>
        implements View.OnClickListener {

    private int roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_COMMUNICATION;
    private int profile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;

    private RoomAdapter adapter;

    private MyThunderEventHandler myThunderEventHandler = new MyThunderEventHandler() {
        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            super.onJoinRoomSuccess(room, uid, elapsed);
            dissMissDialogProgress();

            onJoinRoomStatus();
            startPlay();
        }

        @Override
        public void onLeaveRoom(RoomStats status) {
            super.onLeaveRoom(status);
            dissMissDialogProgress();

            onUnJoinRoomStatus();
        }

        @Override
        public void onUserJoined(String uid, int elapsed) {
            super.onUserJoined(uid, elapsed);

            UserInfo userInfo = adapter.getUserInfo(uid);
            if (userInfo == null) {
                userInfo = new UserInfo(uid);
                adapter.addItem(userInfo);
            }
        }

        @Override
        public void onUserOffline(String uid, int reason) {
            super.onUserOffline(uid, reason);

            UserInfo userInfo = adapter.getUserInfo(uid);
            if (userInfo != null) {
                adapter.deleteItem(userInfo);

                //Restore operation
                //还原操作
                RoomManager.getInstance(MainActivity.this).stopRemoteAudioStream(uid, false);
            }
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            super.onRemoteAudioStopped(uid, stop);

            UserInfo userInfo = adapter.getUserInfo(uid);
            if (stop) {
                if (userInfo != null) {
                    userInfo.setAudioStreamStopped(stop);
                    int index = adapter.indexOf(userInfo);
                    adapter.updateItem(index, userInfo);
                }
            } else {
                if (userInfo != null) {
                    userInfo.setAudioStreamStopped(stop);
                    int index = adapter.indexOf(userInfo);
                    adapter.updateItem(index, userInfo);
                } else {
                    userInfo = new UserInfo(uid);
                    userInfo.setAudioStreamStopped(stop);
                    adapter.addItem(userInfo);
                }
            }
        }

        @Override
        public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
            super.onCaptureVolumeIndication(totalVolume, cpt, micVolume);

            String uid = RoomManager.getInstance(MainActivity.this).getUid();
            UserInfo userInfo = adapter.getUserInfo(uid);
            if (userInfo != null) {
                userInfo.onCaptureVolumeIndication(totalVolume, cpt, micVolume);
                int index = adapter.indexOf(userInfo);
                adapter.updateItem(index, userInfo);
            }
        }

        @Override
        public void onPlayVolumeIndication(AudioVolumeInfo[] speakers, int totalVolume) {
            super.onPlayVolumeIndication(speakers, totalVolume);

            for (AudioVolumeInfo speaker : speakers) {
                String uid = speaker.uid;
                UserInfo userInfo = adapter.getUserInfo(uid);
                if (userInfo != null) {
                    userInfo.onPlayVolumeIndication(speaker);

                    int index = adapter.indexOf(userInfo);
                    adapter.updateItem(index, userInfo);
                } else {
                    userInfo = new UserInfo(uid);
                    userInfo.setAudioStreamStopped(false);
                    adapter.addItem(userInfo);
                }
            }
        }
    };

    private String[] permissions = new String[]{Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE};

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    protected void initView() {
        mDataBinding.btnJoinRoom.setOnClickListener(this);
        mDataBinding.tvSelect.setOnClickListener(this);
        mDataBinding.ivEnableLoud.setOnClickListener(this);
        mDataBinding.ivEarMonitor.setOnClickListener(this);
        mDataBinding.ivSoundEffect.setOnClickListener(this);
        mDataBinding.ivFeedback.setOnClickListener(this);

        adapter = new RoomAdapter(new CopyOnWriteArrayList<>(), this);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setOrientation(OrientationHelper.VERTICAL);
        mDataBinding.recyclerView.setLayoutManager(layoutManager);
        DividerItemDecoration itemDecoration =
                new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        itemDecoration
                .setDrawable(new ColorDrawable(ContextCompat.getColor(this, R.color.bg_grey)));
        mDataBinding.recyclerView.addItemDecoration(itemDecoration);
        mDataBinding.recyclerView.setAdapter(adapter);
        mDataBinding.recyclerView.setItemAnimator(new DefaultItemAnimator());
        adapter.setOnItemClickListener((view, position) -> {
            UserInfo userInfo = adapter.getData().get(position);
            if (view.getId() == R.id.item_iv_volume) {
                onItemVolumeClick(position, userInfo);
            } else {

            }
        });

        mDataBinding.edittextLocalRoomid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (TextUtils
                        .isEmpty(mDataBinding.edittextLocalRoomid.getText().toString().trim())
                        || TextUtils
                        .isEmpty(mDataBinding.edittextLocalUid.getText().toString().trim())) {
                    mDataBinding.btnJoinRoom.showDisableStatus();
                } else {
                    mDataBinding.btnJoinRoom.showOpenStatus();
                }
            }
        });

        mDataBinding.edittextLocalUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (TextUtils
                        .isEmpty(mDataBinding.edittextLocalRoomid.getText().toString().trim())
                        || TextUtils
                        .isEmpty(mDataBinding.edittextLocalUid.getText().toString().trim())) {
                    mDataBinding.btnJoinRoom.showDisableStatus();
                } else {
                    mDataBinding.btnJoinRoom.showOpenStatus();
                }
            }
        });
    }

    @Override
    protected void initData() {
        PermissionUtils.checkAndRequestMorePermissions(MainActivity.this, permissions,
                PermissionUtils.REQUEST_CODE_PERMISSIONS,
                () -> LogUtil.v(Constant.TAG, "已授予权限"));

        onUnJoinRoomStatus();
        setInfo();

        monitorLoudspeaker();
        monitorEarMonitor();

        //Set default
        //设置默认值
        String[] datas = getResources().getStringArray(R.array.mode);
        mDataBinding.tvSelect.setText(datas[1]);
        roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_COMMUNICATION;
        profile =
                ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;

        //initial
        //初始化
        RoomManager.getInstance(this).register(myThunderEventHandler);
        RoomManager.getInstance(MainActivity.this).createEngine();
        RoomManager.getInstance(this).setAudioVolumeIndication();
        RoomManager.getInstance(this).enableCaptureVolumeIndication();

        //Set sdk media mode
        //Pure voice mode (recommended for use without video scenes, for better audio performance)
        //设置sdk媒体模式
        //纯语音模式(无视频场景建议使用，获取更佳音频性能)
        RoomManager.getInstance(MainActivity.this)
                .setMediaMode(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_ONLY_AUDIO);

        //Set room scene mode
        //设置房间场景模式
        RoomManager.getInstance(MainActivity.this).setRoomMode(roomMode);

        //Set audio configuration
        //设置音频配置
        RoomManager.getInstance(MainActivity.this)
                .setAudioConfig(profile, ThunderRtcConstant.CommutMode.THUNDER_COMMUT_MODE_HIGH,
                        ThunderRtcConstant.ScenarioMode.THUNDER_SCENARIO_MODE_DEFAULT);
    }

    private void setInfo() {
        //Set UID
        //设置UID
        String uid = String.valueOf(new Random().nextInt(899999) + 100000);
        Constant.setUID(uid);
        mDataBinding.edittextLocalUid.setText(uid);
    }

    /**
     * Whether the monitor uses speakers
     *
     * ZH:
     * 监控是否外放
     */
    private void monitorLoudspeaker() {
        RoomManager.getInstance(this).enableLoudspeaker.observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(@Nullable Boolean aBoolean) {
                if (aBoolean == null) {
                    mDataBinding.ivEnableLoud.setEnabled(false);
                } else if (aBoolean == true) {
                    mDataBinding.ivEnableLoud.setEnabled(true);
                    mDataBinding.ivEnableLoud.setImageResource(R.drawable.ic_speak_unselected);
                } else if (aBoolean == false) {
                    mDataBinding.ivEnableLoud.setEnabled(true);
                    mDataBinding.ivEnableLoud.setImageResource(R.drawable.ic_speak_selected);
                }
            }
        });
    }

    /**
     * Whether the monitor uses earback
     *
     * ZH:
     * 监控是否耳返
     */
    private void monitorEarMonitor() {
        RoomManager.getInstance(this).enableInEarMonitor.observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(@Nullable Boolean aBoolean) {
                if (aBoolean == null) {
                    mDataBinding.ivEarMonitor.setEnabled(false);
                } else if (aBoolean == true) {
                    mDataBinding.ivEarMonitor.setEnabled(true);
                    mDataBinding.ivEarMonitor.setImageResource(R.drawable.ic_ear_monitor_selected);
                } else if (aBoolean == false) {
                    mDataBinding.ivEarMonitor.setEnabled(true);
                    mDataBinding.ivEarMonitor
                            .setImageResource(R.drawable.ic_ear_monitor_unselected);
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_join_room:
                if (RoomManager.getInstance(this).isJoinRoom.getValue() == true) {
                    leaveRoom();
                } else {
                    joinRoom();
                }
                break;
            case R.id.tv_select:
                showModeDialog();
                break;
            case R.id.iv_enableLoud:
                switchEnableLoud();
                break;
            case R.id.iv_ear_monitor:
                switchEnableEar();
                break;
            case R.id.iv_sound_effect:
                startActivity(new Intent(MainActivity.this, SoundEffectActivity.class));
                break;
            case R.id.iv_feedback:
                startActivity(new Intent(MainActivity.this, FeedBackActivity.class));
                break;
        }
    }

    /**
     * Turn on / off ear monitor
     *
     * ZH:
     * 开/关耳返
     */
    private void switchEnableEar() {
        Boolean enabled = RoomManager.getInstance(this).enableInEarMonitor.getValue();
        if (enabled == null) {
            return;
        }
        RoomManager.getInstance(this).setEnableInEarMonitor(!enabled);
    }

    /**
     * Turn on / off loud speaker
     *
     * ZH:
     * 开/关外放
     */
    private void switchEnableLoud() {
        boolean enabled = RoomManager.getInstance(this).isLoudspeakerEnabled();
        RoomManager.getInstance(this).enableLoudspeaker(!enabled);
    }

    /**
     * Join the room
     *
     * ZH:
     * 加入房间
     */
    private void joinRoom() {
        String uid = mDataBinding.edittextLocalUid.getText().toString();
        String roomid = mDataBinding.edittextLocalRoomid.getText().toString();
        if (TextUtils.isEmpty(uid)) {
            showToast(R.string.error_ileagal_uid);
            return;
        }

        if (TextUtils.isDigitsOnly(uid) == false) {
            showToast(R.string.error_ileagal_number);
            return;
        }

        if (Integer.valueOf(uid) < 100000 || Integer.valueOf(uid) > 999999) {
            showToast(R.string.error_ileagal_uid);
            return;
        }

        if (TextUtils.isEmpty(roomid)) {
            showToast(R.string.error_ileagal_room_id);
            return;
        }

        if (TextUtils.isDigitsOnly(roomid) == false) {
            showToast(R.string.error_ileagal_number);
            return;
        }

        if (Integer.valueOf(roomid) < 0 || Integer.valueOf(roomid) > 99999999) {
            showToast(R.string.error_ileagal_room_id);
            return;
        }

        Constant.setUID(uid);
        Constant.setRoomId(roomid);

        showDialogProgress();

        DataRepository.getInstance(this)
                .refreshToken(Constant.APPID, Constant.mLocalUid, new HttpItemCallback<String>() {
                    @Override
                    public void onSuccess(String token) {
                        runOnUiThread(() -> {
                            dissMissDialogProgress();
                            if (TextUtils.isEmpty(token)) {
                                showToast(R.string.token_error);
                                return;
                            }

                            //Join the room
                            //加入房间
                            showDialogProgress();
                            int result = RoomManager.getInstance(MainActivity.this)
                                    .joinRoom(token, Constant.mLocalRoomId, Constant.mLocalUid);
                            if (result != 0) {
                                dissMissDialogProgress();
                                showToast(getString(R.string.error_join_room, result));
                            }
                        });
                    }

                    @Override
                    public void onFail(BaseError error) {
                        //Failed to obtain tokens in the business. The whitelist for appid configuration in the background can still be added to the room. If it is not configured, it cannot be added to the room.
                        //业务中获取token失败，后台appid配置白名单依然可以加入房间，若未配置，则不能加入房间。
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                dissMissDialogProgress();
                                showToast(R.string.token_error);
                            }
                        });
                    }
                });
    }

    /**
     * Leave the room
     *
     * 离开房间
     */
    private void leaveRoom() {
        dissMissDialogProgress();
        //Exit the room to reset, the ear return is not used by default
        //退出房间重置
        //默认不使用耳返
        RoomManager.getInstance(this).setEnableInEarMonitor(false);

        //Use speakers by default
        //默认使用扬声器
        RoomManager.getInstance(this).enableLoudspeaker(true);

        //Stop local audio and video
        //停止本地开播
        RoomManager.getInstance(this).stopAudioAndVideo();

        //Exit the room
        //退出房间
        RoomManager.getInstance(this).leaveRoom();
    }

    /**
     * The status of not joining the room
     *
     * ZH:
     * 未加入房间的状态
     */
    private void onUnJoinRoomStatus() {
        adapter.clear();

        mDataBinding.edittextLocalUid.setEnabled(true);
        mDataBinding.edittextLocalRoomid.setEnabled(true);
        mDataBinding.tvSelect.setEnabled(true);
        mDataBinding.tvSelect.setTextColor(Color.BLACK);

        mDataBinding.btnJoinRoom.setText(R.string.join_room);
        mDataBinding.btnJoinRoom.showOpenStatus();

        mDataBinding.ivEnableLoud.setEnabled(false);
        mDataBinding.ivEarMonitor.setEnabled(false);
        mDataBinding.ivSoundEffect.setEnabled(false);
    }

    /**
     * The status after joining the room
     *
     * ZH:
     * 加入房间后状态
     */
    private void onJoinRoomStatus() {
        mDataBinding.edittextLocalUid.setEnabled(false);
        mDataBinding.edittextLocalRoomid.setEnabled(false);
        mDataBinding.tvSelect.setEnabled(false);
        mDataBinding.tvSelect
                .setTextColor(ContextCompat.getColor(this, R.color.main_sudio_disable));

        mDataBinding.btnJoinRoom.setText(R.string.leave_room);
        mDataBinding.btnJoinRoom.showOpenStatus();

        mDataBinding.ivEnableLoud.setEnabled(true);
        mDataBinding.ivEarMonitor.setEnabled(true);
        mDataBinding.ivSoundEffect.setEnabled(true);
    }

    /**
     * Start pushing
     *
     * ZH：
     * 开始推流
     */
    private void startPlay() {
        //By default, ear-back is not used
        //默认不使用耳返
        RoomManager.getInstance(this).setEnableInEarMonitor(false);

        //Use speakers by default
        //默认使用扬声器
        RoomManager.getInstance(this).enableLoudspeaker(true);

        int result = RoomManager.getInstance(this).startAudio();
        if (result != 0) {
            showToast(getString(R.string.error_start_play, result));
            return;
        }

        String uid = RoomManager.getInstance(this).getUid();
        UserInfo userInfo = new UserInfo(uid);
        userInfo.setAudioStreamStopped(false);
        userInfo.setVideoStreamStopped(true);
        adapter.addItem(0, userInfo);
    }

    @Override
    protected void onDestroy() {
        RoomManager.getInstance(this).unRegister(myThunderEventHandler);
        leaveRoom();
        RoomManager.getInstance(this).destroyEngine();
        super.onDestroy();
    }

    /**
     * Menu for selecting mode
     *
     * ZH:
     * 模式菜单选择
     */
    private void showModeDialog() {
        String[] datas = getResources().getStringArray(R.array.mode);
        new MenuDialog(this, Arrays.asList(datas), new MenuDialog.OnItemSelectedListener() {
            @Override
            public void onItemSelected(int index) {
                if (index == 0) {
                    mDataBinding.tvSelect.setText(datas[index]);

                    roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_COMMUNICATION;
                    profile =
                            ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_SPEECH_STANDARD;
                } else if (index == 1) {
                    mDataBinding.tvSelect.setText(datas[index]);

                    roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_COMMUNICATION;
                    profile =
                            ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;
                } else if (index == 2) {
                    mDataBinding.tvSelect.setText(datas[index]);

                    roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE;
                    profile =
                            ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;
                } else if (index == 3) {
                    mDataBinding.tvSelect.setText(datas[index]);

                    roomMode = ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE;
                    profile =
                            ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO;
                }

                //Set Room Mode
                //设置房间模式
                RoomManager.getInstance(MainActivity.this).setRoomMode(roomMode);

                //Set audio mode
                //设置音频模式
                RoomManager.getInstance(MainActivity.this).setAudioConfig(profile,
                        ThunderRtcConstant.CommutMode.THUNDER_COMMUT_MODE_HIGH,
                        ThunderRtcConstant.ScenarioMode.THUNDER_SCENARIO_MODE_DEFAULT);
            }
        }).show();
    }

    /**
     * the logic of handle with click volume icon
     *
     * ZH:
     * 处理点击音量图标逻辑
     *
     * @param userInfo
     */
    private void onItemVolumeClick(int position, UserInfo userInfo) {
        String uid = RoomManager.getInstance(MainActivity.this).getUid();
        String targetUid = userInfo.getUid();
        boolean isLocal = TextUtils.equals(uid, targetUid);

        if (isLocal == true) {
            //set local
            //设置本地
            userInfo.setMuteAudio(false);
            if (userInfo.isAudioStreamStopped()) {
                int result = RoomManager.getInstance(this).startAudio();
                if (result != 0) {
                    return;
                }
                userInfo.setAudioStreamStopped(false);
            } else {
                int result = RoomManager.getInstance(this).stopAudio();
                if (result != 0) {
                    return;
                }
                userInfo.setAudioStreamStopped(true);
            }
        } else {
            //set remote
            //设置远程
            if (userInfo.isMuteAudio()) {
                int result = RoomManager.getInstance(this).stopRemoteAudioStream(targetUid, false);
                if (result != 0) {
                    return;
                }
                userInfo.setMuteAudio(false);
            } else {
                int result = RoomManager.getInstance(this).stopRemoteAudioStream(targetUid, true);
                if (result != 0) {
                    return;
                }
                userInfo.setMuteAudio(true);
            }
        }
        adapter.updateItem(position, userInfo);
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(true);
    }
}
