//
//  VEProcessViewController.h
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoManager.h"
#import "RETrimControl.h"

@interface VEProcessViewController : UIViewController <VideoManagerDelegate, RETrimControlDelegate> {
    
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    
    int durationTime;
    
    RETrimControl *trimControl;
}

@property (nonatomic, assign) IBOutlet UIView *viewVideo;
@property (nonatomic, assign) IBOutlet UIView *viewControl;
@property (nonatomic, assign) IBOutlet UIProgressView *progressBar;

- (IBAction)onBack:(id)sender;
- (IBAction)onProcess:(id)sender;

@end
