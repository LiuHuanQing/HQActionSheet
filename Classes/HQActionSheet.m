//
//  HQActionSheet.m
//  Catches
//
//  Created by 刘欢庆 on 2016/12/27.
//  Copyright © 2016年 solot. All rights reserved.
//

#import "HQActionSheet.h"
#define COLOR_WITH_HEX(HEX) [UIColor colorWithRed:((HEX & 0xFF0000) >> 16)/255.0 green:((HEX & 0xFF00) >> 8)/255.0 blue:(HEX & 0xFF)/255.0 alpha:1]

#define HQASTitleHeight 60.0f
#define HQASButtonHeight  49.0f
#define HQASButTitleFont [UIFont systemFontOfSize:18.0f]
#define HQASButColor [UIColor colorWithWhite:1.0 alpha:0.2]
#define HQASBTNTAG 100999
#define HQASBGTAG 101999

@interface HQActionSheet()

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, strong) NSMutableDictionary *handlers;
@property (nonatomic, strong) NSMutableSet *destructives;

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, weak) UIView *maskView;
@property (nonatomic, weak) UIVisualEffectView *btnBgView;
@property (nonatomic, weak) UIButton *cancelButton;
//@property (nonatomic, strong) NSMutableArray *destructive;

@property (nonatomic, assign) BOOL lastPopDisable;
@end
@implementation HQActionSheet

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if(self)
    {
        self.hidden = YES;
        _title = title;
        _cancelButtonIndex = -1;
    }
    return self;
}

- (void)showInView:(UIView *)superView
{
    _superView = superView;
    [superView addSubview:self];
    [self loadSubView];
    [self show];
}

- (void)setHandler:(void (^)(void))block forButtonAtIndex:(NSInteger)index
{
    if (block)
    {
        self.handlers[@(index)] = [block copy];
    }
    else
    {
        [self.handlers removeObjectForKey:@(index)];
    }
}

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSInteger index = 0;
    if(title)
    {
        [self.buttonTitles addObject:title];
        index =  self.buttonTitles.count - 1;
        [self setHandler:block forButtonAtIndex:index];
    }
    return index;
}

- (NSInteger)setCancelButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSInteger cancelButtonIndex = [self addButtonWithTitle:title handler:block];
    self.cancelButtonIndex = cancelButtonIndex;
    return cancelButtonIndex;
}

- (void)addDestructiveButtonWithTitle:(NSString *)title handler:(void (^)(void))block
{
    NSInteger index = [self addButtonWithTitle:title handler:block];
    [self.destructives addObject:@(index)];
}



