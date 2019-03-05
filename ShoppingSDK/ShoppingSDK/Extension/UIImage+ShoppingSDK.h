//
//  UIImage+OneVOne.h
//  OneVOneSDK
//
//  Created by Alen on 2018/8/2.
//  Copyright © 2018年 Allen li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define TT_FIX_CATEGORY_BUG(name) @interface TT_FIX_CATEGORY_BUG_##name @end \
@implementation TT_FIX_CATEGORY_BUG_##name @end
@interface UIImage (ShoppingSDK)

+ (UIImage *)getShoppingSDKImageWithName:(NSString *)name;

+ (NSData *)compressWithOrgImg:(UIImage *)img;

+ (UIImage*)imageFromPixelBuffer:(CMSampleBufferRef)p;
@end
