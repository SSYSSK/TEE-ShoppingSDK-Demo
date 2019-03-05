//
//  UIImage+OneVOne.m
//  OneVOneSDK
//
//  Created by Alen on 2018/8/2.
//  Copyright © 2018年 Allen li. All rights reserved.
//

#import "UIImage+ShoppingSDK.h"

@implementation UIImage (ShoppingSDK)

+(UIImage *)getShoppingSDKImageWithName:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShoppingSDKBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *file = [bundle pathForResource:name ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:file];
    return img;
}

+ (NSData *)compressWithOrgImg:(UIImage *)img
{
    
    NSData *imageData = UIImageJPEGRepresentation(img, 1);
    float length = imageData.length;
    length = length/1024;
    NSLog(@"压缩前的大小：%fKB",length);
    // 裁剪比例
    CGFloat cout = 0.5;
    
    // 压缩比例
    CGFloat imgCout = 0.1;
    if(length > 25000){ // 25M以上的图片
        cout = 0.1;
        imgCout = 0;
    }else if(length > 10000){ // 10M以上的图片
        cout = 0.2;
        imgCout = 0;
    }else if (length > 5000) { // 5M以上的图片
        cout = 0.3;
        imgCout = 0;
    }else if (length > 1500) { // 如果原图大于1.5M就换一个压缩级别
        cout = 0.7;
        imgCout = 0.1;
    }else if (length > 1000) {
        cout = 0.8;
        imgCout = 0.2;
    }else if (length > 500) {
        cout = 0.8;
        imgCout = 0.3;
    }else if (length >100){ // 小于500k的不用裁剪
        
        imageData = UIImageJPEGRepresentation(img, 50 / imageData.length);
        float length = imageData.length;
        length = length/1024;
        NSLog(@"压缩后的大小：%fKB",length);
        return imageData;
    }else{
        
        imageData = UIImageJPEGRepresentation(img, 0.5);
        float length = imageData.length;
        length = length/1024;
        NSLog(@"压缩后的大小：%fKB",length);
        return imageData;
    }
    
    
    // 按裁剪比例裁剪
    UIImage *compressImage =  [img imageByScalingAndCroppingForSize:CGSizeMake(img.size.width * cout, img.size.height *cout)];
    
    
    // 那压缩比例压缩
    imageData = UIImageJPEGRepresentation(compressImage, imgCout);
    
    length= imageData.length / 1024;
    NSLog(@"裁剪比例：%f，压缩比例：%f,压缩后的大小：%fKB",cout,imgCout,length);
    return imageData;
}

// 裁剪
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage*)imageFromPixelBuffer:(CMSampleBufferRef)p {
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(p);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}

@end
