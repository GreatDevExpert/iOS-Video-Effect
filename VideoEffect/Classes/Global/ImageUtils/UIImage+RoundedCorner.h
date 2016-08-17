//
//  UIImage+RoundedCorner.h
//
//  Created by iDeveloper on 2/6/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

// Extends the UIImage class to support making rounded corners
@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
@end
