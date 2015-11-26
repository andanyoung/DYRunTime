//
//  WYRunModel.h
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//


@interface WYRunNewsListModel : NSObject
/** 发布时间 */
@property (nonatomic, copy) NSString *ptime;
/** list 中的标题
 */
@property (nonatomic, copy) NSString *title;
/** 用这个链接他会自己适配网页 */
@property (nonatomic, copy) NSString *url_3w;

@property (nonatomic, assign) NSInteger hasHead;

@property (nonatomic, copy) NSString *docid;
/** list 的icon */
@property (nonatomic, copy) NSString *imgsrc;

@property (nonatomic, copy) NSString *subtitle;

/** list中的描述 */
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, strong) NSArray *imgextra;

+ (id)runNewsListModelWithArray:(id)responseObj;
@end

