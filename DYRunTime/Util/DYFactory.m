//
//  DYFactory.m
//  DYRunTime
//
//  Created by tarena on 15/11/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYFactory.h"
#import "DYLocationManager.h"
#import "MapViewController.h"
#import "LoginViewController.h"
#import "UMSocialAccountManager.h"


#define locationIconWidth 20
#define locationIconHeight 30


@implementation DYFactory
/** 向某个控制器上，添加login按钮 */
+ (void)addLoginItemToVC:(UIViewController *)vc{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString *userDataPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                              stringByAppendingPathComponent:@"userData.bi"];
    //从归档文件中读取数据
    NSData *unArchivingData = [NSData dataWithContentsOfFile:userDataPath];
   // NSFileManager *fileManage
    //创建解档NSKeyedUnarchiver对象,并和读取后的数据进行绑定
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:unArchivingData];
    UMSocialAccountEntity *snsAccount = [unArchiver decodeObjectForKey:@"userData"];
    //- (nullable UIImage *)cachedImageForRequest:(NSURLRequest *)request;
    //从缓存中读取图片
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:snsAccount.iconURL]]];
    if (image==nil){
        image = [UIImage imageNamed:@"avatar_blue_120"];
    }
    
#warning 缓存问题
    btn.bounds = CGRectMake(0, 0, 40, 40);
    
    btn.imageView.layer.cornerRadius = 20;
    //[btn setBackgroundImage: forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    btn.imageView.bounds = btn.bounds;
    [btn bk_addEventHandler:^(id sender) {
        LoginViewController *loginVC = [LoginViewController new];
        loginVC.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:loginVC animated:YES];
  
    } forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    //使用弹簧控件缩小菜单按钮和边缘距离
    UIBarButtonItem *spaceItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10;
    vc.navigationItem.leftBarButtonItems = @[spaceItem ,menuItem];
}


/** 向某个控制器上添加定位图标按钮 */
+ (void)addLocationItemToVc:(UIViewController *)vc{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundImage:[UIImage imageNamed:@"activity_location"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, locationIconWidth, locationIconHeight);
    [button bk_addEventHandler:^(id sender) {
        
        MapViewController *mapVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"map"];
        DYLocationManager *locationManager = [DYLocationManager shareLocationManager];
        mapVc.locations = [NSMutableArray arrayWithArray:locationManager.locations];
        mapVc.type = locationManager.running;
        [vc presentViewController:mapVc animated:YES completion:nil];

    } forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    vc.navigationItem.rightBarButtonItem = item;
}

+ (void) addAllItemsToVC:(UIViewController *)vc{
    [self addLoginItemToVC:vc];
    [self addLocationItemToVc:vc];
}


@end
