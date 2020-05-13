//
//  ToolBar.h
//  SCloudLive
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 JLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolBar;

@protocol ToolBarDelegate <NSObject>

@optional


- (void)toolBarDidTapOnEarpieceButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnEarReturnButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnSoundEffectButton:(ToolBar *)toolBar;
- (void)toolBarDidTapOnFeedbackButton:(ToolBar *)toolBar;

@end

    

@interface ToolBar : UIView
@property (nonatomic, weak) id <ToolBarDelegate> delegate;
@property (nonatomic, readonly, assign) BOOL isEarpieceMode;
@property (nonatomic, readonly, assign) BOOL isEarReturnEnabled;



- (void)updateToolButtonsStatusWithLiveStatus:(BOOL)hasJoinedRoom;

- (void)updateEarpieceButtonStatus:(BOOL)isEarpieceMode;
- (void)updateEarReturnButtonStatus:(BOOL)isEarReturnEnabled;
@end
