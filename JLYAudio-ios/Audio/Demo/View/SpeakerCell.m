//
//  SpeakerCell.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/21.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "SpeakerCell.h"
#import "Masonry.h"
#import "CommonMacros.h"
#import "ThunderRtcAudioVolumeInfo+Additions.h"
#import "ThunderManager.h"



@interface SpeakerCell ()
@property (nonatomic, strong) UILabel *uidLabel;
@property (nonatomic, strong) UIButton *volumeButton;
@property (nonatomic, readwrite, assign) BOOL isMuted;
@property (nonatomic, readwrite, strong) ThunderRtcAudioVolumeInfo *volumeInfo;



@end


@implementation SpeakerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}


#pragma mark - Private

- (void)setupSubviews {
    self.contentView.backgroundColor = kColorHex(@"#EAECF5");
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-11);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-1);
    }];
    
    self.uidLabel = [[UILabel alloc] init];
    _uidLabel.textColor = [UIColor blackColor];
    _uidLabel.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:_uidLabel];
    
    [_uidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    
    self.volumeButton = [[UIButton alloc] init];
    _volumeButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [_volumeButton addTarget:self action:@selector(onVolumeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_volumeButton];
    
    [_volumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(44);
        make.right.top.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Action

- (void)onVolumeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(speakerCellDidTapOnVolumeButton:)]) {
        [_delegate speakerCellDidTapOnVolumeButton:self];
    }
}



#pragma mark - Set
- (void)setupDataWithVolumeInfo:(ThunderRtcAudioVolumeInfo *)volumeInfo {
    self.volumeInfo = volumeInfo;
    
    if ([_volumeInfo.uid isEqualToString:[ThunderManager sharedManager].localUid]) {
        _uidLabel.text = [NSString stringWithFormat:@"%@ (我)", _volumeInfo.uid];
    } else {
        _uidLabel.text = volumeInfo.uid;
    }
    
    if (_volumeInfo.volume >= 0 && _volumeInfo.volume <= 30) {
        [_volumeButton setImage:kImageNamed(@"volume_1") forState:UIControlStateNormal];
    } else if (_volumeInfo.volume >= 31 && _volumeInfo.volume <= 60) {
        [_volumeButton setImage:kImageNamed(@"volume_2") forState:UIControlStateNormal];
    } else if (_volumeInfo.volume >= 61 && _volumeInfo.volume <= 100) {
        [_volumeButton setImage:kImageNamed(@"volume_3") forState:UIControlStateNormal];
    }
    
    if (_volumeInfo.isMuted) {
        [_volumeButton setImage:kImageNamed(@"volume_no") forState:UIControlStateNormal];
    }
}


- (void)setMuted:(BOOL)muted {
    _isMuted = muted;
    if (_isMuted) {
        [_volumeButton setImage:kImageNamed(@"volume_no") forState:UIControlStateNormal];
    } else {
        [_volumeButton setImage:kImageNamed(@"volume_1") forState:UIControlStateNormal];
    }
}



@end
