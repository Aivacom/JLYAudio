//
//  FeedbackViewController.m
//  FeedbackComponent
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 JLY. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommonMacros.h"
#import "Masonry.h"
#import "Utils.h"
#import "UIImage+Additions.h"
#import "UITextView+PlaceHolder.h"
#import "FeedbackRequestHelper.h"
#import "AFNetworkReachabilityManager.h"
#import "UIViewController+BaseViewController.h"
#import "MBProgressHUD+HUD.h"



@interface FeedbackViewController ()
@property (nonatomic, strong) UITextView *feedbackTextView;
@property (nonatomic, copy) NSString *uid;



@end

@implementation FeedbackViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    
    [self setupCommonSetting];
    [self setupNavigationBarWithBarTintColor:[UIColor whiteColor] titleColor:kColorHex(@"#333333") titleFont:[UIFont boldSystemFontOfSize:17] eliminateSeparatorLine:YES];
    
    // 强行设置浅色
    if (@available(iOS 13.0, *)) {
        self.navigationController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    
    
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 需要获取用户的网络类型
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


#pragma mark - Private

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIView *descView = [[UIView alloc] init];
    descView.backgroundColor = kColorHex(@"#F2F2F2");
    
    [self.view addSubview:descView];
    [descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 + kNavBarHeight);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(130);
    }];
    
    UILabel *versionLabel = [self titleLable];
    if ([FeedbackManager sharedManager].appSceneName.length) {
        versionLabel.text = [NSString stringWithFormat:@"当前版本：V%@-%@-%@", [Utils appVersion], [FeedbackManager sharedManager].appSceneName, [Utils appBuildVersion]];
    } else {
        versionLabel.text = [NSString stringWithFormat:@"当前版本：V%@-%@", [Utils appVersion], [Utils appBuildVersion]];
    }
    
    [descView addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(9);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(18);
    }];
    
    UILabel *descTitleLabel = [self titleLable];
    descTitleLabel.text = @"版本功能描述：";
    
    [descView addSubview:descTitleLabel];
    [descTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(versionLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(18);
    }];
    
    
    UITextView *descTextView = [[UITextView alloc] init];
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.editable = NO;
    descTextView.textColor = kColorHex(@"#666666");
    descTextView.font = [UIFont systemFontOfSize:13];
    descTextView.showsVerticalScrollIndicator = NO;
    descTextView.text = [FeedbackManager sharedManager].functionDesc;
    
    [descView addSubview:descTextView];
    [descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(descTitleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-17);
    }];
    
    
    
    self.feedbackTextView = [[UITextView alloc] init];
    _feedbackTextView.backgroundColor = [UIColor clearColor];
    _feedbackTextView.textColor = [UIColor blackColor];
    _feedbackTextView.font = [UIFont systemFontOfSize:14];
    _feedbackTextView.clipsToBounds = YES;
    _feedbackTextView.layer.borderWidth = 0.5;
    _feedbackTextView.layer.borderColor = kColorHex(@"#6666664D").CGColor;
    _feedbackTextView.layer.cornerRadius = 4;
    _feedbackTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 20);

    _feedbackTextView.placeholder = @"请输入反馈内容";
    
    [self.view addSubview:_feedbackTextView];
    [_feedbackTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(descView.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(143);
    }];
    
    
    UIButton *submitButton = [[UIButton alloc] init];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    UIImage *normalImage = [UIImage imageWithColor:kColorHex([FeedbackManager sharedManager].submitButtonNormalHexColor)];
    UIImage *highlightedImage = [UIImage imageWithColor:kColorHex([FeedbackManager sharedManager].submitButtonhighlightedHexColor)];
    submitButton.clipsToBounds = YES;
    submitButton.layer.cornerRadius = 6;


    
    [submitButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [submitButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(onSubmitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.feedbackTextView.mas_bottom).offset(30);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(40);
    }];
}

- (UILabel *)titleLable {
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.textColor = kColorHex(@"#666666");
    titleLable.font = [UIFont boldSystemFontOfSize:13];
    return titleLable;
}

#pragma mark - Public


- (instancetype)initWithUid:(NSString *)uid {
    self = [super init];
    if (self) {
        _uid = [uid copy];
    }
    return self;
}


#pragma mark - Action

- (void)onSubmitButtonClick {
    if (_feedbackTextView.text.length == 0 || [[_feedbackTextView.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0) {
        [MBProgressHUD showToast:@"请输入反馈内容"];
        return;
    }
    
    [MBProgressHUD showActivityIndicator];
    [FeedbackRequestHelper requestWithFeedbackContent:_feedbackTextView.text uid:_uid success:^{
        [MBProgressHUD showToast:@"反馈成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        });
    } failure:^(RequestFailedReason failedReason) {
        if (failedReason == RequestFailedReasonZipArchiveFailed) {
            [MBProgressHUD showToast:@"压缩日志文件失败，请稍后重试"];
        } else if (failedReason == RequestFailedReasonMissingParameter) {
            [MBProgressHUD showToast:@"请求参数缺失"];
        } else {
            [MBProgressHUD showToast:@"反馈失败，请稍后重试"];
        }
    }];
}



@end
