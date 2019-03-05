//
//  ShoppingViewController.h
//  ShoppingSDK
//
//  Created by TEE on 2019/2/26.
//  Copyright © 2019 TEE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingViewController : UIViewController

/**
 请求数据回调的方法，可以重写然后自定义，默认显示TableView数据
 */
-(void)updateUI:(NSArray *)array;

/**
 * TableView的cell点击事件
 */
-(void)clickCell:(NSDictionary *)dict;

@property (nonatomic,assign)BOOL fromDetail; // 判断是否处于拍照或者选择照片,这个属性别修改
@end

NS_ASSUME_NONNULL_END
