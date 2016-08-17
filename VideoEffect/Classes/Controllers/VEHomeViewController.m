//
//  VEHomeViewController.m
//  VideoEffect
//
//  Created by iDeveloper on 12/5/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VEHomeViewController.h"
#import "VESelectViewController.h"

#import "VEFlashView.h"

@interface VEHomeViewController ()

@end

@implementation VEHomeViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return (IS_IPAD ? NO : YES);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION_MASK;
}

- (IBAction)onStart:(id)sender
{
    VESelectViewController *viewController = [[[VESelectViewController alloc] initWithNibName:@"VESelectViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
