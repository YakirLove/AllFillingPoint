//
//  TableDelegateTool.m
//  AllFillingPoint
//
//  Created by 吴焰基 on 2020/4/15.
//  Copyright © 2020 吴焰基. All rights reserved.
//

#import "TableDelegateTool.h"
#import "Hook.h"

@implementation TableDelegateTool

+ (void)exchangeTableViewDelegateMethod:(Class)aClass
{
    [Hook hookClass:aClass to:self fromSelector:@selector(tableView:didSelectRowAtIndexPath:) toSelector:@selector(hook_tableView:didSelectRowAtIndexPath:)];
}

-(void)hook_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"埋点：%@",[NSString stringWithFormat:@"%@ tableViewDidSelect section:%ld row:%ld",NSStringFromClass([self class]),(long)indexPath.section,(long)indexPath.row]);
    [self hook_tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
