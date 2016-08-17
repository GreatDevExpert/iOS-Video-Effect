//
//  SaveAndUploadManager.m
//
//  Created by Lion on 12/2/12.
//  Copyright (c) 2012 Lion. All rights reserved.
//

#import "SaveAndUploadManager.h"
#import "YouTubeTestViewController.h"
#import "SHKFacebook.h"

#define CLIENT_ID        @"482626834412-68bo8s4jbkes5omqor0g4bcgrfqrq8mf.apps.googleusercontent.com"
#define CLIENT_SECRET    @"OX-u1pHTw2qsX1aC6EbrrMSe"

// #define DEV_KEY          @"Find it at http://code.google.com/apis/youtube/dashboard/gwt/index.html"
// #define CLIENT_ID        @"Find it at https://code.google.com/apis/console under 'API Access'"
// #define CLIENT_SECRET    @"Find it there as well (GOOGLE APIs Console)"


static SaveAndUploadManager *_sharedManager = nil;
@implementation SaveAndUploadManager

@synthesize m_PictArray;
@synthesize progressView;
@synthesize pDelegate;

+ (SaveAndUploadManager*)sharedManager
{
    if (_sharedManager == nil)
    {
        _sharedManager = [[SaveAndUploadManager alloc] init];
    }
    return _sharedManager;
}

+ (void)releaseManager
{
    [_sharedManager release];
}

- (id)init
{
    if (self = [super init])
    {
        progressView = nil;
        
        // load share
        m_bPermission = NO;
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBaseDelegate:) name:@"SHKSendDidFinish" object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBaseDelegate:) name:@"SHKSendDidFailWithError" object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBaseDelegate:) name:@"SHKSendDidCancel" object:nil];
    }
    
    return self;
}

- (void)informUI
{
    //NSLog(@"value = %f",progressValue);
    progressView.progress = progressValue;
    [progressView setNeedsDisplay];
}

- (void)saveToLibrary
{
    [SVProgressHUD showProgress:-1 status:@"Save to CameraRoll" maskType:SVProgressHUDMaskTypeClear];
    UISaveVideoAtPathToSavedPhotosAlbum([_globalData.currentVideoURL relativePath], nil, nil, nil);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:_globalData.currentVideoURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    [SVProgressHUD dismiss];
                                    [self.pDelegate uploadedVideo];
                                }];
    [library release];
}

- (void)uploadFacebook
{
    NSData *file = [NSData dataWithContentsOfFile:[_globalData.currentVideoURL relativePath]];
    SHKItem *item = [SHKItem file:file filename:@"Fear Effect.mp4" mimeType:@
                     "video/mp4" title:@"Video Effect"];
    //SHKItem *item = [SHKItem text:@"test"];
    SHKFacebook *sharer = [[[SHKFacebook alloc] init] autorelease];
    VEAppDelegate *delegate = (VEAppDelegate*)[UIApplication sharedApplication].delegate;
    sharer.shareDelegate = delegate;
    [sharer loadItem:item];
    [sharer share];
}

- (void)uploadTwitter
{

}

- (void)uploadYoutube
{
    YouTubeTestViewController* youtubeViewController;
    youtubeViewController = [[YouTubeTestViewController alloc] initWithNibName:@"YouTubeTestViewController" bundle:nil];
    youtubeViewController.playURLString = [_globalData.currentVideoURL relativePath];
    youtubeViewController.pDelegate = self.pDelegate;
    [self.parentController presentViewController:youtubeViewController animated:YES completion:nil];
    [youtubeViewController release];
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Fear Effect Video"];
	// Set up recipients
	//NSArray *toRecipients = [NSArray arrayWithObject:@""];
	//[picker setToRecipients:toRecipients];
	
	//Attach an image to the email
	
	NSData *myData = [NSData dataWithContentsOfFile:[_globalData.currentVideoURL relativePath]];
	[picker addAttachmentData:myData mimeType:@"video/mov" fileName:@"FearEffect.mov"];
	
	// Fill out the email body text
//	NSString *emailBody = @"Hi Please check this fun and usefull video effect app on the appstore - Fear Effect :) -"; //added newly
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	[self.parentController presentViewController:picker animated:YES completion:nil];
    [picker release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    [self.pDelegate uploadedVideo];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	NSString* message;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			message = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			message = @"Mail was sent";
			break;
		case MFMailComposeResultFailed:
			message = @"Result: failed";
			break;
		default:
			message = @"Result: not sent";
			break;
	}
	//UIAlertView* alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
	//alert.tag = ALERT_TAG_SENDEMAIL;
	//[alert show];
	//[alert release];
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self.pDelegate uploadedVideo];
}

- (void)launchMailAppOnDevice
{
	NSString *recipients = @"";
	NSString *body = @"&body=";
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)sendEmail
{
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

- (void) updateBaseDelegate:(id) sender;
{
    [self.pDelegate uploadedVideo];
}

@end
