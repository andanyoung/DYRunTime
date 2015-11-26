//
//  NewsDetailViewController.m
//  DYRunTime
//
//  Created by tarena on 15/11/19.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "NewsDetailViewController.h"
#import <Masonry.h>

@interface NewsDetailViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation NewsDetailViewController

- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (UIWebView *)webView{
    if(!_webView){
        _webView = [[UIWebView alloc]init];
        [_webView loadRequest:[NSURLRequest requestWithURL:_url]];

        _webView.delegate = self;
        _webView.allowsInlineMediaPlayback = YES;
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
        _webView.scrollView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //应该设置在self上
    //self.hidesBottomBarWhenPushed = YES;
    //self.tabBarController.hidesBottomBarWhenPushed = YES;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -- UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
   
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_hud hide:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
//    if (error) {
//        [self showErrorMsg:@"加载失败"];
//    }
}

@end
