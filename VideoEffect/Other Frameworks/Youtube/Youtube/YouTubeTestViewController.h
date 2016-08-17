//
//  YouTubeTestViewController.h
//  YouTubeTest
//
//  Created by Uri Nieto on 10/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveAndUploadManager.h"
#import <UIKit/UIKit.h>
#import "YouTubeUploader.h"

@interface YouTubeTestViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>{
    IBOutlet UIProgressView *mProgressView;
    
    IBOutlet UITextField *mTitleField;
    IBOutlet UITextView *mDescriptionField;
    
    IBOutlet UIButton *btnUpload;
    
    UITextView *activeField;
}

@property (nonatomic, retain) IBOutlet UITextField *mTitleField;
@property (nonatomic, retain) IBOutlet UITextView *mDescriptionField;
@property (nonatomic, retain) IBOutlet UIProgressView *mProgressView;
@property (nonatomic, retain) NSString* playURLString;
@property (nonatomic, assign) id<SaveAndUploadDelegate> pDelegate;
@property (nonatomic, retain) YouTubeUploader *youTubeUploader;

- (IBAction)uploadPressed:(id)sender;
- (IBAction)uploadCanceled:(id)sender;

- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;


@end

