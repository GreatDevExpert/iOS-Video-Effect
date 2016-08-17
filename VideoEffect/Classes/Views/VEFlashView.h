//
//  VEFlashView.h
//  VideoEffect
//
//  Created by iDeveloper on 2/18/14.
//  Copyright (c) 2014 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEFlashView : UIView {
    BOOL animationRunning;
}



- (void)startFlashAnimation:(BOOL)isReady;
- (void)stopFlashAnimation;

@end
