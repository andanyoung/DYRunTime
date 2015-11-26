//
//  NSObject+Common.h
//  FDPublic
//
//  Created by jiyingxin on 15/6/19.
//  Copyright (c) 2015年 timShadow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Common)

//显示失败提示
- (void)showErrorMsg:(NSObject *)msg;

//显示成功提示
- (void)showSuccessMsg:(NSObject *)msg;

//显示忙
- (void)showProgress;

//隐藏提示
- (void)hideProgress;

@end
