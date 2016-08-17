//
//  VEAppDelegate.h
//  VideoEffect
//
//  Created by iDeveloper on 12/5/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VENavViewController.h"
#import "SaveAndUploadManager.h"
#import "SHKSharer.h"
#import "SHKSharerDelegate.h"

@interface UINavigationController (rotationproblem)

- (BOOL)shouldAutorotate;

@end

@interface VEAppDelegate : UIResponder <UIApplicationDelegate, SHKSharerDelegate> {
    NSTimer *logoutTimer;
    SHKSharerDelegate *shareDelegate;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) VENavViewController *viewController;

@end
