/*
 ***********************************************************************************
 *
 *  File     : PickerView.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2019/4/25.
 ***********************************************************************************
 */

#import <UIKit/UIKit.h>
#import "PickerDataProtocal.h"

@class PickerBaseData;

@interface PickerView : UIPickerView <UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, readonly, copy) NSArray <id <PickerDataProtocal>> *dataSources;
@property (nonatomic, strong) id selectedResultValue;
@property (nonatomic, readonly, copy) NSString *selectedResultText;

+ (instancetype)pickerViewWithDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource;

- (instancetype)initWithDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource;

- (void)updateDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource;

- (void)setSelectedRowWithValue:(id)value;

@end
