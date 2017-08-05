//
//  HQActionSheet.h
//  Catches
//
//  Created by 刘欢庆 on 2016/12/27.
//  Copyright © 2016年 solot. All rights reserved.
//

#import <UIKit/UIKit.h>

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
