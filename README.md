# 基于Hook的无侵入埋点

## 埋点
埋点是一个开发中常需要用到的东西，这篇文章主要介绍一下三种常用的埋点场景如何做到无侵入埋点，Controller 页面进入和退出、Button 点击和 Cell 点击。
具体的思路就是 hook 相关的方法，在 hook 的方法里面做埋点。这里面需要注意的就两点：hook 方法和标识唯一性；

### Controller 页面进入和退出
Controller 的进入和退出，我们很容易就能想到 `viewWillAppear`和`viewWillDisappear`，所以接下来操作就很简单了：
```
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
```

记录标识的唯一性，这里直接用 class name 来标识就好：
```
NSLog(@"埋点：%@",[NSString stringWithFormat:@"%@ Appear",NSStringFromClass([self class])]);
```

### Button 点击
对于 Button 的点击，思路是一样的，hook 点击相关的方法，不过我们 hook 的是`UIControl`的`sendAction:to:forEvent:`：
```
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(sendAction:to:forEvent:);
        SEL toSelector = @selector(hook_sendAction:to:forEvent:);
        [Hook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}
```
对于 Button 点击的唯一标识，我们只需要使用记录调用的 target 和 action 就行了：
```
NSString *actionString = NSStringFromSelector(action);
NSString *targetName = NSStringFromClass([target class]);
NSLog(@"埋点：%@",[NSString stringWithFormat:@"%@ %@",targetName,actionString]);
```

### Cell 点击
Cell 点击的 hook 思路就稍微不太一样了，Cell 点击调用的是 UITableView 的 delegate 类的方法，而不是 UITableView 或 UITableViewCell 的方法。这时候，我们可以倒过来推导这件事情：
1. 为了达到无痕埋点需要 hook `tableView:didSelectRowAtIndexPath:`方法
2. `tableView:didSelectRowAtIndexPath:` 在 delegate 的类中
3. 所以我们需要 hook 的是 delegate 的类中的 `tableView:didSelectRowAtIndexPath:` 方法
4. 要 hook delegate 的类，我们就需要获取设置 delegate 的时候
5. 所以我们需要 hook UITableView 的`setDelegate:`方法

到此我们就清楚需要做什么了，我们需要做两次 hook，一次是 hook UITableView 的`setDelegate:`，一次是 hook delegate 的类中的 `tableView:didSelectRowAtIndexPath:`。

这时还有一个问题就是如何 hook delegate 类的方法？具体思路是这样，新建一个中间类，让它来跟 delegate 类做方法交换，代码如下：
```
- (void)hook_setDelegate:(id<UITableViewDelegate>)delegate {
    // 获得delegate的实际调用类
    Class aClass = [delegate class];
    // 传递给TableDelegateTool来交互方法
    [TableDelegateTool exchangeTableViewDelegateMethod:aClass];
    [self hook_setDelegate:delegate];
}
```
TableDelegateTool.m
```
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
```

这里 Cell 点击的唯一标识，我们可以用 class name 和 NSIndexPath 来处理。


## 总结
最后我们回到实用性的角度来看一下，无侵入埋点固然爽，它能直接把场景下的所有数据都采集起来，减少客户端的手动埋点的工作量。但是有时收集的数据不全是我们需要的，结果就是还要在服务端进行数据的标注和分析，才能得到我们想要的埋点数据。所以无侵入埋点的方案维护成本是比较高的，更适合用在一些功能稳定性高的地方。

[Demo](https://github.com/YakirLove/AllFillingPoint)
