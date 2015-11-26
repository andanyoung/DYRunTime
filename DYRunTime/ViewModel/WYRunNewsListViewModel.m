//
//  WYRunNewsListViewModel.m
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "WYRunNewsListViewModel.h"
#import "WYRunNewsListNetWork.h"

#define urlPath @"http://c.3g.163.com/nc/article/list/T1411113472760/"

@implementation WYRunNewsListViewModel

//重写init方法，使得_dataArr在该类初始化是就从本地读取数据
- (instancetype)init{
    if (self = [super init]) {
        _dataArr = [WYRunNewsListNetWork dataArrFromLocation];
    }
    return self;
}
-(NSMutableArray<WYRunNewsListModel *> *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}

- (WYRunNewsListModel *)listModelForRow:(NSInteger)row{
    if (row>self.dataArr.count) {
        return nil;
    }
    return self.dataArr[row];
}
- (void)cancelNetwork{
    [self.task cancel];
}

- (id)getNewsListFromNetCompleteWithError:(void (^)(NSError *))complete{
    [self.task cancel];
    if (_pageNumber == 0) {
        [self.dataArr removeAllObjects];
    }
   
    self.task = [WYRunNewsListNetWork Get:urlPath andParameter:@{@"pageNumber":@(_pageNumber)} completeHandle:^(id model, NSError *error) {
        [self.dataArr addObjectsFromArray: model];
        complete(error);
    }];
    
    return self.task;
}

- (id)getRefreshDataCompleteHandle:(CompletionHandle)completionHandle{
    _pageNumber = 0;
    return [self getNewsListFromNetCompleteWithError:completionHandle];
}

- (id)getMoreDataCompleteHandle:(CompletionHandle)completionHandle{
    _pageNumber += 20;
    return [self getNewsListFromNetCompleteWithError:completionHandle];
}

//每行图标的图片地址
- (NSURL *)imgsrcURLWithIndexPath:(NSInteger)row{
     return [NSURL URLWithString: [self listModelForRow:row].imgsrc];
}
//每行的标题
- (NSString *)titleWithIndexPath:(NSInteger)row{
    return  self.dataArr[row].title;
}
//每行的内容描述
- (NSString *)digestWithIndexPath:(NSInteger)row{
    return  self.dataArr[row].digest;
}
//每行的详细内容
- (NSURL *)url_3wWithIndexPath:(NSInteger)row{
    return [NSURL URLWithString:self.dataArr[row].url_3w];
}

- (NSArray *)imagextraWithIndexPath:(NSInteger)row{
    if(self.dataArr.count == 0)return nil;
    NSArray *imgextraArr = self.dataArr[row].imgextra;
    if (imgextraArr == nil) {
        return nil;
    }
    return @[[NSURL URLWithString:imgextraArr[0]],[NSURL URLWithString:imgextraArr[1]]] ;
}
@end
