//
//  VESelectViewController.m
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VESelectViewController.h"
#import "VERecordViewController.h"
#import "VEGalleryViewController.h"

@interface VESelectViewController ()

@end

@implementation VESelectViewController

@synthesize carousel = _carousel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!IS_IPAD)
        nibNameOrNil = [nibNameOrNil stringByAppendingString:@"~iPhone"];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_carousel removeFromSuperview];
    self.carousel = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _currentEffectIndex = 1;
    currentPurchasePackage = 0;

    _carousel.type = iCarouselTypeCylinder;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION_MASK;
}

- (IBAction)onFearEffect:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onGallery:(id)sender
{
    VEGalleryViewController *viewController = [[[VEGalleryViewController alloc] initWithNibName:@"VEGalleryViewController" bundle:nil] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    navController.navigationBarHidden = YES;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark  - iCarousel methods
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return 11;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        CGRect frameRect = CGRectMake(0, 0, IS_IPAD ? 530 : 240, IS_IPAD ? 370 : 160);
        view = [[[UIImageView alloc] initWithFrame:frameRect] autorelease];
        ((UIImageView *)view).image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_video%d", index+1]];
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([self getLockStatus:index+1]) {
            view.alpha = 0.9f;
            
            UIImageView *lockImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IS_IPAD ? 40 : 25, IS_IPAD ? 45 : 28)] autorelease];
            [lockImageView setImage:[UIImage imageNamed:@"Lock"]];
            lockImageView.center = view.center;
            [view addSubview:lockImageView];
        } else {
            view.alpha = 1.0f;
        }
    }
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (carousel.currentItemIndex != index)
        return;
    
      NSString *unlockMessage = nil;
    if (index > 8) {
        unlockMessage = @"Unlock Monster Pack 3, George and Happy?";
        currentPurchasePackage = 3;
    } else if (index > 5) {
        unlockMessage = @"Unlock Monster Pack 2, Frankie, Slim and Mummy?";
        currentPurchasePackage = 2;
    } else if (index > 2) {
        unlockMessage = @"Unlock Monster Pack 1, Nosferatu, Diablo and Grey?";
        currentPurchasePackage = 1;
    }
    
    if ([self getLockStatus:carousel.currentItemIndex+1]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:unlockMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Unlock", nil];
        [alert show];
        return;
    }
    
    _currentEffectIndex = carousel.currentItemIndex + 1;

    VERecordViewController *viewController = [[[VERecordViewController alloc] initWithNibName:@"VERecordViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)getLockStatus:(int)index
{
    BOOL isLock = NO;
    if (index > 9) {
        if (_isLockPackage3)
            isLock = YES;
    } else if (index > 6) {
        if (_isLockPackage2)
            isLock = YES;
    } else if (index > 3) {
        if (_isLockPackage1)
            isLock = YES;
    }
    
    return isLock;
}

#pragma mark IAP
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) { // Unlock button clicked
		[self buyPackage];
	}
}

- (void)reconfigureUI
{
    [self.carousel reloadData];
}

- (void)buyPackage
{
    if (currentPurchasePackage < 1)
        return;
    
    [[MKStoreManager sharedManager] setUiDelegate:self];
    [[MKStoreManager sharedManager] buyPackage:currentPurchasePackage];
    [SVProgressHUD showWithStatus:@"Connecting..." maskType:SVProgressHUDMaskTypeClear];
}

- (IBAction)onRestore:(id)sender
{
    [[MKStoreManager sharedManager] setUiDelegate:self];
    [[MKStoreManager sharedManager] restorePurchase];
}

@end
