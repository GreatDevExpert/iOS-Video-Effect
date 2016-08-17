//
//  VEFlashView.m
//  VideoEffect
//
//  Created by iDeveloper on 2/18/14.
//  Copyright (c) 2014 iDeveloper. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "VEFlashView.h"

@implementation VEFlashView

#define FLASH_ANIMATION_TIMEOUT 0.7

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.hidden = YES;
    }
    return self;
}

- (void)startFlashAnimation:(BOOL)isReady
{
    if (animationRunning) {
        self.layer.borderColor = isReady ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        self.layer.borderWidth = 5;
        return;
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.layer.borderColor = isReady ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
    self.layer.borderWidth = 5;
    
    animationRunning = YES;
    self.hidden = NO;
    
    [self fadeOut:nil finished:nil context:nil];
}

- (void)stopFlashAnimation
{
    animationRunning = NO;
    [self.layer removeAllAnimations];
    [UIView setAnimationDelegate:nil];

    self.hidden = YES;
}

- (void)fadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:FLASH_ANIMATION_TIMEOUT];
    [UIView  setAnimationDelegate:self];
    if(animationRunning){
        [UIView setAnimationDidStopSelector:@selector(fadeIn:finished:context:) ];
    }
    [self setAlpha:0.2];
    [UIView commitAnimations];
}

- (void)fadeIn:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:FLASH_ANIMATION_TIMEOUT];
    [UIView  setAnimationDelegate:self];
    if(animationRunning){
        [UIView setAnimationDidStopSelector:@selector(fadeOut:finished:context:) ];
    }
    [self setAlpha:1.00];
    [UIView commitAnimations];
}

@end
