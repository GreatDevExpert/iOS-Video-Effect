//
//  UIImage+Alpha.h
//
//  Created by iDeveloper on 2/6/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size;
@end
