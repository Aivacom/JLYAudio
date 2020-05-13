//
//  SoundEffectSelectCell.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "SoundEffectSelectCell.h"
#import "Masonry.h"
#import "CommonMacros.h"


@interface SoundEffectSelectCell ()
@property (nonatomic, readwrite, strong) UILabel *titleLabel;
@property (nonatomic, readwrite, strong) UILabel *subLabel;
@property (nonatomic, readwrite, strong) UIImageView *selectedMarkImageView;


@end

@implementation SoundEffectSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


#pragma mark - Private

- (void)setupSubviews {
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    
    self.subLabel = [[UILabel alloc] init];
    _subLabel.font = [UIFont systemFontOfSize:15];
    _subLabel.textColor = kColorHex(@"#B3B3B3");
    
    [self.contentView addSubview:_subLabel];

    [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right);
        make.top.bottom.mas_equalTo(self.contentView);
    }];
    
    
    self.selectedMarkImageView = [[UIImageView alloc] initWithImage:kImageNamed(@"ic_select")];
    _selectedMarkImageView.hidden = YES;
    
    [self.contentView addSubview:_selectedMarkImageView];
    
    [_selectedMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(24);
    }];
    
}



@end
