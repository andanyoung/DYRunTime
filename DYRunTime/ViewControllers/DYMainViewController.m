//
//  DYMainViewController.m
//  DYRunTime
//
//  Created by tarena on 15/11/2.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYMainViewController.h"
#import "DYRecordView.h"
#import "DYLocationManager.h"
#import "MapViewController.h"
#import "DYFMDBManager.h"
#import "DYRunRecord.h"
#import "DYRunRecordCell.h"
#import "DYFactory.h"
#import <Masonry.h>

#define minSaveCount  3
#define removeObjectsLen 20
#define tableHeaderViewHeight 250
#define rowAnimation UITableViewRowAnimationAutomatic


@interface DYMainViewController ()<DYLocationManagerDelegate,UIViewControllerPreviewingDelegate,UIViewControllerPreviewing>


@property (nonatomic,strong) DYRecordView *tableHeaderView;
/** 每个界面的location */
@property (nonatomic,weak) NSArray <CLLocation *> *locations;
@property (nonatomic, strong) NSMutableArray *allDates;

@property (nonatomic,weak) UILabel *distanceLB;
@property (nonatomic,weak) UILabel *timeLB;
@property (nonatomic,weak) UILabel *speedLB;
@end

@implementation DYMainViewController

- (NSMutableArray *)allDates{
    if (!_allDates) {
        _allDates = [DYFMDBManager getAllListLocations];
    }
    return _allDates;
}

/** 当添加/删除单元格时， 为了不取数据库里读数据（节约内存和时间），直接修改内存上的数据 */
- (void) refreshDataForTableViewWith:(id)object withSection:(NSInteger)section{
    if (![object isMemberOfClass:[DYRunRecord class]]) {
        NSAssert1(NO, @"%s:传入的id参数应为DYRunRecord类型", __FUNCTION__);
    }
  
    if (section != -1) {
        NSMutableArray *arr = _allDates[section];
        [arr removeObject:object];
        
        if (arr.count == 0) {
            [_allDates removeObject:arr];
        }
       
    }else{
        NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_allDates.count == 0) {//没有数据时
            [self.allDates addObject:[NSMutableArray arrayWithObject:object]];

            [self.tableView beginUpdates];
            //会自动插入一个cell。。。
            [self.tableView insertSections:indexSet withRowAnimation:rowAnimation];
           // [self.tableView insertRowsAtIndexPaths:arrInsertRows withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            return;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todatStr = [dateFormatter stringFromDate:[NSDate new]];
        if ([((DYRunRecord *)_allDates[0][0]).date isEqualToString:todatStr]) {
            [_allDates[0] addObject:object];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            [self.tableView endUpdates];
        }else{
            //要将数组插入最前面
            [self.allDates insertObject:[NSMutableArray arrayWithObject:object] atIndex:0];
            //[self.allDates addObject:[NSMutableArray arrayWithObject:object]]; error
            
            [self.tableView beginUpdates];
            
            [self.tableView insertSections:indexSet withRowAnimation:rowAnimation];
  
            [self.tableView endUpdates];
        }
        
    }
}

- (DYLocationManager *)locationManager{
    if (_locationManager == nil) {
        _locationManager = [DYLocationManager shareLocationManager];
    }
    return _locationManager;
}


- (DYRecordView *)tableHeaderView{
    if (!_tableHeaderView){
        _tableHeaderView = [[DYRecordView alloc]initWithFrame:CGRectMake(0, 0, kWindowW, 250)];
        [self.tableHeaderView setBackgroundColor:[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:0.79]];
        //重构代码
        /** 为了在更新数据是减少getter方法的读取次数 */
        _speedLB = _tableHeaderView.speedLB;
        _timeLB = _tableHeaderView.timeLB;
        _distanceLB = _tableHeaderView.distanceLB;
    }
    return _tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    DDLogVerbose(@"viewDidLoad");
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.tableFooterView = [UIView new];
    self.title = @"RunTime";
    [DYFactory addAllItemsToVC:self];
        
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {//适配9.0以下
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
  
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [DYLocationManager shareLocationManager].delegate = self;
    //开启定时器
    [self continueTimer];

}

- (void)viewWillDisappear:(BOOL)animated{
    //[DYLocationManager shareLocationManager].delegate = nil;
    [super viewWillDisappear:animated];
    DDLogInfo(@"viewWillDisappear");
    //暂定定时器
    [self stopTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //内存警告时，移除内存大的
    DDLogError(@"didReceiveMemoryWarning");
    NSRange range = NSMakeRange(0, removeObjectsLen);
    [_locationManager.locations removeObjectsInRange:range];
}

#pragma mark - DYLocationManagerDelegate
- (void)locationManage:(DYLocationManager *)manager didUpdateLocations:(NSArray <CLLocation *>*)locations{
    _distanceLB.text = [NSString stringWithFormat:@"%05.2lf", manager.totalDistanc/1000.0];
    _speedLB.text = [NSString stringWithFormat:@"%05.2lf",manager.speed>0?manager.speed:0];
    //_locations = locations;
}

- (void)locationManage:(DYLocationManager *)manager didChangeUpdateLocationState:(BOOL)running{
    if (running) {
        [self.tableHeaderView startTimer];
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(continueTimer)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:app];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopTimer)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:app];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.tableHeaderView stopTimer];
        
        //保存记录
        DYRunRecord *record;
        
        if (self.locationManager.locations.count < minSaveCount) {
            [self showErrorMsg:@"运动距离太短，保存失败"];
            [self.tableHeaderView resetRecord];
            return;
        }else if( ( record = [DYFMDBManager saveLocations])){

            
            [self refreshDataForTableViewWith:record withSection:-1];
            [self showSuccessMsg:@"保存成功"];
          
        }else{
            [self showErrorMsg:@"保存失败"];
        }
        [hud hide:YES];
       
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

