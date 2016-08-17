//
//  VEAppDelegate.m
//  VideoEffect
//
//  Created by iDeveloper on 12/5/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VEAppDelegate.h"
#import "VideoManager.h"

#import "SHKConfiguration.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKMail.h"
#import "MMShareKitConfiguration.h"
#import "SHKTextMessage.h"

#import "Appirater.h"

@implementation UINavigationController (rotationproblem)

- (BOOL)shouldAutorotate
{
    return (IS_IPAD ? NO : YES);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION_MASK;
}

@end

@implementation VEAppDelegate

+ (VEAppDelegate *) sharedAppDelegate
{
    return (VEAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    
    [super dealloc];
}
//
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return SUPPORTED_ORIENTATION_MASK;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[GlobalData sharedData] loadInitData];
    _currentEffectIndex = 1;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    NSString *nibName = @"VENavViewController";
    if (!IS_IPAD)
        nibName = [nibName stringByAppendingString:@"~iPhone"];

    self.viewController = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:0];
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    
    [[VideoManager sharedManager] clearTempDirectory];
    
    DefaultSHKConfigurator *configurator = [[MMShareKitConfiguration alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    shareDelegate = [[SHKSharerDelegate alloc] init];
    
    [Appirater setAppId:@"816384936"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma facebook delegate


// Facebook page delegate
- (BOOL)handleOpenURL:(NSURL*)url
{
	NSString* scheme = [url scheme];
    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
        return [SHKFacebook handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [self handleOpenURL:url];
}

// Sharer delegate
- (void)sharerStartedSending:(SHKSharer *)sharer
{
	[shareDelegate sharerStartedSending:sharer];
}

- (void)sharerFinishedSending:(SHKSharer *)sharer
{
    if ([sharer isKindOfClass:[SHKFacebook class]]) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Facebook post successful!"];
    }
    else if ([sharer isKindOfClass:[SHKTwitter class]]) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Twitter post successful!"];
    }
    else if ([sharer isKindOfClass:[SHKMail class]]) {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Email sent!"];
    }
    else if ( [sharer isKindOfClass:[SHKTextMessage class]])
    {
        [[SHKActivityIndicator currentIndicator] displayCompleted:@"Email sent!"];
    }
    else {
        [[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Saved!")];
    }
    [self delayedLogout];
}

- (void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success
{
    [shareDelegate sharerAuthDidFinish:sharer success:success];
}

- (void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin
{
    [shareDelegate sharer:sharer failedWithError:error shouldRelogin:shouldRelogin];
    [self delayedLogout];
}

- (void)sharerCancelledSending:(SHKSharer *)sharer
{
    [shareDelegate sharerCancelledSending:sharer];
    [self delayedLogout];
}

- (void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer
{
    [shareDelegate sharerShowBadCredentialsAlert:sharer];
}

- (void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer
{
    [shareDelegate sharerShowOtherAuthorizationErrorAlert:sharer];
}

- (void)logoutOfAllServices
{
    [SHK logoutOfAll];
}

- (void)delayedLogout
{
    if (logoutTimer != nil) {
        if ([logoutTimer isValid]) {
            [logoutTimer invalidate];
        }
        logoutTimer = nil;
    }
    logoutTimer = [[NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(logoutOfAllServices) userInfo:nil repeats:NO] retain];
}

@end
