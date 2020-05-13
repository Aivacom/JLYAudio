//
//  UIViewController+BaseViewController.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/21.
//

#import "UIViewController+BaseViewController.h"
#include <objc/message.h>
#import "CommonMacros.h"
#import "UIImage+Additions.h"


static char const * const kBackBarButtonActionKey = "kBackBarButtonActionKey";


@implementation UIViewController (BaseSetup)



#pragma mark - Public


+ (void)initialize {
    [self setGlobalBackBarButtonItemImage:kImageNamed(@"nav_btn_back")];
    [self setGlobalBackgroundColor:[UIColor whiteColor]];
}


static UIImage *globalBackBarButtonItemImage = nil;
+ (void)setGlobalBackBarButtonItemImage:(UIImage *)image  {
    globalBackBarButtonItemImage = image;
}

static UIColor *globalBackgroundColor = nil;
+ (void)setGlobalBackgroundColor:(UIColor *)color  {
    globalBackgroundColor = color;
}

- (void)setupNavigationBarWithBarTintColor:(UIColor *)barTintColor
            titleColor:(UIColor *)titleColor
             titleFont:(UIFont *)font
eliminateSeparatorLine:(BOOL)yesOrNo {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if ([self isKindOfClass:[UINavigationController class]]) {
        navigationBar = ((UINavigationController *)self).navigationBar;
    }
    
    navigationBar.barTintColor = barTintColor;
    navigationBar.tintColor = titleColor;

    NSDictionary *attributes = @{NSForegroundColorAttributeName:titleColor, NSFontAttributeName:font};
    [navigationBar setTitleTextAttributes:attributes];
    
    if (yesOrNo) {
        UIImage *clearImage = [UIImage imageWithColor:[UIColor clearColor]];
        navigationBar.shadowImage = clearImage;
    }
}



- (void)setupBackBarButtonItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:globalBackBarButtonItemImage style:UIBarButtonItemStylePlain target:self action:@selector(p_onBackButtonClick:)];

}

- (void)setBackBarButtonItemAction:(SEL)action {
    objc_setAssociatedObject(self, kBackBarButtonActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setupBaseSetting {
    if (globalBackgroundColor) {
        self.view.backgroundColor = globalBackgroundColor;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)setupCommonSetting {
    [self setupBackBarButtonItem];
    [self setupBaseSetting];
}



#pragma mark - Private

- (void)p_onBackButtonClick:(id)sender {
    SEL action = NSSelectorFromString(self.backBarButtonAction);
    NSMethodSignature *signature = [self methodSignatureForSelector:action];
    
    if (signature) {
        if (signature.numberOfArguments == 2) {
            ((void (*)(id, SEL))objc_msgSend)(self, action);
        } else if (signature.numberOfArguments == 3) {
            ((void (*)(id, SEL, id))objc_msgSend)(self, action, sender);
        }
    } else {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Get or Set

- (NSString *)backBarButtonAction {
    NSString *selector = objc_getAssociatedObject(self, kBackBarButtonActionKey);
    return selector;
}



@end
