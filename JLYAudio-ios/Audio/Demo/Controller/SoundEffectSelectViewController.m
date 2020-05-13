//
//  SoundEffectSelectViewController.m
//  JLYAudio
//
//  Created by iPhuan on 2019/10/22.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "SoundEffectSelectViewController.h"
#import "UIViewController+BaseViewController.h"
#import "SoundEffectSelectCell.h"
#import "ThunderManager.h"
#import "CommonMacros.h"
#import "Masonry.h"



static NSString * const kSoundEffectSelectCellReuseIdentifier = @"SoundEffectSelectCell";


@interface SoundEffectSelectViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *soundEffects;





@end

@implementation SoundEffectSelectViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音效/变声模式";
    [self setupCommonSetting];
    [self setBackBarButtonItemAction:@selector(onBackBarButtonClick:)];
    
    
    self.soundEffects = @[@"无", @"VALLEY模式", @"R&B模式", @"KTV模式", @"CHARMING模式", @"流行模式", @"嘻哈模式", @"摇滚模式", @"演唱会模式", @"录音棚模式", @"空灵", @"惊悚", @"鲁班", @"萝莉", @"大叔", @"死肥仔", @"熊孩子", @"魔兽农民", @"重金属", @"感冒", @"重机械", @"困兽", @"强电流"];
    
    
    [self setupSubviews];
}


#pragma mark - Private

- (void)setupSubviews {
    self.view.backgroundColor = kColorHex(@"#EDEFF4");

    self.tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0);
    _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    _tableView.separatorColor = kColorHex(@"#EBEBEB");
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[SoundEffectSelectCell class] forCellReuseIdentifier:kSoundEffectSelectCellReuseIdentifier];

    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(kNavBarHeight + 5);
    }];
    
}

#pragma mark - Public



#pragma mark - Action
- (void)onBackBarButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _soundEffects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SoundEffectSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kSoundEffectSelectCellReuseIdentifier forIndexPath:indexPath];
    
    NSString *title = _soundEffects[indexPath.row];
    cell.titleLabel.text = title;
    
    if (indexPath.row == 0) {
        cell.subLabel.text = @"";
    } else if (indexPath.row < 10) {
        cell.subLabel.text = @"（音效）";
    } else if (indexPath.row >= 10) {
        cell.subLabel.text = @"（变声）";
    }
    
    cell.selectedMarkImageView.hidden = [ThunderManager sharedManager].selectedSoundEffectIndex != indexPath.row;

    
    return cell;
}




#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:[ThunderManager sharedManager].selectedSoundEffectIndex inSection:0];
    SoundEffectSelectCell *cell = [_tableView cellForRowAtIndexPath:aIndexPath];
    cell.selectedMarkImageView.hidden = YES;
    
    // 设置音效或者变声
    // Set sound effects or change voice
    [[ThunderManager sharedManager] setSoundEffectAndVoiceChanger:indexPath.row];

    
    SoundEffectSelectCell *currentCell = [_tableView cellForRowAtIndexPath:indexPath];
    currentCell.selectedMarkImageView.hidden = NO;
}


@end
