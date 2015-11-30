//
//  WYRunNewsListNetWork.m
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "WYRunNewsListNetWork.h"
#import <AFNetworking.h>

static NSString *lastLmodify = nil; //用于保存上一次保存到本地的数据修改时间，从而来判断是否要将数据保存到本地
@implementation WYRunNewsListNetWork
+ (NSMutableArray<WYRunNewsListModel *> *) dataArrFromLocation{
    NSArray *arr = [NSArray arrayWithContentsOfFile:[kDocumentPath stringByAppendingPathComponent:@"newsList.plist"]];
    lastLmodify = arr[0][@"lmodify"];
    return [WYRunNewsListModel runNewsListModelWithArray:arr];
}

+ (id)Get:(NSString *)path andParameter:(NSDictionary *)parameter completeHandle:(void (^)(id , NSError *))complete{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@-20.html",path,parameter[@"pageNumber"]];
    DDLogInfo(@"url path:%@",path);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"text/html",@"application/json", nil];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
     manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:urlPath parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        
        //将数据保存到本地，
        NSArray *arr = responseObject[@"T1411113472760"];
        if ([parameter[@"pageNumber"] longValue] == 0  ){
           //判断是否有必要更新本地数据
            if(![lastLmodify isEqualToString: arr[0][@"lmodify"] ]){
                [arr writeToFile:[kDocumentPath stringByAppendingPathComponent:@"newsList.plist"] atomically:YES];
                DDLogInfo(@"DocumentPath:%@",kDocumentPath);
                lastLmodify =  arr[0][@"lmodify"];
            }
        }
        
        complete([WYRunNewsListModel runNewsListModelWithArray:arr],nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        DDLogError(@"%@",error);
        complete(nil,error);
    }];
    return nil;
}

    
    
//+ (id)Get:(NSString *)path completeHandle:(void (^)(id , NSError *))complete{
//
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:path] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
//        if (error) {
//            complete(nil,error);
//        }else{
//            NSError *error1 = nil;
//            id responseObj=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error1];
//            if (error1) {
//                complete(nil,error1);
//            }else{
//                complete([WYRunNewsListModel runNewsListModelWithArray:responseObj[@"T1411113472760"]],error1);
//            }
//        }
//    }];
//    [task resume];
//    return task;
//}
@end
