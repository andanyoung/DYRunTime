//
//  DYNewsViewController.m
//  DYRunTime
//
//  Created by tarena on 15/10/31.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYNewsViewController.h"
#import "WYRunNewsListViewModel.h"
#import "DYNewsCell.h"
#import "DYNewsExtraImgCell.h"
#import "NewsDetailViewController.h"
#import "DYFactory.h"

#import <Masonry.h>
#import <MJRefresh.h>
#import <UIImageView+AFNetworking.h>



@interface DYNewsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WYRunNewsListViewModel *newsListVM;
/** 用户保存下拉刷新的图片 */
@property (nonatomic, strong) NSArray *refreshGifs;
@end

@implementation DYNewsViewController

- (NSArray *)refreshGifs{
    if (!_refreshGifs) {
        _refreshGifs = [NSArray arrayWithObjects:[UIImage imageNamed:@"paoku 00188"],[UIImage imageNamed:@"paoku 00189"],[UIImage imageNamed:@"paoku 00190"],
                        [UIImage imageNamed:@"paoku 00191"],[UIImage imageNamed:@"paoku 00192"],[UIImage imageNamed:@"paoku 00193"],[UIImage imageNamed:@"paoku 00194"],[UIImage imageNamed:@"paoku 00195"],[UIImage imageNamed:@"paoku 00196"],[UIImage imageNamed:@"paoku 00197"],[UIImage imageNamed:@"paoku 00198"],[UIImage imageNamed:@"paoku 00199"], nil];
    }
    return _refreshGifs;
}
- (WYRunNewsListViewModel *)newsListVM{
    if (_newsListVM == nil) {
        _newsListVM = [WYRunNewsListViewModel new];
    }
    return _newsListVM;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            [_newsListVM getRefreshDataCompleteHandle:^(NSError *error) {
                
                if (error) {
                    DDLogError(@"%@",error);
                }else{
                    if (self.newsListVM.dataArr.count) {
                        [_tableView reloadData];
                    }
                }
                [_tableView.mj_header endRefreshing];
            }];
        }];
        //设置普通状态的动画图片
        [header setImages:self.refreshGifs forState:MJRefreshStateIdle];
        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        [header setImages:self.refreshGifs forState:MJRefreshStatePulling];
        // 设置正在刷新状态的动画图片
        [header setImages:self.refreshGifs forState:MJRefreshStateRefreshing];
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        // 隐藏状态
        header.stateLabel.hidden = YES;
        // 设置header
        self.tableView.mj_header = header;

        MJRefreshBackGifFooter *footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{
            [_newsListVM getMoreDataCompleteHandle:^(NSError *error) {
                
                if (error) {
                    DDLogError(@"%@",error);
                }else{
                    if(self.newsListVM.dataArr.count >0){
                        [_tableView reloadData];
                    }
                    
                }
                [_tableView.mj_footer endRefreshing];
                
            }];
        }];
        //设置普通状态的动画图片
        [footer setImages:self.refreshGifs forState:MJRefreshStateIdle];
        // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
        [footer setImages:self.refreshGifs forState:MJRefreshStatePulling];
        // 设置正在刷新状态的动画图片
        [footer setImages:self.refreshGifs forState:MJRefreshStateRefreshing];
        
        _tableView.mj_footer = footer;
        
        [_tableView.mj_header beginRefreshing];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [DYFactory addAllItemsToVC:self];
    
    
    self.title = @"News";
    [self.tableView registerClass:[DYNewsCell class] forCellReuseIdentifier:@"newsCell"];
    [self.tableView registerClass:[DYNewsExtraImgCell class] forCellReuseIdentifier:@"newsExtraCell"];
    self.tableView.rowHeight = 80;
    self.tableView.backgroundColor = kRGBColor(244, 244, 244);
}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.newsListVM.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.newsListVM imagextraWithIndexPath:indexPath.row]) {
        DYNewsExtraImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsExtraCell"];
        cell.titleLB.text = [self.newsListVM titleWithIndexPath:indexPath.row];
        [cell.iconIV setImageWithURL:[self.newsListVM imgsrcURLWithIndexPath:indexPath.row] placeholderImage:[UIImage imageNamed:@"loading"]];
        NSArray *imgextra = [self.newsListVM imagextraWithIndexPath:indexPath.row];
        [cell.imgextra0 setImageWithURL:imgextra[0] placeholderImage:[UIImage imageNamed:@"loading"]];
        [cell.imgextra1 setImageWithURL:imgextra[1] placeholderImage:[UIImage imageNamed:@"loading"]];
        
        return cell;
    }
    
    DYNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    [cell.iconIV setImageWithURL:[self.newsListVM imgsrcURLWithIndexPath:indexPath.row] placeholderImage:[UIImage imageNamed:@"loading"]];
    cell.titleLB.text = [self.newsListVM titleWithIndexPath:indexPath.row];
    cell.digestLB.text = [self.newsListVM digestWithIndexPath:indexPath.row];
    
    return cell;
}

kRemoveCellSeparator
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc]initWithURL:[self.newsListVM url_3wWithIndexPath:indexPath.row]];
    newsDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newsDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.newsListVM imagextraWithIndexPath:indexPath.row]) {
        return 120;
    }else{
        return 80;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.navigationController.navigationBar.alpha = 0.0;
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    self.navigationController.navigationBar.alpha = 1;
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    self.navigationController.navigationBar.alpha = 1;
//}
@end
