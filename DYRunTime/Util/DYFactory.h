//
//  DYFactory.h
//  DYRunTime
//
//  Created by tarena on 15/11/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <Foundation/Foundation.h>
extern UIButton *leftBtn;

@interface DYFactory : NSObject
/** 向某个控制器上，添加login按钮 */
+ (void)addLoginItemToVC:(UIViewController *)vc;

/** 向某个控制器上添加定位图标按钮 */
+ (void)addLocationItemToVc:(UIViewController *)vc;
/** 向某个服务器上添加login按钮和定位图标按钮 */
+ (void) addAllItemsToVC:(UIViewController *)vc;
@end
