//
//  AnimationUtils.m
//  BottlesNightOut
//
//  Created by iDeveloper on 7/9/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

#import "AnimationUtils.h"

@implementation AnimationUtils

+ (void)setLayerAnimation:(CALayer *)layer format:(NSString *)format
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionPush;
    transition.subtype = format;
    [layer addAnimation:transition forKey:nil];
}

+ (void)setAddSubviewAnimation:(CALayer *)layer format:(NSString *)format
{
    CATransition *loadViewIn = [CATransition animation];
    [loadViewIn setDuration:0.25f];
    [loadViewIn setType:format];
    [loadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [layer addAnimation:loadViewIn forKey:format];
}

+ (void)setScaleAnimation:(CALayer *)layer duration:(CFTimeInterval)duration
{
    CABasicAnimation *zoomInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomInAnimation.fromValue = @0.9f;
    zoomInAnimation.toValue = @1.1f;
    
    CABasicAnimation *zoomOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOutAnimation.fromValue = @1.1f;
    zoomOutAnimation.toValue = @0.9f;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = duration;
    groupAnimation.repeatCount = HUGE_VALF;
    groupAnimation.autoreverses = YES;
    groupAnimation.animations = [NSArray arrayWithObjects:zoomInAnimation, zoomOutAnimation, nil];
    
    [layer addAnimation:groupAnimation forKey:@"scale.animations"];
}

+ (void)setMoveXAnimation:(CALayer *)layer fromValue:(float)fromValue toValue:(float)toValue duration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [layer addAnimation:animation forKey:@"translation"];
}

@end
