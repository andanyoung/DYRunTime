//
//  MapViewController.m
//  DYRunTime
//
//  Created by tarena on 15/10/15.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "MapViewController.h"
#import "DYLocationManager.h"
#import "DYRunRecord.h"
#import "DYFMDBManager.h"
#import "DYMainViewController.h"
#import "MobClick.h"
#import "UMSocial.h"

#import <Masonry.h>

#define polylineWidth 10.0
#define polylineColor [[UIColor greenColor] colorWithAlphaComponent:1]
#define mapViewZoomLevel 20
#define removeObjectsLen 20


#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件//只引入所需的单个头文件
#import <BaiduMapAPI_Utils/BMKGeometry.h>



@interface MapViewController ()<BMKMapViewDelegate,DYLocationManagerDelegate,UIPreviewActionItem,UMSocialUIDelegate>
//百度地图View
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (nonatomic, strong) BMKPolyline *polyLine;
@property (nonatomic, strong) DYLocationManager *locationManager;
@property (nonatomic, assign) float zoomLevel;
@property (nonatomic, weak) BMKPointAnnotation *startAnnotation;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@end

@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   // _zoomLevel = 0;
    //初始化定位
    [self initLocation];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
 
    _locationManager.delegate = self;
    //更新位置
    if(MapViewTypeQueryDetail != _type ){
        BMKUserLocation *userLocation = _locationManager.userLocation;
        
        //[_mapView setCenterCoordinate:location.coordinate animated:YES];
        //下行：设置默认的地图中心。按上行设置时，当直接改变zoomLevel，是中心会改变
        _mapView.centerCoordinate = userLocation.location.coordinate;
        [_mapView updateLocationData:userLocation];
    }
    //peek 、Pop都会调用此方法，所以初始化轨迹应放这
    if (MapViewTypeLocation != _type ) {
        //绘制路径
        [self drawWalkPolyline:_locations];
        [self mapViewFitPolyLine:_polyLine];
        if (_type == MapViewTypeQueryDetail) {
       
            [self creatPointWithLocaiton:[_locations lastObject] title:@"终点"];
        }
        if (_zoomLevel > 3) {
            _mapView.zoomLevel = _zoomLevel;
        }
    }

    [MobClick beginLogPageView:[NSString stringWithFormat:@"MapView_type_%ld",_type]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = nil;//不用时，值nil。释放内存
    
    [MobClick endLogPageView:[NSString stringWithFormat:@"MapView_type_%ld",_type]];
}



#pragma mark -- 初始化地图
- (void)initLocation{
    _progressHUD = [MBProgressHUD showHUDAddedTo:self.mapView animated:YES];
    _mapView.showMapScaleBar = YES;
    _mapView.delegate = self;
    
    
    if ( MapViewTypeQueryDetail == _type ) {
        _shareBtn.hidden = NO;
        return;
    }
    _mapView.zoomLevel = mapViewZoomLevel;
    //配置_mapView 去除蓝色精度框
    if (MapViewTypeRunning == _type ) {
        BMKLocationViewDisplayParam *displayParam = [BMKLocationViewDisplayParam new];
        displayParam.isRotateAngleValid = true;//跟随态旋转角度是否生效
        displayParam.isAccuracyCircleShow = false;//精度圈是否显示
        displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
        displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
        displayParam.locationViewImgName = @"walk";//定位图标名称
        [_mapView updateLocationViewWithParam:displayParam];
    }
    
    
    
    /** 开始定位 */
    _locationManager = [DYLocationManager shareLocationManager];
    _locationManager.delegate = self;
    
    [_locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;// 定位罗盘模式
    _mapView.showsUserLocation = YES;//显示定位图层,开始定位
}

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
 //先viewDidAppear ，在这个
   // _mapView.zoomLevel = 3;
    //_mapView.centerCoordinate = _locationManager.userLocation.coordinate;
    [_progressHUD hide:YES];
}

#pragma mark -- DYLocationManagerDelegate

- (void)locationManage:(DYLocationManager *)manager didUpdateLocations:(NSArray <CLLocation *>*)locations{
    //_mapView.zoomLevel = mapViewZoomLevel;
    BMKUserLocation *userLocation = manager.userLocation;
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    [_mapView updateLocationData:userLocation];
    
    if(_type != MapViewTypeLocation){
        [self drawWalkPolyline:locations];
    }
   
}

#pragma mark -- 路径配置
/**
 *  绘制轨迹路线
 */
- (void)drawWalkPolyline:(NSArray *)locations{
    // 轨迹点数组个数
    NSUInteger count = locations.count;
    // 动态分配存储空间
    // BMKMapPoint是个结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
    BMKMapPoint *tempPoints = malloc(sizeof(BMKMapPoint) * count);
    // 遍历数组 ,将coordinate 转化为 BMKMapPoint
    [locations enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL * _Nonnull stop) {
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
    }];
    
    // 放置起点旗帜
    if (!_startAnnotation) {
        _startAnnotation = [self creatPointWithLocaiton:[_locations firstObject] title:@"起点"];
    }

    //移除原有的绘图，避免在原来轨迹上重画
    if (self.polyLine) {
        [self.mapView removeOverlay:self.polyLine];
    }
    
    //通过points构建BMKPolyline
    self.polyLine = [BMKPolyline polylineWithPoints:tempPoints count:count];
    //添加路线，绘图
    if(self.polyLine){
        [self.mapView addOverlay:self.polyLine];
    }
    // 清空 tempPoints 临时数组
    free(tempPoints);
    
    // 根据polyline设置地图范围
    //[self mapViewFitPolyLine:self.polyLine];
}


