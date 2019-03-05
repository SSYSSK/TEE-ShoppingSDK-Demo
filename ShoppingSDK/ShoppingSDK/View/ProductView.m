//
//  ProductView.m
//  ShoppingSDK
//
//  Created by TEE on 2019/2/26.
//  Copyright © 2019 TEE. All rights reserved.
//

#import "ProductView.h"
#import "UIImageView+ZFCache.h"
#import "UIImage+ShoppingSDK.h"

@implementation ProductView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, frame.size.height - 24, frame.size.height - 24)];
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame)+12, 12, frame.size.width - CGRectGetMaxX(_imageView.frame) - 12 - 12, _imageView.frame.size.height*0.55)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame)+12, CGRectGetMaxY(_nameLabel.frame), _nameLabel.frame.size.width, 17)];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame)+12, CGRectGetMaxY(_priceLabel.frame), _nameLabel.frame.size.width, 17)];
        _fromLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_imageView];
        [self addSubview:_nameLabel];
        [self addSubview:_priceLabel];
        [self addSubview:_fromLabel];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

-(void)clickAction {
    if (self.clickBlock != nil) {
        self.clickBlock(self.dict);
    }  
}

-(void)setDict:(NSDictionary *)dict{
    _dict = dict;
    UIImage *img = [UIImage getShoppingSDKImageWithName:@"loading"];
    [self.imageView setImageWithURLString:dict[@"goodsLogo"] placeholder:img];
    self.nameLabel.text = dict[@"goodsName"];
    self.priceLabel.text = [NSString stringWithFormat:@"价格: ¥ %.02f",[dict[@"price"] doubleValue]];
    self.fromLabel.text = dict[@"from"];
}
@end
