/*
 ***********************************************************************************
 *
 *  File     : PickerView.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2019/4/25.
 ***********************************************************************************
 */

#import "PickerView.h"
#import "CommonMacros.h"
#import "PickerViewManager.h"


@interface PickerView ()
@property (nonatomic, readwrite, copy) NSArray *dataSources;
@property (nonatomic, readwrite, copy) NSString *selectedResultText;

@end

@implementation PickerView

#pragma mark - Public

+ (instancetype)pickerViewWithDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource {
    
    return [[self alloc] initWithDataSource:dataSource];;
}


- (instancetype)initWithDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource {
    self = [super init];
    if (self) {
        _dataSources = [dataSource copy];
        
        self.backgroundColor = [PickerViewManager sharedManager].backgroundColor;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setSelectedRowWithValue:(id)value {
    [self.dataSources enumerateObjectsUsingBlock:^(id <PickerDataProtocal> obj, NSUInteger idx, BOOL *stop) {
        if (obj.value == value) {
            [self selectRow:idx inComponent:0 animated:NO];
            *stop = YES;
        }
    }];
}

- (void)updateDataSource:(NSArray <id <PickerDataProtocal>> *)dataSource {
    _dataSources = [dataSource copy];
    [self reloadAllComponents];
}


#pragma mark - Private

- (NSAttributedString *)p_attributedStringWithTitle:(NSString *)title {
    if (title) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[PickerViewManager sharedManager].textColor};
        [attributedString addAttributes:attrs range:NSMakeRange(0, title.length)];
        return attributedString;
    }
    
    return nil;
}


#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
}


#pragma mark - Set or Get

- (void)setSelectedResultValue:(NSString *)selectedResultValue {
    [self setSelectedRowWithValue:selectedResultValue];
}

- (NSString *)selectedResultText {
    NSInteger row = [self selectedRowInComponent:0];
    if (row < 0) {
        return nil;
    }
    if (self.dataSources.count == 0) {
        return nil;
    }
    
    id <PickerDataProtocal> data = self.dataSources[row];
    return data.title;
}

- (id)selectedResultValue {
    NSInteger row = [self selectedRowInComponent:0];
    if (row < 0) {
        return nil;
    }
    
    if (self.dataSources.count == 0) {
        return nil;
    }
    
    id <PickerDataProtocal> data = self.dataSources[row];
    return data.value;
}



#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSources.count;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return [PickerViewManager sharedManager].rowHeight;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id <PickerDataProtocal> data = self.dataSources[row];
    return [self p_attributedStringWithTitle:data.title];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}

@end
