//
//  LivingOperationView.h
//  SCloudLive
//
//  Created by iPhuan on 2019/8/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LivingOperationView;
@class TextField;

@protocol LivingOperationViewDelegate <NSObject>

@optional

- (void)operationView:(LivingOperationView *)operationView didTapOnJoinRoomButtonWithLocalUid:(NSString *)uid roomId:(NSString *)roomId;
- (void)operationViewDidTapOnLiveConfigButton:(LivingOperationView *)operationView;


@end


@interface LivingOperationView : UIView
@property (nonatomic, weak) id <LivingOperationViewDelegate> delegate;
@property (nonatomic, readonly, strong) UIButton *liveConfigButton;


- (void)updateControlsStatusForLiveStatus:(BOOL)hasJoinedRoom;

- (void)setLiveConfigTitle:(NSString *)title;

@end
