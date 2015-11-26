//
//  NewsDetailViewController.h
//  DYRunTime
//
//  Created by tarena on 15/11/19.
//  Copyright © 2015年 ady. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailViewController : UIViewController
@property (nonatomic, strong) NSURL *url;

- (instancetype)initWithURL:(NSURL *)url;
@end