/**
 *  根据polyline设置地图范围
 *
 *  @param polyLine
 */


- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    
//    if (polyLine.pointCount < 20 ) {
//        self.mapView.zoomLevel = 20;
//        [self.mapView setCenterCoordinate:[_locations lastObject].coordinate animated:YES];
//        return;
//    }

    //一个矩形的四边
    /** ltx: top left x */
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;

    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    

    
    BMKMapRect mapRect;
    mapRect.origin = BMKMapPointMake(ltX, ltY);
    mapRect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
   // DDLogInfo(@"1coor:%lf-- %lf",_mapView.centerCoordinate.longitude,_mapView.centerCoordinate.latitude);
    [self.mapView setVisibleMapRect:mapRect ];
    //DDLogInfo(@"2coor:%lf-- %lf",_mapView.centerCoordinate.longitude,_mapView.centerCoordinate.latitude);

    DDLogInfo(@" region:%lf,%lf",_mapView.region.span.latitudeDelta,_mapView.region.span.longitudeDelta);
    
    CGPoint point = [self.mapView convertCoordinate:_locations.firstObject.coordinate toPointToView:self.mapView];
    if (16777215 == point.x) {
        [_mapView zoomOut];
    }
    [_mapView zoomOut];
    NSLog(@"%@",NSStringFromCGPoint(point));
    DDLogInfo(@" region:%lf,%lf",_mapView.region.span.latitudeDelta,_mapView.region.span.longitudeDelta);
    if (1.0 >_zoomLevel) {//为了让pop进来时保存住zoomlevel
        _zoomLevel = _mapView.zoomLevel;
    }
    //zoomLevel是浮点数
//    if (1.0 < _zoomLevel) {
//        //设置两次（setRegion）会使zoolLevel改变？ pop进来会两次进入Viewdidappear，
//        CGRect rect = [self.mapView convertMapRect:mapRect toRectToView:self.mapView];
//        BMKCoordinateRegion region = [self.mapView convertRect:rect toRegionFromView:self.mapView];
//        BMKCoordinateSpan tempSpan = region.span;
//        tempSpan.latitudeDelta *= 1.3;
//        tempSpan.longitudeDelta *= 1.3;
//        region.span = tempSpan;
//        [self.mapView setRegion:region ];
//        
//        _zoomLevel = _mapView.zoomLevel;
//        //打印出来有时为 3coor:0.000000-- -0.000000 转化失败。。
//        DDLogInfo(@"3coor:%lf-- %lf",_mapView.centerCoordinate.longitude,_mapView.centerCoordinate.latitude);
//    }
    
}


// Override
#pragma mark - BMKMapViewDelegate
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = polylineColor;
        polylineView.lineWidth = polylineWidth;
       // polylineView.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
        return polylineView;
    }
    return nil;
}
- (void)didFailToLocateUserWithError:(NSError *)error{
    DDLogError(@"error:%@",error);
}

/**
 *  添加一个大头针
 *
 *  @param location
 */
- (BMKPointAnnotation *)creatPointWithLocaiton:(CLLocation *)location title:(NSString *)title;
{
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];
    
    return point;
}

/**
 *  只有在添加大头针的时候会调用，直接在viewDidload中不会调用
 *  根据anntation生成对应的View
 *  @param mapView 地图View
 *  @param annotation 指定的标注
 *  @return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        if([[annotation title] isEqualToString:@"起点"]){ // 有起点旗帜代表应该放置终点旗帜（程序一个循环只放两张旗帜：起点与终点）
            annotationView.pinColor = BMKPinAnnotationColorGreen; // 替换资源包内的图片，作为起点
           
        }else if([[annotation title] isEqualToString:@"终点"]){
            annotationView.pinColor = BMKPinAnnotationColorRed;//终点的图标
        }else { // 没有起点旗帜，应放置起点旗帜
            annotationView.pinColor = BMKPinAnnotationColorPurple;

        }
        
        // 从天上掉下效果
        annotationView.animatesDrop = YES;
        
        // 不可拖拽
        annotationView.draggable = NO;
        
        return annotationView;
    }
    return nil;
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    DDLogInfo(@"start locate");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //内存警告时，移除内存大的
    NSRange range = NSMakeRange(0, removeObjectsLen);
    [_locationManager.locations removeObjectsInRange:range];
}

- (IBAction)quitMap:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    if ( _type == MapViewTypeRunning) return;
    [_locationManager stopUpdatingLocation];
    
}

//底部预览界面选项
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
//    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"查看" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action,UIViewController  * _Nonnull previewViewController) {
//    //previewViewController 为当前视图(self)
//        [_mainVC presentViewController:previewViewController animated:YES completion:nil];
//    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"删除" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        [[UIAlertView bk_showAlertViewWithTitle:@"删除记录？" message:@"确定要删除此纪录吗？" cancelButtonTitle:@"点错了" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
               
                [_mainVC tableView:_mainVC.tableView deleteCellAtIndexPath:_indexParh];
            }
        }] show];
    }];


    return @[action2];
}

- (IBAction)share:(id)sender {
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToSina, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    UIImage *shareImage = [self.mapView takeSnapshot];
    
   // [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://img.blog.csdn.net/20151125192649330?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center";
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"565169f167e58e49ba005813"
                                      shareText:@"我今天的运动轨迹"
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,nil]
                                       delegate:self];
}

//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.mapView animated:YES];
        _progressHUD.labelText = @"分享成功";
        _progressHUD.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
        [_progressHUD hide:YES afterDelay:1];
    }
}
@end
