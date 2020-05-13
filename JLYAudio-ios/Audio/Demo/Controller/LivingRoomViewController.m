//
//  LivingRoomViewController.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/18.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingRoomViewController.h"
#import "Masonry.h"
#import "IQKeyboardManager.h"

#import "Utils.h"
#import "CommonMacros.h"
#import "MBProgressHUD+HUD.h"
#import "UIView+Additions.h"
#import "UIViewController+AlertController.h"
#import "UIViewController+BaseViewController.h"

#import "ThunderManager.h"
#import "ThunderRtcAudioVolumeInfo+Additions.h"

#import "LivingOperationView.h"
#import "ToolBar.h"
#import "TextField.h"
#import "SpeakerCell.h"

#import "FeedbackViewController.h"
#import "SoundEffectSelectViewController.h"




static NSString * const kFeedbackAppId = @"JLYAudio-ios"; // 对接反馈系统AppID/Docking feedback system AppID

static NSString * const kSpeakerCellReuseIdentifier = @"SpeakerCell";

static dispatch_semaphore_t _semaphore;


@interface LivingRoomViewController () <UITableViewDelegate, UITableViewDataSource, ThunderEventDelegate, LivingOperationViewDelegate, ToolBarDelegate, SpeakerCellDelegate>
@property (nonatomic, strong) LivingOperationView *operationView;
@property (nonatomic, strong) ToolBar *toolBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ThunderRtcAudioVolumeInfo *localAudioVolumeInfo;
@property (nonatomic, strong) NSMutableArray<ThunderRtcAudioVolumeInfo *> *speakers;



@end

@implementation LivingRoomViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupBaseSetting];
    [self setupNavigationBarWithBarTintColor:[UIColor whiteColor] titleColor:kColorHex(@"#333333") titleFont:[UIFont boldSystemFontOfSize:17] eliminateSeparatorLine:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    if (@available(iOS 13.0, *)) {
        self.navigationController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
        
    [self setup];
    [self setupSubviews];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.presentedViewController) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark - Private

- (void)setup {
    
    _semaphore = dispatch_semaphore_create(1);

    // 初始化SDK
    // Initialize SDK
    [self.thunderManager setupEngineWithDelegate:self];
    
}

- (void)setupSubviews {
    
    // 顶部操作区
    // Top operating area
    self.operationView = [[LivingOperationView alloc] init];
    _operationView.delegate = self;
    [_operationView setLiveConfigTitle:@"通话模式 44.1KHz采样率 40K码率"];
    
    [self.view addSubview:_operationView];
    
    [_operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeight);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(128);
    }];
    
    
    // 底部工具栏
    // Bottom toolbar
    self.toolBar = [[ToolBar alloc] init];
    _toolBar.delegate = self;
    
    [self.view addSubview:_toolBar];
    
    [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(-kBottomOffset);
    }];
    
    
    
    self.tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(28, 0, 40, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[SpeakerCell class] forCellReuseIdentifier:kSpeakerCellReuseIdentifier];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.operationView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.toolBar.mas_top);
    }];
    
}


#pragma mark - LivingOperationViewDelegate

- (void)operationView:(LivingOperationView *)operationView didTapOnJoinRoomButtonWithLocalUid:(NSString *)uid roomId:(NSString *)roomId {
    
    if (self.thunderManager.hasJoinedRoom) {
        // 退出房间
        // Leave room
        [self.thunderManager leaveRoom];
    } else {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        
        // 更新本地用户信息
        // Update local user info
        [self.thunderManager updateLocalUid:uid roomId:roomId];
        self.localAudioVolumeInfo.uid = uid;

        // 请求权限
        // Request permission
        [Utils requestAccessForMediaType:AVMediaTypeAudio viewController:self completionHandler:^(BOOL isAvailable) {
            if (isAvailable) {
                [self requestToken];
            }
        }];
    }
}

- (void)requestToken {
    [MBProgressHUD showActivityIndicator];
    // 请求token
    // Get token
    [self.thunderManager requestTokenWithCompletionHandler:^(BOOL success) {
        if (success) {
            // 进入房间
            // Join room
            [self.thunderManager joinRoom];
            
            // 设置进房间超时时间，30S后如还未收到进房间回调，隐藏loading
            // Set the timeout period for entering the room. If the callback for entering the room has not been received after 30S, hide the loading
            [self performSelector:@selector(joinRoomTimeoutHandle) withObject:nil afterDelay:30];
        } else {
            [MBProgressHUD showToast:@"未获取到token，请稍后重试" ];
        }
    }];
}


