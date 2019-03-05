//
//  HomeTableViewCell.h
//  ShoppingSDK
//
//  Created by TEE on 2019/2/27.
//  Copyright © 2019 TEE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeTableViewCell : UITableViewCell

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *priceLabel;
@property(nonatomic, strong)NSDictionary *dict;

 + (instancetype)cellWithTableView:(UITableView *)tableView;


@end

NS_ASSUME_NONNULL_END
