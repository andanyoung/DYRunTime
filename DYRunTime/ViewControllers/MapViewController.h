//
//  MapViewController.h
//  DYRunTime
//
//  Created by tarena on 15/10/15.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DYMainViewController.h"

typedef enum : NSUInteger {
    /** 用于定位 */
    MapViewTypeLocation,
    /** 用于运动轨迹 */
    MapViewTypeRunning,
    /** 用于回放轨迹细节 */
    MapViewTypeQueryDetail 
} MapViewType;

@interface MapViewController : UIViewController
/** 保存经纬度信息 */
@property (strong, nonatomic)NSMutableArray<CLLocation *> *locations;
/** 判断是定位还是，运动 */
@property (nonatomic) MapViewType type;
/** 用于peek上拉，保存peek的选项 */
@property (nonatomic, weak) NSIndexPath *indexParh;
@property (nonatomic, weak) DYMainViewController *mainVC;

@end
