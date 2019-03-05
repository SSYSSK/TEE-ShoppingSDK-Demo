//
//  ViewController.m
//  ShoppingSDKDemoOC
//
//  Created by TEE on 2019/2/26.
//  Copyright © 2019 TEE. All rights reserved.
//

#import "ViewController.h"
#import <ShoppingSDK/ShoppingSDK.h>
#import "CustomViewController.h"
#import <AFNetworking/AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, (self.view.frame.size.width - 100), 50)];
    [button setTitle:@"SDK拍照购物界面" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shoppingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, (self.view.frame.size.width - 100), 50)];
    [button1 setTitle:@"自定义拍照购物界面" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(shoppingAction2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    [AFNetworkReachabilityManager sharedManager];
}

-(void)shoppingAction {
    ShoppingViewController *vc = [[ShoppingViewController alloc]init];
    
    [self.navigationController pushViewController:vc animated:true];
}

-(void)shoppingAction2 {
    CustomViewController *vc = [[CustomViewController alloc]init];
    
    [self.navigationController pushViewController:vc animated:true];
}




@end
