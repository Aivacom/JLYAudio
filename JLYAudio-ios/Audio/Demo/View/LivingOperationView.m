//
//  LivingOperationView.m
//  SCloudLive
//
//  Created by iPhuan on 2019/8/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "LivingOperationView.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "TextField.h"
#import "UIImage+Additions.h"
#import "ThunderManager.h"

@interface LivingOperationView () <UITextFieldDelegate>
@property (nonatomic, strong) TextField *localUidTextField;
@property (nonatomic, strong) TextField *localRoomIdTextField;
@property (nonatomic, strong) UIButton *joinRoomButton;
@property (nonatomic, readwrite, strong) UIButton *liveConfigButton;

@property (nonatomic, assign) BOOL hasJoinedRoom;


@end

@implementation LivingOperationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 128)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    /*************** 本地uid/Local uid ***************/
    self.localUidTextField = [self textField];
    _localUidTextField.maxInputLength = 6;
    // 随机生成6位本地uid
    // Randomly generate 6 local uids
    _localUidTextField.text = [ThunderManager sharedManager].localUid;
    
    [self addSubview:_localUidTextField];
    [_localUidTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.left.mas_equalTo(12);
        make.width.mas_equalTo(kRatioFitSize(120));
        make.height.mas_equalTo(32);
    }];
    
    
    UILabel *localUidLabel = [self titleLabel];
    localUidLabel.text = @"本地UID";
    
    [self addSubview:localUidLabel];
    [localUidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.localUidTextField.mas_top).offset(-4);
        make.left.mas_equalTo(self.localUidTextField);
        make.height.mas_equalTo(16);
    }];
    
    
    /*************** 本地房间号/Local room number ***************/
    self.localRoomIdTextField = [self textField];
    _localRoomIdTextField.maxInputLength = 8;
    
    [self addSubview:_localRoomIdTextField];
    [_localRoomIdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.localUidTextField);
        make.left.mas_equalTo(self.localUidTextField.mas_right).offset(10);
        make.width.mas_equalTo(kRatioFitSize(120));
        make.height.mas_equalTo(self.localUidTextField);
    }];
    
    
    UILabel *localRoomIdLabel = [self titleLabel];
    localRoomIdLabel.text = @"房间号";
    
    [self addSubview:localRoomIdLabel];
    [localRoomIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.localRoomIdTextField.mas_top).offset(-4);
        make.left.mas_equalTo(self.localRoomIdTextField);
        make.height.mas_equalTo(localUidLabel);
    }];
    
    
    /*************** 开播按钮/Live button ***************/
    
    self.joinRoomButton = [self button];
    [_joinRoomButton addTarget:self action:@selector(onLiveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_joinRoomButton];
    [_joinRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.localUidTextField);
        make.right.mas_equalTo(k5FitSize(-16));
        make.width.mas_equalTo(kRatioFitSize(80));
        make.height.mas_equalTo(self.localUidTextField);
    }];
    
    self.liveConfigButton = [self selectButton];
    _liveConfigButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_liveConfigButton addTarget:self action:@selector(onLiveConfigButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_liveConfigButton];
    [_liveConfigButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.localUidTextField.mas_bottom).offset(16);
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(k5FitSize(-16));
        make.height.mas_equalTo(36);
    }];
    
    
   
    
    [self updateControlsStatusForLiveStatus:NO];
    [self updateLiveButtonStatus];
}




- (UILabel *)titleLabel {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    return titleLabel;
}

- (TextField *)textField {
    TextField *textField = [[TextField alloc] init];
    textField.backgroundColor = kColorHex(@"#A3ACCC33");
    textField.layer.cornerRadius = 3;
    textField.layer.masksToBounds = YES;
    textField.font = [UIFont fontWithName:@"SFProText-Medium" size:16];
    textField.textColor = kColorHex(@"#414141");
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.canPaste = NO;
    [textField addTarget:self action:@selector(textFieldDidChangedEditing:) forControlEvents:UIControlEventEditingChanged];
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 32)];
    
    
    return textField;
}

- (UIButton *)button {
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#6485F9")];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#3A61ED")];
    UIImage *disabledImage = [UIImage imageWithColor:kColorHex(@"#CCCCCC")];

    
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    
    return button;
}

- (UIButton *)selectButton {
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:kColorHex(@"#414141") forState:UIControlStateNormal];
    [button setTitleColor:kColorHex(@"#BBBBBB") forState:UIControlStateDisabled];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex(@"#A3ACCC33")];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex(@"#A3ACCC66")];
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalImage forState:UIControlStateDisabled];

    [button setImage:kImageNamed(@"ic_pull_arrow") forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(14, kScreenWidth - 12 - k5FitSize(16) - 16 - 12, 14, 16);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16 + 12 + 16);
    return button;
}

- (void)updateLiveButtonStatus {
    _joinRoomButton.enabled = _localUidTextField.text.length > 0 && _localRoomIdTextField.text.length > 0;
}



#pragma mark - Public



- (void)updateControlsStatusForLiveStatus:(BOOL)hasJoinedRoom {
    _hasJoinedRoom = hasJoinedRoom;
    
    NSString *title = @"进入房间";
    if (hasJoinedRoom) {
        title = @"退出房间";
    }
    
    [_joinRoomButton setTitle:title forState:UIControlStateNormal];
    
    _localUidTextField.enabled = !_hasJoinedRoom;
    _localRoomIdTextField.enabled = !_hasJoinedRoom;
    
    _liveConfigButton.enabled = !_hasJoinedRoom;
}

- (void)setLiveConfigTitle:(NSString *)title {
    [_liveConfigButton setTitle:title forState:UIControlStateNormal];
}



#pragma mark - Action

- (void)onLiveButtonClick {
    
    if (_delegate && [_delegate respondsToSelector:@selector(operationView:didTapOnJoinRoomButtonWithLocalUid:roomId:)]) {
        [_delegate operationView:self didTapOnJoinRoomButtonWithLocalUid:_localUidTextField.text roomId:_localRoomIdTextField.text];
    }
}

- (void)onLiveConfigButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(operationViewDidTapOnLiveConfigButton:)]) {
        [_delegate operationViewDidTapOnLiveConfigButton:self];
    }
}


#pragma mark - UIControlEventEditingChanged

- (void)textFieldDidChangedEditing:(UITextField *)textField {
    [self updateLiveButtonStatus];
}




@end