- (void)joinRoomTimeoutHandle {
    [MBProgressHUD hideActivityIndicator];
}


- (void)operationViewDidTapOnLiveConfigButton:(LivingOperationView *)operationView {
    UIAlertController *alertController = [self actionSheetWithTitle:nil message:nil handler:^(UIAlertAction *action, NSUInteger index) {
        if (index != 4) {
            self.thunderManager.liveConfig = index;
            [self.operationView setLiveConfigTitle:action.title];
        }
    } otherActionTitles:@"通话模式 16KHz采样率 18K码率", @"通话模式 44.1KHz采样率 40K码率", @"娱乐模式 44.1KHz采样率 40K码率", @"娱乐模式 44.1KHz采样率 128K码率", nil];
    
    if (@available(iOS 13.0, *)) {
        alertController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    // 对iPad做处理
    // Handle iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
        popPresenter.sourceView = _operationView.liveConfigButton;
        popPresenter.sourceRect = CGRectMake(_operationView.liveConfigButton.width - 28.5, _operationView.liveConfigButton.height/2.0f + 10, 0, 0);
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}




#pragma mark - ToolBarDelegate

- (void)toolBarDidTapOnEarpieceButton:(ToolBar *)toolBar {
    if ([self.thunderManager enableLoudspeaker:toolBar.isEarpieceMode]) {
        [toolBar updateEarpieceButtonStatus:!toolBar.isEarpieceMode];
    } else {
        [MBProgressHUD showToast:@"操作失败，请稍后重试"];
    }
}

- (void)toolBarDidTapOnEarReturnButton:(ToolBar *)toolBar {
    if ([self.thunderManager enableEarReturn:!toolBar.isEarReturnEnabled]) {
        [toolBar updateEarReturnButtonStatus:!toolBar.isEarReturnEnabled];
    } else {
        [MBProgressHUD showToast:@"操作失败，请稍后重试"];
    }
}

- (void)toolBarDidTapOnSoundEffectButton:(ToolBar *)toolBar {
    SoundEffectSelectViewController *viewController = [[SoundEffectSelectViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toolBarDidTapOnFeedbackButton:(ToolBar *)toolBar {
    [self onFeedbackButtonClick];
}


#pragma mark - SpeakerCellDelegate

- (void)speakerCellDidTapOnVolumeButton:(SpeakerCell *)cell {
    // 加锁
    // add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    [cell setMuted:!cell.isMuted];
    
    if ([self.thunderManager.localUid isEqualToString:cell.volumeInfo.uid] ) {
        [self.thunderManager disableLocalAudio:cell.isMuted];
    } else {
        [self.thunderManager disableRemoteAudio:cell.volumeInfo.uid disabled:cell.isMuted];
    }
    cell.volumeInfo.isMuted = cell.isMuted;
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speakers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpeakerCell *cell = [tableView dequeueReusableCellWithIdentifier:kSpeakerCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    ThunderRtcAudioVolumeInfo *volumeInfo = self.speakers[indexPath.row];
    [cell setupDataWithVolumeInfo:volumeInfo];
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41;
}


#pragma mark - ThunderEventDelegate

/*!
 @brief 进入房间回调/Enter room callback
 @param room 房间名/room name
 @param uid 用户id/user Id
 @elapsed 未实现/none
 */
- (void)thunderEngine: (ThunderEngine* _Nonnull)engine onJoinRoomSuccess:(nonnull NSString* )room withUid:(nonnull NSString*)uid elapsed:(NSInteger)elapsed {
    
    [MBProgressHUD hideActivityIndicator];
    // 取消超时操作
    // Cancel timeout operation
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(joinRoomTimeoutHandle) object:nil];

    self.thunderManager.hasJoinedRoom = YES;
    [_operationView updateControlsStatusForLiveStatus:YES];
    [_toolBar updateToolButtonsStatusWithLiveStatus:YES];
    
    // 开播
    // Live
    [self.thunderManager enableAudioLive];
    
    // 设置屏幕常亮
    // Setting screen is always on
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

/*!
 @brief 离开房间/Leave room
 */
- (void)thunderEngine: (ThunderEngine* _Nonnull)engine onLeaveRoomWithStats:(ThunderRtcRoomStats* _Nonnull)stats {
    
    self.thunderManager.hasJoinedRoom = NO;
    [_operationView updateControlsStatusForLiveStatus:NO];
    [_toolBar updateToolButtonsStatusWithLiveStatus:NO];
    [_toolBar updateEarpieceButtonStatus:NO];
    [_toolBar updateEarReturnButtonStatus:NO];

    
    [self.speakers removeAllObjects];
    [_tableView reloadData];
    
    // 恢复localAudioVolumeInfo
    // Restore localAudioVolumeInfo
    self.localAudioVolumeInfo = nil;
    
    //关闭耳返
    //Turn off the ear
    [self.thunderManager enableEarReturn:NO];
    
    // 移除token
    // Remove token
    self.thunderManager.token = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // SDK退出房间后依然会保持之前停止流的状态，所以退出房间时对所有流进行恢复
    // After exiting the room, the SDK will still maintain the state of the previous stop flow, so all flows are restored when exiting the room
    [self.thunderManager recoveryAllRemoteAudioStream];
}



/*!
 @brief 说话声音音量提示回调/Speaking voice volume prompt callback
 @param speakers 说话用户/speaker users
 @param totalVolume 混音后总音量/Total volume after mixing
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onPlayVolumeIndication:(NSArray<ThunderRtcAudioVolumeInfo *> * _Nonnull)speakers
          totalVolume:(NSInteger)totalVolume {
    // 加锁
    // add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if (self.speakers.count == 0) {
        // 添加本地用户
        // add local user
        [self.speakers addObject:self.localAudioVolumeInfo];
    }
    
    if (self.speakers.count == 1) {
        // 添加正在说话的人
        // add talking user
        [self.speakers addObjectsFromArray:speakers];
        
        [_tableView reloadData];
    } else {
        // 同步音量数据已经添加新的用户
        // Synchronized volume data has been added for new users

        NSMutableArray *newSpeakers = [[NSMutableArray alloc] init];
        [speakers enumerateObjectsUsingBlock:^(ThunderRtcAudioVolumeInfo *obj, NSUInteger idx, BOOL *stop) {
            __block BOOL found = NO;
            
            [self.speakers enumerateObjectsUsingBlock:^(ThunderRtcAudioVolumeInfo *volumeInfo, NSUInteger index, BOOL *theStop) {
                if ([volumeInfo.uid isEqualToString:obj.uid]) {
                    volumeInfo.volume = obj.volume;
                    // 单条更新，避免滚动reloadData卡顿
                    // Update single cell, avoid rolling reloadData stuck
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    SpeakerCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                    [cell setupDataWithVolumeInfo:volumeInfo];
                    found = YES;
                    
                    *theStop = YES;
                }
            }];
            
            if (!found) {
                [newSpeakers addObject:obj];
            }
        }];
        
        // 如果有新加成员
        // If there are new members
        if (newSpeakers.count) {
            [self.speakers addObjectsFromArray:newSpeakers];
            [_tableView reloadData];
        }
    }
    
    dispatch_semaphore_signal(_semaphore);
}

/*!
 @brief 采集声音音量提示回调/Collected sound volume prompt callback
 @param totalVolume 采集总音量（包含麦克风采集和文件播放）/Collect the total volume (including microphone collection and file playback)
 @param cpt 采集时间戳/Collected timestamp
 @param micVolume 麦克风采集音量/Microphone collection volume
 @
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onCaptureVolumeIndication:(NSInteger)totalVolume cpt:(NSUInteger)cpt micVolume:(NSInteger)micVolume {
    // 加锁
    // Add semaphore
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

    // 设置本地音量
    // Set local volume
    self.localAudioVolumeInfo.volume = micVolume;
    
    // 如果只有自己时更新数据，否则同其他音量数据在onPlayVolumeIndication里更新
    // Update the data if only you own, otherwise update it with other volume data in onPlayVolumeIndication
    if (self.speakers.count <= 1) {
        
        if (self.speakers.count == 0) {
            [self.speakers addObject:self.localAudioVolumeInfo];
            [self.tableView reloadData];
        } else {
            // 单条更新，避免滚动reloadData卡顿
            // Update single cell, avoid rolling reloadData stuck
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            SpeakerCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [cell setupDataWithVolumeInfo:self.localAudioVolumeInfo];
        }
    }
    
    dispatch_semaphore_signal(_semaphore);
}


/*!
 @brief 远端用户音频流停止/开启回调 / Remote user audio stream stop / start callback
 @param stopped 停止/开启，YES=停止 NO=开启 / Stop or open, YES = stop NO = open
 @param uid 远端用户uid/Remote user uid

 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteAudioStopped:(BOOL)stopped byUid:(nonnull NSString*)uid {
    kLog(@"Uid:%@ stopped：%@", uid, stopped?@"YES":@"NO");
}



/*!
 @brief 鉴权服务即将过期回调/Authentication service is about to expire callback
 @param token 即将服务失效的Token/Token that is about to expire
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onTokenWillExpire:(nonnull NSString*)token {
    kLog(@"Token will expire：%@", token);
    [self updateToken];
}

/*!
 @brief 鉴权过期回调/Authentication expired callback
 */
- (void)thunderEngineTokenRequest:(ThunderEngine * _Nonnull)engine {
    kLog(@"Token expired");
    
    // 如果onTokenWillExpire更新失败补救请求一次token
    // If onTokenWillExpire update fails, remedial request a token
    [self updateToken];
}

- (void)updateToken {
    // token即将过期时或者已经过期时重新请求
    // Re-request when the token is about to expire or has expired
    self.thunderManager.token = nil;
    [self.thunderManager requestTokenWithCompletionHandler:^(BOOL success) {
        if (success) {
            // 更新token
            // Update token
            [self.thunderManager updateToken];
        }
    }];
}


/*!
 @brief 远端用户加入回调/Remote user join callback
 @param uid 远端用户uid/Remote user uid
 @param elapsed 加入耗时/Join time-consuming
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onUserJoined:(nonnull NSString*)uid elapsed:(NSInteger)elapsed {
    kLog(@"Uid:%@", uid);
}

/*!
 @brief 远端用户离开当前房间回调/Callback when the remote user leaves the current room
 @param uid 离线用户uid/Offline user id
 @param reason 离线原因，参见ThunderLiveRtcUserOfflineReason/For offline reasons, see ThunderLiveRtcUserOfflineReason
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onUserOffline:(nonnull NSString*)uid reason:(ThunderLiveRtcUserOfflineReason)reason {
    kLog(@"Uid:%@", uid);

    // Resume streaming mute operation
    [self.thunderManager recoveryRemoteAudioStream:uid];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);

    
    __block ThunderRtcAudioVolumeInfo *volumeInfo = nil;
    
    [self.speakers enumerateObjectsUsingBlock:^(ThunderRtcAudioVolumeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uid isEqualToString:uid]) {
            volumeInfo = obj;
            *stop = YES;
        }
    }];
    
    if (volumeInfo) {
        [self.speakers removeObject:volumeInfo];
        [_tableView reloadData];
    }
    
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - Feedback
- (void)onFeedbackButtonClick {    
    [self setupFeedbackManagerOnce];
    
    FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithUid:self.thunderManager.localUid];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)setupFeedbackManagerOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FeedbackManager sharedManager].appId = kFeedbackAppId;
        [FeedbackManager sharedManager].appSceneName = @"audio";
        [FeedbackManager sharedManager].functionDesc = @"1、实现纯音频互动，切换音筒、耳返、静音、开播模式等操作\n2、支持多种音效和变声";
        [FeedbackManager sharedManager].logFilePath = self.thunderManager.logPath;
    });
}


#pragma mark - Get and Set

- (ThunderManager *)thunderManager {
    return [ThunderManager sharedManager];
}

- (ThunderRtcAudioVolumeInfo *)localAudioVolumeInfo {
    if (_localAudioVolumeInfo == nil) {
        _localAudioVolumeInfo = [[ThunderRtcAudioVolumeInfo alloc] init];
        _localAudioVolumeInfo.uid = self.thunderManager.localUid;
        _localAudioVolumeInfo.volume = 0;
    }
    
    return _localAudioVolumeInfo;
}


- (NSMutableArray *)speakers {
    if (_speakers == nil) {
        _speakers = [[NSMutableArray alloc] init];
    }
    return _speakers;
}


@end
