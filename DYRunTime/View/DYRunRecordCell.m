//
//  DYRunRecordCell.m
//  DYRunTime
//
//  Created by tarena on 15/11/10.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYRunRecordCell.h"
#import <Masonry.h>


@implementation DYRunRecordCell
- (UILabel *)timeLb {
    if(_timeLb == nil) {
        _timeLb = [[UILabel alloc] init];
        _timeLb.textColor = [UIColor lightGrayColor];
        _timeLb.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_timeLb];
        
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(self.totalDistancLb.mas_bottom).mas_equalTo(8);
            make.bottom.mas_equalTo(-10);//距离底部一定要写，好让自动布局控制cell的高
        }];
    }
    return _timeLb;
}

- (UILabel *)totalDistancLb {
    if(_totalDistancLb == nil) {
        _totalDistancLb = [[UILabel alloc] init];
        _totalDistancLb.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:_totalDistancLb];
        
        [_totalDistancLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(10);
        }];
    }
    return _totalDistancLb;
}

- (UILabel *)totalTimeLb {
    if(_totalTimeLb == nil) {
        _totalTimeLb = [[UILabel alloc] init];
        _totalTimeLb.font = [UIFont systemFontOfSize:15];
        _totalTimeLb.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_totalTimeLb];
        [_totalTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(0);
            
                  }];
//        _totalTimeLb.frame = CGRectMake(0, 0, 59, 59);
//        self.accessoryView = _totalTimeLb;
    
    //NSLog(@"%@",self.accessoryType);
    }
    return _totalTimeLb;
}

//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
//        self.accessoryType = 1;
//    }
//    return self;
//}
@end
