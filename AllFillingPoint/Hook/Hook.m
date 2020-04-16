//
//  Hook.m
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import "Hook.h"
#import <objc/runtime.h>

@implementation Hook

+ (void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    Class class = classObject;    // 得到被替换类的实例方法
    Method fromMethod = class_getInstanceMethod(class, fromSelector);    // 得到替换类的实例方法
    Method toMethod = class_getInstanceMethod(class, toSelector);        // class_addMethod 返回成功表示被替换的方法没实现，然后会通过 class_addMethod 方法先实现；返回失败则表示被替换方法已存在，可以直接进行 IMP 指针交换
    if(class_addMethod(class, fromSelector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {      // 进行方法的替换
        class_replaceMethod(class, toSelector, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
        
    } else {      // 交换 IMP 指针
        method_exchangeImplementations(fromMethod, toMethod);
        
    }
    
}

+ (void)hookClass:(Class)originalClass to:(Class)replacedClass fromSelector:(SEL)originalSel toSelector:(SEL)replacedSel
{
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);

        
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
        
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
        // 将样替换的方法往代理类中添加, (一般都能添加成功, 因为代理类中不会有我们自定义的函数)
    BOOL didAddMethod = class_addMethod(originalClass,
                                        replacedSel,
                                        replacedMethodIMP,
                                        method_getTypeEncoding(replacedMethod));
        
    if (didAddMethod) {
        NSLog(@"class_addMethod succeed --> (%@)", NSStringFromSelector(replacedSel));
        // 获取新方法在代理类中的地址
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 交互原方法和自定义方法
        method_exchangeImplementations(originalMethod, newMethod);
    
    } else {// 如果失败, 则证明自定义方法在代理方法中, 直接交互就可以
        NSLog(@"class_addMethod fail --> (%@)", NSStringFromSelector(replacedSel));
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

@end
