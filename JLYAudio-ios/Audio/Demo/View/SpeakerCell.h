//
//  SpeakerCell.h
//  JLYAudio
//
//  Created by iPhuan on 2019/10/21.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThunderRtcAudioVolumeInfo;
@class SpeakerCell;

@protocol SpeakerCellDelegate <NSObject>

@optional


- (void)speakerCellDidTapOnVolumeButton:(SpeakerCell *)cell;

@end


@interface SpeakerCell : UITableViewCell
@property (nonatomic, weak) id <SpeakerCellDelegate> delegate;
@property (nonatomic, readonly, strong) ThunderRtcAudioVolumeInfo *volumeInfo;
@property (nonatomic, readonly, assign) BOOL isMuted;




- (void)setupDataWithVolumeInfo:(ThunderRtcAudioVolumeInfo *)volumeInfo;

- (void)setMuted:(BOOL)muted;

@end
