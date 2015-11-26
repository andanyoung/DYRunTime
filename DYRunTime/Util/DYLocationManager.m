//
//  DYLocationManager.m
//  DYRunTime
//
//  Created by tarena on 15/10/28.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYLocationManager.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#define minDistance 5
static BMKLocationService *locationService;
@interface DYLocationManager ()<BMKLocationServiceDelegate>

@end

@implementation DYLocationManager

- (NSMutableArray<CLLocation *> *)locations{
    if (!_locations) {
        _locations = [NSMutableArray new];
    }
    return _locations;
}


+(DYLocationManager *)shareLocationManager{
//    //单例
    static DYLocationManager *manager = nil;
    static dispatch_once_t oneToke;
    dispatch_once(&oneToke, ^{
        manager = [DYLocationManager new];
    });
    return manager;
}

#pragma mark - BMKLocationServiceDelegate

- (void)didFailToLocateUserWithError:(NSError *)error{
    DDLogWarn(@" 定位失败 error %@",error);
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation  {
    _userLocation = userLocation;
    
    CLLocation *location  = userLocation.location;
    // 如果此时位置更新的水平精准度大于10米，直接返回该方法
    // 可以用来简单判断GPS的信号强度
    //horizontalAccuracy:半径不确定性的中心点，以米为单位。 该地点的纬度和经度确定的圆的圆心，该值表示在该圆的半径。负值表示位置的经度和纬度是无效的。
    if (location.horizontalAccuracy<0||location.horizontalAccuracy>20.0) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
    
            UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示:定位误差较大" message:@"亲，请再室外使用，并尽量避免高大的建筑物。" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil] ;
            //自动关闭 UIAlertView
            [NSTimer bk_scheduledTimerWithTimeInterval:3 block:^(NSTimer *timer) {
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            } repeats:NO];
        });
       
        
    }else{

        DDLogInfo(@"dingwei:纬度：%lf,经度：%lf",location.coordinate.latitude,location.coordinate.longitude);
        
        if(self.locations.count>1){

            //计算本次定位数据与上一次定位之间的距离
            CGFloat distance = [location distanceFromLocation:[self.locations lastObject]];
            // (5.0米门限值，存储数组画线) 如果距离少于 5.0 米，则忽略本次数据直接返回方法
            if (distance > minDistance) {
                _totalDistanc += distance;
                //  _timestamp = location.timestamp;
                _speed = location.speed;

            }else{
                //不添加较近的两点
                if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
                    //程序处于前台
                    [self.delegate locationManage:self didUpdateLocations:self.locations];
                }
                return;
            }
        }
        [self.locations addObject:location];
    }
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        //程序处于前台
        [self.delegate locationManage:self didUpdateLocations:self.locations];
    }
}

- (void)startUpdatingLocation{
    DDLogInfo(@"startUpdatingLocation");
    if (_running) {
        return;//已经在定时
    }
    
    if (locationService == nil) {
        locationService = [BMKLocationService new];
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
             locationService.allowsBackgroundLocationUpdates = YES;
        }
       
        locationService.desiredAccuracy = kCLLocationAccuracyBest;
        locationService.pausesLocationUpdatesAutomatically = NO;/// 指定定位是否会被系统自动暂停。默认为YES。只在iOS 6.0之后起作用。
        locationService.delegate = self;
    }
    
   // _timerNumber = 0;
    _totalDistanc = 0;
    _running = YES;
    if ([self.delegate respondsToSelector:@selector(locationManage: didChangeUpdateLocationState:)]){
        [self.delegate locationManage:self didChangeUpdateLocationState:_running];
    }
    [self.locations removeAllObjects ];
    [locationService startUserLocationService];
    _startLocationDate = [NSDate new]; 

}

//- (void)suspendUpdatingLocation{
//
//}

- (void)stopUpdatingLocation{
    DDLogInfo(@"stopUpdatingLocation");
    
    [locationService stopUserLocationService];
    locationService = nil;
    _running = false;

    if ([self.delegate respondsToSelector:@selector(locationManage: didChangeUpdateLocationState:)]){
        [self.delegate locationManage:self didChangeUpdateLocationState:_running];
    }
   
}


- (void)dealloc{
    DDLogError(@"locationManager is dealloc");
}
@end
