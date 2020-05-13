/*
 ***********************************************************************************
 *
 *  File     : InputAccessoryView.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/6/27.
 ***********************************************************************************
 */

#import <UIKit/UIKit.h>

@class InputAccessoryView;

@protocol InputAccessoryViewDelegate <NSObject>

@optional

- (void)inputAccessoryViewDidTapOnCancelButton:(InputAccessoryView *)inputAccessoryView;
- (void)inputAccessoryViewDidTapOnConfirmButton:(InputAccessoryView *)inputAccessoryView;

@end

typedef void(^InputAccessoryViewBlock)(InputAccessoryView *inputAccessoryView);

@interface InputAccessoryView : UIView
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UIButton *cancelButton;
@property (nonatomic, readonly, strong) UIButton *confirmButton;

@property (nonatomic, weak) id <InputAccessoryViewDelegate> delegate;
@property (nonatomic, copy) InputAccessoryViewBlock comfirmBlock;
@property (nonatomic, copy) InputAccessoryViewBlock cancelBlock;


- (instancetype)initWithComfirmBlock:(InputAccessoryViewBlock)comfirmBlock
                         cancelBlock:(InputAccessoryViewBlock)cancelBlock;


@end
