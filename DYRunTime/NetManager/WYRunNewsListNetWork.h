//
//  WYRunNewsListNetWork.h
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYRunNewsListModel.h"

@interface WYRunNewsListNetWork : NSObject
/** 根据所给的参数以及路径， 通过get 的方式从网络上获取数据 */
+ (id)Get:(NSString *)path andParameter:(NSDictionary *)parameter completeHandle:(void (^)(id , NSError *))complete;
/** 从本地读取新闻列表缓存 */
+ (NSMutableArray<WYRunNewsListModel *> *) dataArrFromLocation;
@end
