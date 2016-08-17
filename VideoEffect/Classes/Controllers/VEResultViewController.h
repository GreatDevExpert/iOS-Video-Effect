//
//  VEResultViewController.h
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SaveAnduploadManager.h"

@interface VEResultViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, SaveAndUploadDelegate> {
    
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    
    NSTimer * timer;
    double currentTime;
    int durationTime;
    
    UIPopoverController *popover;
}

@property (nonatomic, assign) IBOutlet UIView *viewVideo;
@property (nonatomic, assign) IBOutlet UIButton *btnReplay;
@property (nonatomic, assign) IBOutlet UIButton *btnPlayAndPause;

- (IBAction)onReplay:(id)sender;
- (IBAction)onPlayAndPause:(id)sender;
- (IBAction)onRewind:(id)sender;

- (IBAction)onBack:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onDelete:(id)sender;

@end
