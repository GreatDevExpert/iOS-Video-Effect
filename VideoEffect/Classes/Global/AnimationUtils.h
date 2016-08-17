//
//  AnimationUtils.h
//  BottlesNightOut
//
//  Created by iDeveloper on 7/9/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface AnimationUtils : NSObject

// [AnimationUtils setLayerAnimation:self.navigationController.view.layer format:kCATransitionReveal];
// [self.navigationController pushViewController:viewController animated:NO];
+ (void)setLayerAnimation:(CALayer *)layer format:(NSString *)format;

//[AnimationUtils setAddSubviewAnimation:viewController.view.layer format:kCATransitionReveal];
+ (void)setAddSubviewAnimation:(CALayer *)layer format:(NSString *)format;

+ (void)setScaleAnimation:(CALayer *)layer duration:(CFTimeInterval)duration;

+ (void)setMoveXAnimation:(CALayer *)layer fromValue:(float)fromValue toValue:(float)toValue duration:(CFTimeInterval)duration;

@end
