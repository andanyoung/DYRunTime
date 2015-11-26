//
//  LoginView.m
//  DYRunTime
//
//  Created by tarena on 15/11/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "LoginView.h"
#define effectAlpha 0.3
#define kMagnitude 1 //重力强度
@interface LoginView ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIVisualEffectView *effectView;
@end
@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.868f]];
        // Do any additional setup after loading the view.
        //添加毛玻璃
        //    UIVisualEffectView *effectView=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        //    effectView.alpha= effectAlpha;
        //    //[self.view insertSubview:effectView atIndex:1];
        //    _effectView  = effectView;
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"weixin"]];
        [self addSubview:imageView];
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc]initWithItems:@[imageView]];
        //设置重力强度
        gravity.magnitude = kMagnitude;
        gravity.gravityDirection = CGVectorMake(0, 1);
        [_animator addBehavior:gravity];
        //添加碰撞行为
        UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:@[imageView]];
        //将外界的环境的边缘作为碰撞的边缘
        //self.view 的边缘作为边界
        collision.translatesReferenceBoundsIntoBoundary = YES;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
