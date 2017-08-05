# HQActionSheet

公司要跟微信一样ActionSheet,没什么可说的

> 刚从内网gitlab转过来,没上pod,很多东西暂时没有

```objc
@interface HQActionSheet : UIView

//标题
@property (nonatomic, strong) NSString *title;

//取消按钮下标
@property (nonatomic) NSInteger cancelButtonIndex;

//初始化
- (instancetype)initWithTitle:(NSString *)title;

//添加按钮
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block;

//设置取消按钮
- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block;

//设置警告按钮(红色)
- (void)addDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block;

//显示
- (void)showInView:(UIView *)view;
@end
```
