//
//  UIViewController+Hook.m
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import "UIViewController+Hook.h"
#import "Hook.h"

@implementation UIViewController (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        SEL fromSelectorAppear = @selector(viewWillAppear:);
        SEL toSelectorAppear = @selector(hook_viewWillAppear:);
        [Hook hookClass:self fromSelector:fromSelectorAppear toSelector:toSelectorAppear];
        
        SEL fromSelectorDisappear = @selector(viewWillDisappear:);
        SEL toSelectorDisappear = @selector(hook_viewWillDisappear:);
        
        [Hook hookClass:self fromSelector:fromSelectorDisappear toSelector:toSelectorDisappear];
    });
}

- (void)hook_viewWillAppear:(BOOL)animated {
    // 先执行插入代码，再执行原 viewWillAppear 方法
    [self insertToViewWillAppear];
    [self hook_viewWillAppear:animated];
}

- (void)hook_viewWillDisappear:(BOOL)animated {
    // 执行插入代码，再执行原 viewWillDisappear 方法
    [self insertToViewWillDisappear];
    [self hook_viewWillDisappear:animated];
}


- (void)insertToViewWillAppear {
    // 在 ViewWillAppear 时进行日志的埋点
    NSString *classStr = NSStringFromClass([self class]);
    if(![classStr isEqualToString:@"UIEditingOverlayViewController"] &&
       ![classStr isEqualToString:@"UIInputWindowController"] &&
       ![classStr isEqualToString:@"UICompatibilityInputViewController"] &&
       ![classStr isEqualToString:@"UIApplicationRotationFollowingControllerNoTouches"]) {
        NSLog(@"埋点：%@",[NSString stringWithFormat:@"%@ Appear",classStr]);
    }
}
- (void)insertToViewWillDisappear {
    // 在 ViewWillDisappear 时进行日志的埋点
    NSString *classStr = NSStringFromClass([self class]);
    if(![classStr isEqualToString:@"UIEditingOverlayViewController"] &&
       ![classStr isEqualToString:@"UIInputWindowController"] &&
       ![classStr isEqualToString:@"UICompatibilityInputViewController"] &&
       ![classStr isEqualToString:@"UIApplicationRotationFollowingControllerNoTouches"]) {
        NSLog(@"埋点：%@",[NSString stringWithFormat:@"%@ Disappear",classStr]);
    }

}

@end
