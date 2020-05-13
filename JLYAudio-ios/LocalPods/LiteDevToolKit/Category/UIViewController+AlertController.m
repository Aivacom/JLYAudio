//
//  UIViewController+Alert.m
//  LiteDevToolKit
//
//  Created by iPhuan on 2019/8/21.
//

#import "UIViewController+AlertController.h"
#import "CommonMacros.h"



NSString *const ActionSheetShowErrorMessage = @"The modalPresentationStyle of a UIAlertController with this style is UIModalPresentationPopover. You must provide location information for this popover through the alert controller's popoverPresentationController. You must provide either a sourceView and sourceRect or a barButtonItem.";

@implementation UIViewController (Alert)



- (UIAlertController *)popupAlertViewWithMessage:(NSString *)message {
    UIAlertController *alertController = [self alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert handler:nil cancelActionTitle:nil otherActionTitle:@"确定" args:nil];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}


- (UIAlertController *)popupAlertViewWithTitle:(NSString *)title
                        message:(NSString *)message
                        handler:(AlertActionHandler)handler
              cancelActionTitle:(NSString *)cancelActionTitle
             confirmActionTitle:(NSString *)confirmActionTitle {
    UIAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert handler:handler cancelActionTitle:cancelActionTitle otherActionTitle:confirmActionTitle args:nil];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}


- (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         handler:(AlertActionHandler)handler
               otherActionTitles:(NSString *)otherActionTitles, ... {
    va_list args;
    va_start(args, otherActionTitles);
    
    UIAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet handler:handler cancelActionTitle:@"取消" otherActionTitle:otherActionTitles args:args];
    va_end(args);
    
    BOOL canShowActionSheet = YES;
    if (alertController.popoverPresentationController) {
        canShowActionSheet = NO;
    }
    if (canShowActionSheet) {
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        kLog(@"Your application has presented a UIAlertController (<UIAlertController: %p>) of style UIAlertControllerStyleActionSheet. %@", alertController, ActionSheetShowErrorMessage);
    }
    return alertController;
}

- (UIAlertController *)actionSheetWithTitle:(NSString *)title
                                    message:(NSString *)message
                                    handler:(AlertActionHandler)handler
                          otherActionTitles:(NSString *)otherActionTitles, ... {
    va_list args;
    va_start(args, otherActionTitles);
    
    UIAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet handler:handler cancelActionTitle:@"取消" otherActionTitle:otherActionTitles args:args];
    
    va_end(args);
    
    return alertController;
}


- (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                        message:(NSString *)message
                                 preferredStyle:(UIAlertControllerStyle)preferredStyle
                                        handler:(AlertActionHandler)handler
                              cancelActionTitle:(NSString *)cancelActionTitle
                               otherActionTitle:(NSString *)otherActionTitle
                                           args:(va_list)args {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    NSInteger index = -1;
    if (otherActionTitle) {
        NSString *actionTitle = otherActionTitle;
        while (actionTitle) {
            index++;
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (handler) {
                    handler(action, index);
                }
            }];
            [alertController addAction:alertAction];
            if (args) {
                actionTitle = va_arg(args, NSString *);
            } else {
                actionTitle = nil;
            }
        }
    }
    
    if (cancelActionTitle) {
        index++;
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (handler) {
                handler(action, index);
            }
        }];
        [alertController addAction:alertAction];
    }
    
    return alertController;
}

- (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         handler:(AlertActionHandler)handler
            otherActionTitleList:(NSArray *)otherActionTitleList {
    
    UIAlertController *alertController = [self actionSheetWithTitle:title message:message handler:handler cancelActionTitle:@"取消" otherActionTitleList:otherActionTitleList];
    
    BOOL canShowActionSheet = YES;
    if (alertController.popoverPresentationController) {
        canShowActionSheet = NO;
    }
    if (canShowActionSheet) {
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        kLog(@"Your application has presented a UIAlertController (<UIAlertController: %p>) of style UIAlertControllerStyleActionSheet. %@", alertController, ActionSheetShowErrorMessage);
    }
    return alertController;
    
}


- (UIAlertController *)actionSheetWithTitle:(NSString *)title
                                    message:(NSString *)message
                                    handler:(AlertActionHandler)handler
                          cancelActionTitle:(NSString *)cancelActionTitle
                       otherActionTitleList:(NSArray *)otherActionTitleList {
    
    if (otherActionTitleList.count == 0) {
        return nil;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [otherActionTitleList enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (handler) {
                handler(action, idx);
            }
        }];
        [alertController addAction:alertAction];
    }];
    
    
    if (cancelActionTitle) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (handler) {
                handler(action, otherActionTitleList.count);
            }
        }];
        [alertController addAction:alertAction];
    }
    
    return alertController;
}



@end

