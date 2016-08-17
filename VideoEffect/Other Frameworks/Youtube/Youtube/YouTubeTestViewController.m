//
//  YouTubeTestViewController.m
//  YouTubeTest
//
//  Created by Uri Nieto on 10/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "YouTubeTestViewController.h"

@implementation YouTubeTestViewController

@synthesize mProgressView;
@synthesize mTitleField;
@synthesize mDescriptionField;
@synthesize playURLString;
@synthesize youTubeUploader;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    // Too lazy to create different IBOutlets, they are UITextFields for the future...
    [mTitleField setText:@""];
	[mDescriptionField setText:@""];
	[self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    [mTitleField release];
    [mDescriptionField release];
    [mProgressView release];
    self.youTubeUploader = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];

    [super dealloc];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)uploadPressed:(id)sender {
    [mTitleField resignFirstResponder];
    [mDescriptionField resignFirstResponder];
    self.youTubeUploader = [[YouTubeUploader alloc] init];
    self.youTubeUploader.delegate = self;
    self.youTubeUploader.uploadProgressView = mProgressView;
    self.youTubeUploader.mediaDescription = [mDescriptionField text];
    self.youTubeUploader.mediaTitle = [mTitleField text];
    [self.youTubeUploader uploadVideoFile:self.playURLString];
}

- (IBAction)uploadCanceled:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
    [self.pDelegate uploadedVideo];
}
#pragma mark -



#pragma mark UIAlertView delegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
	[self dismissViewControllerAnimated:YES completion:nil];
    [self.pDelegate uploadedVideo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
//    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

//    if (activeField != nil && self.view.frame.origin.y == 0 ) {
//		[UIView beginAnimations: @"anim" context: nil];     
//		[UIView setAnimationBeginsFromCurrentState: YES];     
//		[UIView setAnimationDuration: 0.3];     
//		self.view.frame = CGRectOffset(self.view.frame, 0, -mDescriptionField.frame.size.height);     
//		[UIView commitAnimations]; 
//		
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//	if (activeField == nil && self.view.frame.origin.y < 0) {
//		[UIView beginAnimations: @"anim" context: nil];     
//		[UIView setAnimationBeginsFromCurrentState: YES];     
//		[UIView setAnimationDuration: 0.3];     
//		self.view.frame = CGRectOffset(self.view.frame, 0, mDescriptionField.frame.size.height);     
//		[UIView commitAnimations]; 
//	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
	activeField = textView;
	[UIView beginAnimations: @"anim" context: nil];     
	[UIView setAnimationBeginsFromCurrentState: YES];     
	[UIView setAnimationDuration: 0.3];
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)		
		self.view.frame = CGRectOffset(self.view.frame, 0, -(100));
	else 
		self.view.frame = CGRectOffset(self.view.frame, 0, -(100));     
	[UIView commitAnimations]; 
}
- (void)textViewDidEndEditing:(UITextView *)textView{
	activeField = nil;
	[UIView beginAnimations: @"anim" context: nil];     
	[UIView setAnimationBeginsFromCurrentState: YES];     
	[UIView setAnimationDuration: 0.3];     
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)		
		self.view.frame = CGRectOffset(self.view.frame, 0, (100));
	else 
		self.view.frame = CGRectOffset(self.view.frame, 0, 100);
	[UIView commitAnimations]; 
}

@end
