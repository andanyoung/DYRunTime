//
//  WYRunNewsListViewModel.h
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYRunNewsListModel.h"

typedef void(^CompletionHandle)(NSError *error);

@interface WYRunNewsListViewModel : NSObject
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableArray<WYRunNewsListModel *> *dataArr;
/** 页数 */
@property (nonatomic) NSInteger pageNumber;

//每行图标的图片地址
- (NSURL *)imgsrcURLWithIndexPath:(NSInteger)row;
//每行的标题
- (NSString *)titleWithIndexPath:(NSInteger)row;
//每行的内容描述
- (NSString *)digestWithIndexPath:(NSInteger)row;
//每行的详细内容
- (NSURL *)url_3wWithIndexPath:(NSInteger)row;
/** 每行的额外图片 */
- (NSArray *)imagextraWithIndexPath:(NSInteger)row;

/** 刷新数据 */
- (id)getRefreshDataCompleteHandle:(CompletionHandle)completionHandle;
/** 获取更多数据 */
- (id)getMoreDataCompleteHandle:(CompletionHandle)completionHandle;
/** 取消当前网络任务 */
- (void)cancelNetwork;
@end
