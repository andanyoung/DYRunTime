//
//  DYLocationManager.h
//  DYRunTime
//
//  Created by tarena on 15/10/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class DYLocationManager,BMKLocationService,BMKUserLocation;

@protocol DYLocationManagerDelegate <NSObject>
/**
 *  当位置发生变化时调用
 */
- (void)locationManage:(DYLocationManager *)manager didUpdateLocations:(NSArray <CLLocation *>*)locations;

@optional
/**
 *  当定位状态发生变化时调用,开启定位/停止定位
 */
- (void)locationManage:(DYLocationManager *)manager didChangeUpdateLocationState:(BOOL)running;
@end


@interface DYLocationManager : NSObject

@property (nonatomic,strong) NSMutableArray<CLLocation *> *locations;

@property (nonatomic, weak)id<DYLocationManagerDelegate> delegate;

/*  用于保存总记录
 */

@property (nonatomic) double totalDistanc;
@property (nonatomic) double speed;
/** 定位开始时间 */
@property (nonatomic, strong) NSDate *startLocationDate;
/** 是否是运动记录 */
@property (nonatomic,getter=isRunning) BOOL running;

//用于显示当前的位子
@property (nonatomic, strong) BMKUserLocation *userLocation;

+ (DYLocationManager *)shareLocationManager;
/**
 * 开始定位
 */
- (void)startUpdatingLocation;

/**
 * 结束定位
 */
- (void)stopUpdatingLocation;
@end
