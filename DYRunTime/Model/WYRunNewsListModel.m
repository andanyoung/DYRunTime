//
//  WYRunModel.m
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "WYRunNewsListModel.h"


@implementation WYRunNewsListModel
/**
 *  将得到的格式化后json数据装化为所需要的内容
 *
 *  @param responseObj 传入的数组
 *
 *  @return 解析好的数组
 */
+ (id)runNewsListModelWithArray:(id)responseObj{
    
     //[model setValuesForKeysWithDictionary:dic];
    //根据规律。。。
    NSMutableArray<WYRunNewsListModel *> *arr = [[NSMutableArray alloc]initWithCapacity:20];
    for (NSDictionary *dic in responseObj) {
        WYRunNewsListModel *model = [WYRunNewsListModel new];
        model.ptime = dic[@"ptime"];
        model.title = dic[@"title"];
        model.url_3w = dic[@"url_3w"];
        model.docid = dic[@"docid"];
        model.imgsrc = dic[@"imgsrc"];
        model.digest = dic[@"digest"];
        if ([dic valueForKey:@"imgextra"]) {
            model.imgextra = @[dic[@"imgextra"][0][@"imgsrc"],dic[@"imgextra"][1][@"imgsrc"]];
        }
        [arr addObject:model];
    }
    
    return arr;
        
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end


