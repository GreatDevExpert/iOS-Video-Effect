//
//  VERecordViewController.h
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AVCamPreviewView.h"
#import "VEFlashView.h"

@interface VERecordViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    BOOL isCameraAvailable;
    
    VEFlashView *flashView;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onSelectVideo:(id)sender;
- (IBAction)onRecord:(id)sender;

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

@end
