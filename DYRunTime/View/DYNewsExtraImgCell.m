//
//  DYNewsExtraImgCell.m
//  DYRunTime
//
//  Created by tarena on 15/11/20.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYNewsExtraImgCell.h"
#import <Masonry.h>

@implementation DYNewsExtraImgCell

- (UILabel *)titleLB {
    if(_titleLB == nil) {
        _titleLB = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLB];
        [_titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(5);
            make.left.mas_equalTo(10);
            make.height.greaterThanOrEqualTo(@15);
        }];
    }
    return _titleLB;
}

- (UIImageView *)iconIV {
    if(_iconIV == nil) {
        _iconIV = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconIV];
        [_iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLB.mas_bottom).mas_equalTo(10);
            make.left.mas_equalTo(10);
            make.bottom.mas_equalTo(-5);
            //make.width.mas_equalTo(200);
        }];
        _iconIV.clipsToBounds = YES;
    }
    return _iconIV;
}

- (UIImageView *)imgextra0 {
    if(_imgextra0 == nil) {
        _imgextra0 = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgextra0];
        [_imgextra0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconIV).mas_equalTo(0);
            make.left.mas_equalTo(self.iconIV.mas_right).mas_equalTo(2.5);
            make.width.mas_equalTo(self.iconIV);
            make.height.mas_equalTo(self.iconIV);
        }];
        _imgextra0.clipsToBounds = YES;
    }
    return _imgextra0;
}

- (UIImageView *)imgextra1 {
    if(_imgextra1 == nil) {
        _imgextra1 = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgextra1];
        [_imgextra1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconIV).mas_equalTo(0);
            make.left.mas_equalTo(self.imgextra0.mas_right).mas_equalTo(2.5);
            make.width.mas_equalTo(self.iconIV);
            make.height.mas_equalTo(self.iconIV);
            make.right.mas_equalTo(-10);
        }];
        
        _imgextra1.clipsToBounds = YES;
    }
    return _imgextra1;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLB.font = [UIFont systemFontOfSize:16];
        self.contentView.backgroundColor = kRGBColor(244, 244, 244);
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
