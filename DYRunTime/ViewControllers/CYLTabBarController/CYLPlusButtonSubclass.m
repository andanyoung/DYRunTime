//
//  CYLPlusButtonSubclass.m
//  DWCustomTabBarDemo
//
//  Created by 微博@iOS程序犭袁 (http://weibo.com/luohanchenyilong/) on 15/10/24.
//  Copyright (c) 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlusButtonSubclass.h"
#import "DYLocationManager.h"
#import "DYMainViewController.h"

@interface CYLPlusButtonSubclass () {
    CGFloat _buttonImageHeight;
}
@end
@implementation CYLPlusButtonSubclass

#pragma mark -
#pragma mark - Life Cycle

+(void)load {
    [super registerSubclass];
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}


//上下结构的 button
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 控件大小,间距大小
    CGFloat const imageViewEdge = self.bounds.size.width ;
    CGFloat const centerOfViewX = self.bounds.size.width * 0.5;
    CGFloat const centerOfViewY = self.bounds.size.height * 0.5 - 2;
   // CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
   // CGFloat const verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdge;
   // CGFloat const verticalMargin  = verticalMarginT / 2;
    
    // imageView 和 titleLabel 中心的 Y 值
   // CGFloat const centerOfImageView  = verticalMargin + imageViewEdge * 0.5;
  //  CGFloat const centerOfTitleLabel = imageViewEdge  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
    
    //imageView position 位置
    self.imageView.bounds = CGRectMake(0, 0, imageViewEdge, imageViewEdge);
    self.imageView.center = CGPointMake(centerOfViewX, centerOfViewY);
    
    //title position 位置
  //  self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
   // self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
}

/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
+ (instancetype)plusButton
{

    UIImage *buttonImage = [UIImage imageNamed:@"post_normal"];
    UIImage *selectedImage = [UIImage imageNamed:@"post_selected"];

    CYLPlusButtonSubclass* button = [CYLPlusButtonSubclass buttonWithType:UIButtonTypeCustom];

    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
   // [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    //[button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    button.imageView.contentMode = 1;
    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

#pragma mark -
#pragma mark - Event Response

- (void)clickPublish {
    self.selected = !self.isSelected;
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.selectedIndex = 1;
    UIViewController *viewController = tabBarController.selectedViewController;
    DYMainViewController *mainVC = ((UINavigationController *)viewController).viewControllers[0];
    DYLocationManager *locationManager = [DYLocationManager shareLocationManager];
    
    mainVC.locationManager = locationManager;//保持住
    if (!locationManager.running) {
        locationManager.delegate = mainVC;
        [locationManager startUpdatingLocation];
        
        [MobClick event:@"startRun"];
    }else{
        
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
    }
}


#pragma mark - CYLPlusButtonSubclassing

//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 3;
//}

+ (CGFloat)multiplerInCenterY {
    return  0.3;
}

@end
