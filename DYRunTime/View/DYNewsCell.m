
//  DYNewsCell.m
//  DYRunTime
//
//  Created by tarena on 15/11/18.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYNewsCell.h"
#import <Masonry.h>

#define iconIVWidth 80


@implementation DYNewsCell

- (UIImageView *)iconIV {
    if(_iconIV == nil) {
        _iconIV = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconIV];
        [_iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(iconIVWidth);
       
        }];
        _iconIV.clipsToBounds = YES;
    }
    return _iconIV;
}

- (UILabel *)titleLB {
    if(_titleLB == nil) {
        _titleLB = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLB];
        [_titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.left.mas_equalTo(self.iconIV.mas_right).mas_equalTo(10);
        }];
        //_titleLB.font = [UIFont systemFontOfSize:18];
    }
    return _titleLB;
}

- (UILabel *)digestLB {
    if(_digestLB == nil) {
        _digestLB = [[UILabel alloc] init];
        [self.contentView addSubview:_digestLB];
        [_digestLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.left.mas_equalTo(self.iconIV.mas_right).mas_equalTo(10);
            make.top.mas_equalTo(self.titleLB.mas_bottom).mas_equalTo(5);
        }];
        _digestLB.numberOfLines = 2;
        //_digestLB.font = [UIFont systemFontOfSize:12];
        _digestLB.textColor = [UIColor grayColor];
    }
    return _digestLB;
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       // DDLogError(@"initCell:%@",[NSThread currentThread]);

        self.titleLB.font = [UIFont systemFontOfSize:16];
        self.digestLB.font = [UIFont systemFontOfSize:15];
        self.contentView.backgroundColor = kRGBColor(244, 244, 244);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
