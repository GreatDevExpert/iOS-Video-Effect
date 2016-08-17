//
//  ImageUtils.h
//  A Day in The Life
//
//  Created by iDeveloper on 2/6/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUtils : UIImage

+ (UIImage *)drawText:(NSString *)text inImage:(UIImage *)image atPoint:(CGPoint)point;
+ (UIImage *)imageFromText:(NSString *)text;

+ (UIImage *)horizontalMergeFromTwoImage:(UIImage *)image1 image2:(UIImage *)image2;
+ (UIImage *)horizontalMergeFromList:(NSMutableArray *)fileList;

// dimension process
+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight;
+ (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight bitsPerComponent:(size_t)bitsPerComponent bytesPerRow:(size_t)bytesPerRow;
+ (UIImage *)resizeUpholdImage:(UIImage *)image size:(CGSize)size;

// color process
+ (UIColor *)colorForPixel:(UIImage *)refImage;
+ (UIImage *)changePixelColor:(UIImage *)fromImage toColor:(UIColor *)toColor;

@end
