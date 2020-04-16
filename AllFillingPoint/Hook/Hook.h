//
//  Hook.h
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Hook : NSObject

+ (void)hookClass:(Class)classObject fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

+ (void)hookClass:(Class)originalClass to:(Class)replacedClass fromSelector:(SEL)originalSel toSelector:(SEL)replacedSel;

@end

NS_ASSUME_NONNULL_END
