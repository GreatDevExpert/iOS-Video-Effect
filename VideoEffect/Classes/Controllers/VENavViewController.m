//
//  BNNavViewController.m
//  BottlesNightOut
//
//  Created by iDeveloper on 7/19/13.
//  Copyright (c) 2013 iDevelopers. All rights reserved.
//

#import "VENavViewController.h"

@interface VENavViewController ()

@end

@implementation VENavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    
    [self setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION_MASK;
}

- (void)replaceLastWith:(UIViewController *)controller animated:(BOOL)animated
{
    NSMutableArray *stactViewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [stactViewControllers removeLastObject];
    [stactViewControllers addObject:controller];
    [self setViewControllers:stactViewControllers animated:animated];
}

@end