/** 当返回这个页面时，继续计时器 */
- (void)continueTimer{

    if (_locationManager.running) {
        
        _distanceLB.text = [NSString stringWithFormat:@"%05.2lf", _locationManager.totalDistanc/1000.0];
        _speedLB.text = [NSString stringWithFormat:@"%05.2lf",_locationManager.speed>0?_locationManager.speed:0];
        [_tableHeaderView.timer setFireDate:[NSDate distantPast]];//开启定时器
        NSDate *nowDate = [[NSDate alloc]init];
        NSTimeInterval timeInterval = [nowDate timeIntervalSinceDate:_locationManager.startLocationDate];
        _tableHeaderView.timerNumber = (NSInteger)timeInterval;
    }

}
/** 当退出这个页面时，停止计时器 */
- (void)stopTimer{
    [_tableHeaderView.timer setFireDate:[NSDate distantFuture]];//关闭定时器,invalidate会让timer，退出loop，取消timer
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.allDates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.allDates[section];
    return arr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray *arr = self.allDates[section];
    DYRunRecord *record = arr[0];
    return record.date;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DYRunRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Configure the cell...
    NSArray *arr = self.allDates[indexPath.section];
    DYRunRecord *record = arr[arr.count - indexPath.row - 1];
    cell.accessoryType = 1;
    cell.totalDistancLb.text = [NSString stringWithFormat:@"%@公里",record.totalDistanc];
    cell.totalTimeLb.text = [NSString stringWithFormat:@"%@s",record.totalTime];
    cell.timeLb.text = [NSString stringWithFormat:@"%@ ~ %@",record.startTime,record.endTime];
    return cell;
}

kRemoveCellSeparator

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.locationManager.running){
        [self showErrorMsg:@"正在计时，不能进入详情页面"];
        return;//当正在计时跑步时，不该进入
    }
    NSArray *arr = self.allDates[indexPath.section];
    DYRunRecord *record = arr[arr.count - indexPath.row - 1];
    MapViewController * mapVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"map"];
    mapVC.type = MapViewTypeQueryDetail;
    mapVC.locations = [DYFMDBManager getLocationsWithDate:record.date andStartTime:record.startTime ];
    if (mapVC.locations == nil || mapVC.locations.count == 0) {
//        [[UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"找不到相关信息" cancelButtonTitle:@"OK!" otherButtonTitles:nil handler:nil] show];
        [self showErrorMsg:@"找不到相关信息"];
        return;
    }
    [self presentViewController:mapVC animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}


#pragma mark - tableViewEdit
//某行是否支持编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// Allows customization of the editingStyle for a particular（详细的） cell located at 'indexPath'. If not implemented（执行）, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
//某行的编辑状态
- (UITableViewCellEditingStyle )tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除此记录";
}


//当编辑操作出触发后，做什么
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle== UITableViewCellEditingStyleDelete) {
        if (editingStyle==UITableViewCellEditingStyleDelete) {
            
            [[UIAlertView bk_showAlertViewWithTitle:@"删除记录？" message:@"确定要删除此纪录吗？" cancelButtonTitle:@"点错了" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex==1) {
                    [self tableView:tableView deleteCellAtIndexPath:indexPath];
                }else{
                    [self.tableView endEditing:YES];
                }
            }] show];
            
        }
    }
}

/** 根据indexPath删除cell */
- (void)tableView:(UITableView *)tableView deleteCellAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr = self.allDates[indexPath.section];
    DYRunRecord *record = arr[arr.count - indexPath.row - 1];
    if([DYFMDBManager deleteRecordsWithDate:record.date andStartTime:record.startTime]){
        
        [self refreshDataForTableViewWith:record withSection:indexPath.section];
        if ([tableView numberOfRowsInSection:indexPath.section] == 1) {
            
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:rowAnimation];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView endUpdates];
    }

}
#pragma mark - previewing Delegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
    
    if (self.locationManager.running){
        [self showErrorMsg:@"正在计时，不能进入详情页面"];
        return nil;//当正在计时跑步时，不该进入
    }
    //转化坐标
    // CGPoint point = [_tableView convertPoint:location fromView:self.view];
    //通过当前坐标得到当前cell和indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    //当触碰的不是cell是indexPath = nil
    if (indexPath == nil) {
        return nil;
    }

    NSArray *arr = self.allDates[indexPath.section];
    DYRunRecord *record = arr[arr.count - indexPath.row - 1];
    MapViewController * mapVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"map"];
    mapVC.type = MapViewTypeQueryDetail;
    mapVC.locations = [DYFMDBManager getLocationsWithDate:record.date andStartTime:record.startTime];
    _locations = mapVC.locations;
    mapVC.indexParh = indexPath;
    mapVC.mainVC = self;
    if (mapVC.locations == nil || mapVC.locations.count < 1) {
        [self showErrorMsg:@"找不到相关信息"];
        return nil;
    }
    //自定义peek大小
     //dvc.preferredContentSize = CGSizeMake(200.0f,300.0f);
    
    //    CGRect rect = CGRectMake(10, location.y - 10, self.view.frame.size.width - 20,20);
    //    previewingContext.sourceRect = rect;
    return mapVC;
}


- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{

    [self showDetailViewController:viewControllerToCommit sender:self];
}

@end
