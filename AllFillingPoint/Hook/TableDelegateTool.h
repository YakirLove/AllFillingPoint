//
//  TableDelegateTool.h
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TableDelegateTool : NSObject<UITableViewDelegate>

+ (void)exchangeTableViewDelegateMethod:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
