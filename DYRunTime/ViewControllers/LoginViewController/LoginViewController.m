//
//  LoginViewController.m
//  DYRunTime
//
//  Created by tarena on 15/11/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "LoginViewController.h"
#import "UMSocial.h"
#import "WXApi.h"
#import <UIImageView+AFNetworking.h>


#define effectAlpha 0.7
#define kMagnitude 1 //重力强度
#define contentViewHeight 70
#define iconWidth 50 //登录按钮高度
#define pathY 0.6 //contentView 下降的高度比例
#define userIconHeight 100
#define userIconWidth 80
@interface LoginViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIImageView *userIcon;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation LoginViewController
- (UIImageView *)userIcon{
    if (_userIcon == nil) {
        _userIcon = [UIImageView new];
        [self.view addSubview:_userIcon];
        _userIcon.layer.cornerRadius = userIconWidth /2;
        _userIcon.layer.masksToBounds = YES;
    }
    return _userIcon;
}
- (UIDynamicAnimator *)animator{
    if (_animator == nil) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc]initWithItems:@[self.contentView]];
        //设置重力强度
        gravity.magnitude = kMagnitude;
        gravity.gravityDirection = CGVectorMake(0, 1);
        [_animator addBehavior:gravity];
        
        //添加碰撞行为
        UICollisionBehavior *collision = [[UICollisionBehavior alloc]initWithItems:@[self.contentView]];
        //将外界的环境的边缘作为碰撞的边缘
        //self.view 的边缘作为边界
        collision.translatesReferenceBoundsIntoBoundary = YES;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,kWindowH * pathY, kWindowW, 1) cornerRadius:0.0];
        [collision addBoundaryWithIdentifier:@"MyPath" forPath:path];
        //添加到环境中
        //collision.collisionMode = UICollisionBehaviorModeEverything;
        [_animator addBehavior:collision];
    }
    return _animator;
}

-(UIView *)contentView{
    if (_contentView == nil) {
        //这里有动画不能用约束
        _contentView = [UIView new];
        [self.view addSubview:_contentView];
        _contentView.frame = CGRectMake(0, 0, kWindowW, contentViewHeight);
       // _contentView.backgroundColor = [UIColor redColor];
        UIImageView *loginBar = [[UIImageView alloc]initWithImage: [UIImage imageNamed:@"loginBar"]];
        [_contentView addSubview:loginBar];
        loginBar.frame = CGRectMake(0, 0, kWindowW, contentViewHeight - iconWidth);
        UIButton *wecatIcon = [[UIButton alloc]initWithFrame:CGRectMake(kWindowW/4 -iconWidth/2 , contentViewHeight - iconWidth, iconWidth, iconWidth)];
        [wecatIcon setBackgroundImage:[UIImage imageNamed:@"icon-wechat"] forState:UIControlStateNormal];
        UIButton *tecentIcon = [[UIButton alloc]initWithFrame:CGRectMake(kWindowW/2 -iconWidth/2, contentViewHeight - iconWidth, iconWidth, iconWidth)];
        [tecentIcon setBackgroundImage:[UIImage imageNamed:@"icon-tecent"] forState:UIControlStateNormal];
        UIButton *sinaIcon = [[UIButton alloc]initWithFrame:CGRectMake(kWindowW*3/4 -iconWidth/2, contentViewHeight - iconWidth, iconWidth, iconWidth)];
        [sinaIcon setBackgroundImage:[UIImage imageNamed:@"icon-sina"] forState:UIControlStateNormal];
        [_contentView addSubview:wecatIcon];
        wecatIcon.tag = 10;
        [_contentView addSubview:sinaIcon];
        sinaIcon.tag  = 20;
        [_contentView addSubview:tecentIcon];
        tecentIcon.tag = 30;
        [wecatIcon addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
        [sinaIcon addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
        [tecentIcon addTarget:self action:@selector(clickLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatLoginUI];
    [self getUserDataFromLocation];
}
- (void)getUserDataFromLocation{
    NSString *userDataPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                              stringByAppendingPathComponent:@"userData.bi"];
    //从归档文件中读取数据
    NSData *unArchivingData = [NSData dataWithContentsOfFile:userDataPath];
    // NSFileManager *fileManage
    //创建解档NSKeyedUnarchiver对象,并和读取后的数据进行绑定
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:unArchivingData];
    UMSocialAccountEntity *snsAccount = [unArchiver decodeObjectForKey:@"userData"];
    [self.userIcon setImageWithURL:[NSURL URLWithString:snsAccount.iconURL] placeholderImage:[UIImage imageNamed:@"avatar_blue_120"]];
}
- (void)creatLoginUI{
    
    UIImageView *backImageView= [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"run_login"]];
    backImageView.tag = 100;
    [self.view addSubview:backImageView];
    
    //添加毛玻璃
    UIVisualEffectView *effectView=[[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    effectView.alpha= effectAlpha;
    [self.view insertSubview:effectView atIndex:1];
    _effectView  = effectView;
    self.animator ;
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _effectView.frame = self.view.bounds;
    [self.view viewWithTag:100].frame = self.view.bounds;
    self.contentView.frame = CGRectMake(0, 0, kWindowW, contentViewHeight);
    self.userIcon.frame = CGRectMake((kWindowW - userIconWidth)/2, userIconHeight, userIconWidth, userIconWidth);
}

- (void) clickLogin:(UIButton *)sender{
    NSString *platformStr = nil;
    switch (sender.tag) {
        case 10:
            platformStr = UMShareToWechatSession;
            break;
        case 20:
            platformStr = UMShareToSina;
            break;
        case 30:
            platformStr = UMShareToQzone;
            break;
        default:
            break;
    }
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformStr];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformStr];
            
            DDLogInfo(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            [self.userIcon setImageWithURL:[NSURL URLWithString:snsAccount.iconURL] placeholderImage:[UIImage imageNamed:@"avatar_blue_120"]];
             //归档
            NSMutableData *data = [NSMutableData new];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
            [archiver encodeObject:snsAccount forKey:@"userData"];
            //真正执行编码动作结束
            [archiver finishEncoding];
            
            //写入归档文件
            NSString *userDataPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"userData.bi"];
            NSLog(@"归档文件路径：%@",userDataPath);
            [data writeToFile:userDataPath atomically:YES];
        }});
}

@end
