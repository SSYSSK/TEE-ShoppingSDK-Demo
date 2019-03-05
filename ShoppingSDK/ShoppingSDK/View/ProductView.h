//
//  ProductView.h
//  ShoppingSDK
//
//  Created by TEE on 2019/2/26.
//  Copyright © 2019 TEE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ProductViewClickBlock)(NSDictionary *dict);//给block重命名,方便调用
@interface ProductView : UIView

@property(nonatomic, strong)NSDictionary *dict;

@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *priceLabel;
@property(nonatomic, strong)UILabel *fromLabel;
@property (nonatomic, copy) ProductViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
