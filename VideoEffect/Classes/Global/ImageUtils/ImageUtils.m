//
//  ImageUtils.m
//  A Day in The Life
//
//  Created by iDeveloper on 2/6/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils

+ (UIImage *)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point
{
//    UIFont *font = [UIFont boldSystemFontOfSize:18];
    UIFont *font = [UIFont fontWithName:@"V5 Prophit" size:22];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x - [text sizeWithFont:font].width / 2, point.y, image.size.width, image.size.height);
    [[UIColor colorWithRed:209/255.f green:151/255.f blue:145/255.f alpha:1.0]  set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageFromText:(NSString *)text
{
    //  set the font type and size
    UIFont *font = [UIFont systemFontOfSize:20.f];
    CGSize size = [text sizeWithFont:font];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    else // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    
    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.f, 0.f) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)horizontalMergeFromTwoImage:(UIImage *)image1 image2:(UIImage *)image2
{
    CGSize newSize = CGSizeMake(image1.size.width + image2.size.width, MAX(image1.size.height, image2.size.height));
    UIGraphicsBeginImageContext(newSize);
    
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(image1.size.width, 0, image2.size.width, image2.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)horizontalMergeFromList:(NSMutableArray *)fileList
{
    NSMutableArray *imgArray = [NSMutableArray array];
    int space = 10;
    
    int w = 10, h = 0;
    for (int i = 0; i < [fileList count]; i++) {
        UIImage *image = [UIImage imageNamed:[fileList objectAtIndex:i]];
        if (image == nil)
            continue;
        
        [imgArray addObject:image];
        w += (image.size.width + space);
        h = MAX(h, image.size.height);
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(w, h));

    int currentX = 10;
    for (int i = 0; i < [imgArray count]; i++) {
        UIImage *image = [imgArray objectAtIndex:i];
        [image drawInRect:CGRectMake(currentX, 0, image.size.width, image.size.height)];
        currentX += (image.size.width +space);
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight
{
    UIGraphicsBeginImageContext(CGSizeMake(resizedWidth, resizedHeight));
    [image drawInRect:CGRectMake(0, 0, resizedWidth, resizedHeight)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight bitsPerComponent:(size_t)bitsPerComponent bytesPerRow:(size_t)bytesPerRow
{
    CGImageRef imageRef = [image CGImage];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL, resizedWidth, resizedHeight, bitsPerComponent, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, resizedWidth, resizedHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
    
}

+ (UIImage *)resizeUpholdImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [image drawInRect:CGRectMake((size.width - image.size.width) / 2, (size.height - image.size.height) / 2, image.size.width, image.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIColor *)colorForPixel:(UIImage *)refImage
{
    CGImageRef image = [refImage CGImage];
    NSUInteger width = CGImageGetWidth(image);
    NSUInteger height = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger xx = width / 2;
    NSUInteger yy = height / 2;
    NSUInteger byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;
    float red_ = (float)rawData[byteIndex] / 255.f;
    float green_ = (float)rawData[byteIndex + 1] / 255.f;
    float blue_ = (float)rawData[byteIndex + 2] / 255.f;
    //    int alpha_ = rawData[byteIndex + 3];

//    NSLog(@"colorForPixel : %@, %.2f, %.2f, %.2f", NSStringFromCGSize([refImage size]), red_, green_, blue_);
    
    return [[[UIColor alloc] initWithRed:red_ green:green_ blue:blue_ alpha:1] autorelease];
}

+ (UIImage *)changePixelColor:(UIImage *)fromImage toColor:(UIColor *)toColor
{
    CGImageRef inImage = [fromImage CGImage];
    CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    UInt8 * pixelBuf = (UInt8 *) CFDataGetBytePtr(dataRef);
    
    CFIndex length = CFDataGetLength(dataRef);
    
    CGContextRef ctx = CGBitmapContextCreate(pixelBuf,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                             );
    
    
    CGColorRef colorRef = [toColor CGColor];
//    int numComponents = CGColorGetNumberOfComponents(colorRef);
    const CGFloat *components = CGColorGetComponents(colorRef);
    int red     = components[0] * 255;
    int green   = components[1] * 255;
    int blue    = components[2] * 255;
    
    for (int i = 0; i < length; i += 4) {
        if (pixelBuf[i + 3] > 0) {
            pixelBuf[i] = red;
            pixelBuf[i + 1] = green;
            pixelBuf[i + 2] = blue;
        }
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(dataRef);
    
    return finalImage;
}

@end
