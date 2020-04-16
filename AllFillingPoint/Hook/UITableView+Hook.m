//
//  UITableView+Hook.m
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import "UITableView+Hook.h"
#import "Hook.h"
#import "TableDelegateTool.h"

@implementation UITableView (Hook)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(setDelegate:);
        SEL toSelector = @selector(hook_setDelegate:);
        [Hook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)hook_setDelegate:(id<UITableViewDelegate>)delegate {
    // 获得delegate的实际调用类
    Class aClass = [delegate class];
    // 传递给TableDelegateTool来交互方法
    [TableDelegateTool exchangeTableViewDelegateMethod:aClass];
    [self hook_setDelegate:delegate];
}

@end
