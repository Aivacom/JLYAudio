//
//  ToolBar.m
//  SCloudLive
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "ToolBar.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "UIImage+Additions.h"



@interface ToolBar ()
@property (nonatomic, strong) UIButton *earpieceButton;
@property (nonatomic, strong) UIButton *earReturnButton;
@property (nonatomic, strong) UIButton *soundEffectButton;
@property (nonatomic, readwrite, assign) BOOL isEarpieceMode;
@property (nonatomic, readwrite, assign) BOOL isEarReturnEnabled;

@end

@implementation ToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Private

- (void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    // Function button
    self.earpieceButton = [[UIButton alloc] init];
    
    [_earpieceButton addTarget:self action:@selector(onReceiverButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_earpieceButton];
    [_earpieceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    self.earReturnButton = [[UIButton alloc] init];
    
    [_earReturnButton addTarget:self action:@selector(onEarReturnButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_earReturnButton];
    [_earReturnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(self.earpieceButton.mas_right).offset(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    [self updateEarpieceButtonStatus:NO];
    
    
    self.soundEffectButton = [[UIButton alloc] init];
    [_soundEffectButton setBackgroundImage:kImageNamed(@"toolbar_btn_effects") forState:UIControlStateNormal];
    [_soundEffectButton setBackgroundImage:kImageNamed(@"toolbar_btn_effects") forState:UIControlStateHighlighted];
    
    [_soundEffectButton addTarget:self action:@selector(onSoundEffectButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_soundEffectButton];
    [_soundEffectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.mas_equalTo(self.earReturnButton.mas_right).offset(12);
        make.bottom.mas_equalTo(-12);
    }];
    
    [self updateEarReturnButtonStatus:NO];
    
    
    UIButton *feedbackButton = [[UIButton alloc] init];
    [feedbackButton setBackgroundImage:kImageNamed(@"toolbar_btn_report") forState:UIControlStateNormal];
    [feedbackButton setBackgroundImage:[kImageNamed(@"toolbar_btn_report") imageWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    
    
    [feedbackButton addTarget:self action:@selector(onFeedbackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:feedbackButton];
    [feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(-12);
    }];
    
    
    
    [self updateToolButtonsStatusWithLiveStatus:NO];
}


#pragma mark - Action

- (void)onReceiverButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnEarpieceButton:)]) {
        [_delegate toolBarDidTapOnEarpieceButton:self];
    }
}

- (void)onEarReturnButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnEarReturnButton:)]) {
        [_delegate toolBarDidTapOnEarReturnButton:self];
    }
}

- (void)onSoundEffectButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnSoundEffectButton:)]) {
        [_delegate toolBarDidTapOnSoundEffectButton:self];
    }
}



- (void)onFeedbackButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(toolBarDidTapOnFeedbackButton:)]) {
        [_delegate toolBarDidTapOnFeedbackButton:self];
    }
}


#pragma mark - Public

- (void)updateToolButtonsStatusWithLiveStatus:(BOOL)hasJoinedRoom {
    _earpieceButton.enabled = hasJoinedRoom;
    _earReturnButton.enabled = hasJoinedRoom;
    _soundEffectButton.enabled = hasJoinedRoom;
}



- (void)updateEarpieceButtonStatus:(BOOL)isEarpieceMode {
    self.isEarpieceMode = isEarpieceMode;
    
    UIImage *normalImage = kImageNamed(@"toolbar_btn_speaker");
    if (_isEarpieceMode) {
        normalImage = kImageNamed(@"toolbar_btn_earpiece");
    }
    UIImage *highlightedImage = [normalImage imageWithAlphaComponent:0.7];
    UIImage *disabledImage = highlightedImage;
    
    [_earpieceButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_earpieceButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [_earpieceButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];
}


- (void)updateEarReturnButtonStatus:(BOOL)isEarReturnEnabled {
    self.isEarReturnEnabled = isEarReturnEnabled;

    UIImage *normalImage = kImageNamed(@"toolbar_btn_headset");
    if (_isEarReturnEnabled) {
        normalImage = kImageNamed(@"toolbar_btn_headset_enabled");
    }
    UIImage *highlightedImage = [normalImage imageWithAlphaComponent:0.7];
    UIImage *disabledImage = highlightedImage;
    
    [_earReturnButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_earReturnButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [_earReturnButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];
}




#pragma mark - Public


@end
