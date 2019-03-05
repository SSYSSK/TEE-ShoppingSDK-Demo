//
//  ProductDetailVC.m
//  ShoppingSDK
//
//  Created by TEE on 2019/3/4.
//  Copyright © 2019 TEE. All rights reserved.
//

#import "ProductDetailVC.h"
#import "HomeTableViewCell.h"
#import "UIImage+ShoppingSDK.h"
#import "ShoppingViewController.h"
#import "CommonTableViewCell.h"
@interface ProductDetailVC () <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
@property (nonatomic,strong) UITableView *maintableView;

@property (nonatomic,strong) UITableView *commontableView;

@property (nonatomic,strong) UIImageView *topBgImage;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIView *noDataView;
@property (nonatomic,strong) NSArray *commonArray;
@property (nonatomic,strong) UIView *commontableViewBg;
@end

@implementation ProductDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topBgImage];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backButton];
    
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.commontableViewBg];
    [self.view addSubview:self.commontableView];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    [currentVC.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (self.goods.count == 0) {
        [self.noDataView setHidden:NO];
    }else {
        [self.noDataView setHidden:YES];
    }
    
    [self setExtraCellLineHidden:self.tableView];
}


#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (viewController == self) {
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
//        [currentVC.navigationController setNavigationBarHidden:YES animated:YES];
//    }
//}

-(UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.delegate = self;
//    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    if (self.navigationController.delegate == self) {
//        self.navigationController.delegate = nil;
//    }
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 24, 35, 30)];
        ;
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"back_icon_white"];
        [_backButton setImage:img forState:UIControlStateNormal];
    }
    return _backButton;
}

-(UIView *)commontableViewBg {
    if (!_commontableViewBg) {
        _commontableViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _commontableViewBg.alpha = 0.3;
        [_commontableViewBg setHidden:YES];
        _commontableViewBg.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commotAction)];
        [_commontableViewBg addGestureRecognizer:tap];
     
    }
    return _commontableViewBg;
}

-(UIView *)noDataView {
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 40)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        label.text = @"没有查询到相关数据～";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:label];
    }
    return _noDataView;
}

-(UITableView *)tableView {
    if (!_maintableView) {
        _maintableView = [[UITableView alloc] initWithFrame:CGRectMake(25, 90,self.view.frame.size.width - 50,self.view.frame.size.height - 90 - 20)];
        //        [_tableView registerClass:[HomeTableViewCell class] forCellReuseIdentifier:@"HomeTableViewCell"];
        _maintableView.delegate = self;
        _maintableView.dataSource = self;
        _maintableView.layer.masksToBounds =YES;
        _maintableView.layer.cornerRadius=10;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _maintableView.frame.size.width, 200)];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, _maintableView.frame.size.width, 190)];
        //    icon.clipsToBounds  = YES;
        icon.image = self.image;// right text
        icon.contentMode =  UIViewContentModeScaleAspectFit;
        // 属性方式设置背景色
        headerView.backgroundColor = [UIColor whiteColor];
        
        [headerView addSubview:icon];
        [self setExtraCellLineHidden:_maintableView];
        _maintableView.tableHeaderView = headerView;
    }
    return _maintableView;
}

-(UITableView *)commontableView {
    if (!_commontableView) {
        _commontableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, self.view.frame.size.height/3*2)];
        _commontableView.delegate = self;
        _commontableView.dataSource = self;
        [self setExtraCellLineHidden:_commontableView];
    }
    return _commontableView;
}



-(UIImageView *)topBgImage {
    if (!_topBgImage) {
        _topBgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,90 + 45)];
        _topBgImage.image = [UIImage getShoppingSDKImageWithName:@"tee_vision_bg"];
    }
    return _topBgImage;
}

-(void)commotAction {
    [_commontableViewBg setHidden:YES];
    [UIView animateWithDuration:0.4 animations:^{
        self.commontableView.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, self.view.frame.size.height/3*1.8);
    }];
}

-(void)backButtonAction {
//    for( UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[ShoppingViewController class]]) {
//            ShoppingViewController *v = (ShoppingViewController *)vc;
//            v.fromDetail = YES;
//            NSLog(@"vc isKindOfClass:[ShoppingViewController class]");
//        }
//    }
    // 创建一个通知中心
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"cesuo" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UITableViewDelegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.maintableView == tableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _maintableView.frame.size.width, 10)];
        // 属性方式设置背景色
        headerView.backgroundColor = [UIColor whiteColor];
        return headerView;
    }else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _maintableView.frame.size.width, 1)];
        headerView.backgroundColor = [UIColor whiteColor];
        return headerView;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.maintableView == tableView) {
        return 10;
    }else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.maintableView == tableView) {
        return self.goods.count;
    }else {
        return self.commonArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.maintableView == tableView) {
        return 100;
    }else {
        return 80;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.maintableView == tableView) {
        HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView];
        cell.dict = self.goods[indexPath.section];
        return cell;
    }else {
        CommonTableViewCell *cell = [CommonTableViewCell cellWithTableView:tableView];
        cell.dict = self.commonArray[indexPath.section];
        return cell;
    }
   
}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//      [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.maintableView == tableView) {
        [self.commontableViewBg setHidden:NO];
        [UIView animateWithDuration:0.4 animations:^{
            self.commontableView.frame = CGRectMake(0, self.view.frame.size.height/3*1.2,self.view.frame.size.width, self.view.frame.size.height/3*1.8);
        }];
        NSDictionary *dict = self.goods[indexPath.section];
        self.commonArray = dict[@"commList"];
        [self.commontableView reloadData];
    }
}

@end
