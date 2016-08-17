//
//  SaveAndUploadManager.h
//
//  Created by Lion on 12/2/12.
//  Copyright (c) 2012 Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VEAppDelegate.h"
#import "FBConnect.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol SaveAndUploadDelegate <NSObject>
- (void)uploadedVideo;
@end

@interface SaveAndUploadManager : NSObject <MFMailComposeViewControllerDelegate, UIAlertViewDelegate,FBSessionDelegate>
{
    float progressValue;
    bool isNew;
	BOOL m_bPermission;
	UIImageView* m_pUploadingView;
	NSString* m_playURLString;
    
}
@property (atomic, assign) NSArray *m_PictArray;
@property (nonatomic, assign) UIProgressView *progressView;
@property (nonatomic, assign) id<SaveAndUploadDelegate> pDelegate;
@property (nonatomic, assign) UIViewController *parentController;

+ (SaveAndUploadManager*) sharedManager;
+ (void) releaseManager;

-(void) saveToLibrary;
-(void) uploadFacebook;
-(void) uploadTwitter;
-(void) uploadYoutube;
- (void) sendEmail;

@end
