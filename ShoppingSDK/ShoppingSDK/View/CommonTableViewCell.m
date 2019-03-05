//
//  CommonTableViewCell.m
//  ShoppingSDK
//
//  Created by TEE on 2019/3/5.
//  Copyright © 2019 TEE. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "UIImage+ShoppingSDK.h"
#import "UIImageView+ZFCache.h"
#define cellheight 60
@implementation CommonTableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"CommonTableViewCell";
    // 1.缓存中取
    CommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CommonTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.layer.masksToBounds =YES;
        self.contentView.layer.cornerRadius=6;
        self.contentView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        UIImageView *headImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:headImageView];
        headImageView.frame = CGRectMake(12, 12, cellheight - 24, cellheight - 24);
        UIImage *img = [UIImage getShoppingSDKImageWithName:@"camera_check_detection"];
        headImageView.image = img;
        self.iconImageView = headImageView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.frame = CGRectMake(CGRectGetMaxX(headImageView.frame) + 12, 12, self.contentView.frame.size.width - (CGRectGetMaxX(headImageView.frame) + 12) - 12, (cellheight - 24)*0.55);
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:priceLabel];
        priceLabel.frame = CGRectMake(CGRectGetMaxX(headImageView.frame) + 12, CGRectGetMaxY(nameLabel.frame) + 5, 200, 17);
        self.priceLabel = priceLabel;
        
    }
    
    return self;
    
}

-(void)setDict:(NSDictionary *)dict {
    self.nameLabel.text = dict[@"goodsName"];
    self.priceLabel.text = [NSString stringWithFormat:@"价格: ¥ %.02f",[dict[@"price"] doubleValue]];
    UIImage *img = [UIImage getShoppingSDKImageWithName:@"loading"];
    [self.iconImageView setImageWithURLString:dict[@"goodsLogo"] placeholder:img];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