- (void)loadSubView
{
    CGRect frame = self.superView.bounds;
    CGFloat width = CGRectGetWidth(frame);
    self.frame = frame;
    UIView *maskView = [[UIView alloc] initWithFrame:frame];
    maskView.alpha = 0;
    maskView.backgroundColor = COLOR_WITH_HEX(0x141414);
    [self addSubview:maskView];
    self.maskView = maskView;
    
    UIVisualEffectView *btnBgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [self addSubview:btnBgView];
    self.btnBgView = btnBgView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [maskView addGestureRecognizer:tap];
    
    CGFloat titleHeight = 0;
    if(self.title)
    {
        titleHeight = HQASTitleHeight;
        UIVisualEffectView *btnBg = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        btnBg.frame = CGRectMake(0, 0, width, titleHeight);
        [btnBgView addSubview:btnBg];

        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, titleHeight)];
        titleLab.text = _title;
        titleLab.numberOfLines = 0;
        titleLab.textColor = COLOR_WITH_HEX(0x7D7D7D);
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:13.0f];
        titleLab.backgroundColor = HQASButColor;
        [btnBgView addSubview:titleLab];
    }

    NSString *cancelButtonTitle;
    if(_cancelButtonIndex == -1)
    {
        cancelButtonTitle = @"取消";
    }
    else
    {
        cancelButtonTitle = self.buttonTitles[_cancelButtonIndex];
        [self.buttonTitles removeObjectAtIndex:_cancelButtonIndex];
    }
    for (int i = 0; i < _buttonTitles.count; i++)
    {
        CGFloat originY = titleHeight + HQASButtonHeight * i;

        UIVisualEffectView *btnBg = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        btnBg.tag                 = HQASBGTAG + i;
        btnBg.frame               = CGRectMake(0, originY, width, HQASButtonHeight);
        [btnBgView addSubview:btnBg];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addObserver:button];
        button.tag             = HQASBTNTAG + i;
        button.backgroundColor = HQASButColor;
        button.titleLabel.font = HQASButTitleFont;
        [button setTitle:_buttonTitles[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[_destructives containsObject:@(i)]?[UIColor redColor]:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, originY, width, HQASButtonHeight);
        [btnBgView addSubview:button];
        
        if(i > 0)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
            line.backgroundColor = COLOR_WITH_HEX(0xD2D2D2);
            line.frame = CGRectMake(0, originY, width, 0.5);
            [btnBgView addSubview:line];
        }

    }
    
    CGFloat originY = titleHeight + HQASButtonHeight * _buttonTitles.count + 5;
    
    UIVisualEffectView *btnBg = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    btnBg.tag                 = HQASBGTAG + _buttonTitles.count;
    btnBg.frame               = CGRectMake(0, originY, width, HQASButtonHeight);
    [btnBgView addSubview:btnBg];

    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addObserver:cancelButton];
    cancelButton.tag             = HQASBTNTAG + _buttonTitles.count;
    cancelButton.backgroundColor = HQASButColor;
    cancelButton.titleLabel.font = HQASButTitleFont;
    cancelButton.frame           = CGRectMake(0, originY, width, HQASButtonHeight);
    [cancelButton addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [btnBgView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    CGFloat height = originY + HQASButtonHeight;
    originY = CGRectGetHeight(frame) - height;
    btnBgView.frame = CGRectMake(0, originY, width, height);
    
    
}

- (void)show
{
    self.hidden = NO;
    self.btnBgView.transform = CGAffineTransformMakeTranslation(0, self.btnBgView.frame.size.height);

    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0.3;
        self.btnBgView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.maskView.alpha = 0;
        self.btnBgView.transform = CGAffineTransformMakeTranslation(0, self.btnBgView.frame.size.height);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeAllObserver];
        [self removeFromSuperview];
    }];
}

- (NSMutableArray *)buttonTitles
{
    if(!_buttonTitles)
    {
        _buttonTitles = [NSMutableArray array];
    }
    return _buttonTitles;
}

- (NSMutableDictionary *)handlers
{
    if(!_handlers)
    {
        _handlers = [NSMutableDictionary dictionary];
    }
    return _handlers;
}

- (NSMutableSet *)destructives
{
    if(!_destructives)
    {
        _destructives = [NSMutableSet set];
    }
    return _destructives;
}

- (void)addObserver:(UIButton *)button
{
    [button addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver:(UIButton *)button
{
    [button removeObserver:self forKeyPath:@"highlighted"];
}

- (void)removeAllObserver
{
    for (int i = 0; i < _buttonTitles.count; i++)
    {
        UIButton *btn = [self viewWithTag:i + HQASBTNTAG];
        [self removeObserver:btn];
    }
    [self removeObserver:self.cancelButton];
}

- (void)didClickButton:(UIButton *)btn
{
    void (^block)(void) = self.handlers[@(btn.tag - HQASBTNTAG)];;
    if(block)block();
    [self hide];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    UIButton *button = (UIButton *)object;
    if ([keyPath isEqualToString:@"highlighted"])
    {
        UIVisualEffectView *btnBg = [self viewWithTag:button.tag - HQASBTNTAG + HQASBGTAG];
        if (button.highlighted)
        {
            btnBg.alpha = 0.1;
        }
        else
        {
            btnBg.alpha = 1.0;
        }
    }
}


@end
