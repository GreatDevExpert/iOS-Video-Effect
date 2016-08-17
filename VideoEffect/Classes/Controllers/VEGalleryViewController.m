//
//  VEGalleryViewController.m
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "VEGalleryViewController.h"
#import "VEResultViewController.h"

#import "UIImage+Resize.h"

@interface VEGalleryViewController ()
@property (nonatomic, strong) NSArray *files;
@end

@implementation VEGalleryViewController
@synthesize scrollView;
@synthesize files;

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
    self.files = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
}

- (BOOL)shouldAutorotate
{
	return (IS_IPAD ? NO : YES);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == SUPPORTED_ORIENTATION);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return SUPPORTED_ORIENTATION;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *galleryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"gallery"];
    
    NSFileManager *manger = [NSFileManager defaultManager];
    NSArray *dirFiles = [manger contentsOfDirectoryAtPath:galleryPath error:nil];
    self.files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mov'"]];
    
    int posX = IS_IPAD ? 38 : (IS_WIDESCREEN ? 31 : 20);
    int posY = IS_IPAD ? 38 : (IS_WIDESCREEN ? 31 : 20);
    int row = 0, column = 0;
    int w = IS_IPAD ? 180 : 80;
    int h = IS_IPAD ? 180 : 80;
    int cw = IS_IPAD ? 256 : (IS_WIDESCREEN ? 142 : 120);
    int ch = IS_IPAD ? 210 : (IS_WIDESCREEN ? 116 : 98);
    
    for (int i = 0; i < self.files.count; i++) {
        @autoreleasepool {
            
            UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(posX + column * cw, posY + row * ch, w, h)];
            [videoView setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:74.f/255.f blue:125.f/255.f alpha:1.0f]];
            videoView.clipsToBounds = YES;
            videoView.layer.cornerRadius = 2.f;
            [scrollView addSubview:videoView];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(2, 2, w-4, h-4)];
            [button setBackgroundColor:[UIColor blackColor]];
            [button addTarget:self action:@selector(onChooseVideo:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+1;
            UIImageView *playImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4th-Page_0014_play"]];
            [playImage setFrame:CGRectMake(0, 0, (IS_IPAD ? 22 : 10), (IS_IPAD ? 26 : 12))];
            playImage.center = CGPointMake(w/2, h/2);
            
            [videoView addSubview:button];
            [button addSubview:playImage];
            [playImage release];
            
            NSString *thumbImagePath = [galleryPath stringByAppendingString:[[self.files objectAtIndex:i] lastPathComponent]];
            thumbImagePath = [thumbImagePath stringByAppendingPathExtension:@"png"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:thumbImagePath]) {
                
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbImagePath];
                [button setImage:thumbImage forState:UIControlStateNormal];
                
            } else {
            
                NSURL *videoURl = [NSURL fileURLWithPath:[galleryPath stringByAppendingPathComponent:[self.files objectAtIndex:i]]];
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
                AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generate.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 60);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *thumbImage = [[UIImage alloc] initWithCGImage:imgRef];
                thumbImage = [[thumbImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(180, 180) interpolationQuality:kCGInterpolationDefault] retain];
                
                if (![UIImagePNGRepresentation(thumbImage) writeToFile:thumbImagePath atomically:YES]) {
                    NSLog(@"save thumbnail image error : %@", thumbImagePath);
                }
                
                [button setImage:thumbImage forState:UIControlStateNormal];
                
                [thumbImage release];
                CGImageRelease(imgRef);
                [generate release];
                [asset release];
                [videoView release];
            }
            
            column++;
            if (column > 3) {
                row++;
                column = 0;
            }
        }
    }
    
    [scrollView setContentSize:CGSizeMake(0, row * ch + cw)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [scrollView.layer setSublayers:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onChooseVideo:(id)sender;
{
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *galleryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"gallery"];
    _globalData.currentVideoURL = [NSURL fileURLWithPath:[galleryPath stringByAppendingPathComponent:[self.files objectAtIndex:[sender tag]-1]]];
    NSLog(@"selected video : %@", _globalData.currentVideoURL);
    
    VEResultViewController *viewController = [[[VEResultViewController alloc] initWithNibName:@"VEResultViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
