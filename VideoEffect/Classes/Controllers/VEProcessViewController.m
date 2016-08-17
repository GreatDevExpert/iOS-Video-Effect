//
//  VEProcessViewController.m
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VEProcessViewController.h"
#import "VEResultViewController.h"

@interface VEProcessViewController ()
@end

@implementation VEProcessViewController

@synthesize viewVideo, viewControl;
@synthesize progressBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!IS_IPAD)
        nibNameOrNil = [nibNameOrNil stringByAppendingString:@"~iPhone"];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (IS_IPAD)
            [[UIProgressView appearance] setFrame:CGRectMake(77, 20, 802, 10)];
        else
            [[UIProgressView appearance] setFrame:CGRectMake(30, 8, 310, 10)];
        [[UIProgressView appearance] setTrackImage:[UIImage imageNamed:@"4th-Page_0016_slide-total"]];
        [[UIProgressView appearance] setProgressImage:[UIImage imageNamed:@"4th-Page_0015_slide-current"]];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    durationTime = 0;
    
    [VideoManager sharedManager].delegate = self;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return SUPPORTED_ORIENTATION_MASK;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return SUPPORTED_ORIENTATION;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (IS_IPAD)
        [[UIProgressView appearance] setFrame:CGRectMake(77, 20, 802, 10)];
    else
        [[UIProgressView appearance] setFrame:CGRectMake(30, 8, 310, 10)];

    [[UIProgressView appearance] setTrackImage:[UIImage imageNamed:@"4th-Page_0016_slide-total"]];
    [[UIProgressView appearance] setProgressImage:[UIImage imageNamed:@"4th-Page_0015_slide-current"]];
    
    [super viewWillAppear:animated];
    
    progressBar.hidden = YES;
    
    trimControl = nil;
    
    if (_globalData.currentVideoURL) {
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:_globalData.currentVideoURL options:nil];
        CMTime duration = sourceAsset.duration;
        
        NSArray *tracks = [sourceAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = [tracks objectAtIndex:0];
        _globalData.currentMediaSize = track.naturalSize;
        
        durationTime = CMTimeGetSeconds(duration) + 0.5f;
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_globalData.currentVideoURL];
        avPlayer = [[AVPlayer playerWithPlayerItem:playerItem] retain];
        avPlayerLayer = [[AVPlayerLayer playerLayerWithPlayer:avPlayer] retain];
        
        avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewVideo.frame), CGRectGetHeight(self.viewVideo.frame));
        [avPlayerLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewVideo.layer addSublayer:avPlayerLayer];
        
        [avPlayer pause];
        
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        if (durationTime < 7) {
            [UIHelpers showAlertWithTitle:@"Warning" msg:@"video is shorter than 7 seconds"];
        }
        
        if (durationTime > 6) {
            trimControl = [[RETrimControl alloc] initWithFrame:CGRectMake(10, (IS_IPAD ? 0 : 3), CGRectGetWidth(viewControl.frame), (IS_IPAD ? 50 : 28))];
            CGFloat startPoint = 3.0f * 100.0f / durationTime;
            trimControl.leftValue = startPoint; // insert video
            CGFloat endPoint = startPoint + 3.0f * 100.0f / durationTime;
            trimControl.rightValue = endPoint;
            trimControl.length = 100;
            trimControl.delegate = self;
            
            [viewControl addSubview:trimControl];
            
            _sinceInsertVideo = 3;
            
        } else if (durationTime > 3) {
            trimControl = [[RETrimControl alloc] initWithFrame:CGRectMake(10, (IS_IPAD ? 0 : 3), CGRectGetWidth(viewControl.frame), (IS_IPAD ? 50 : 28))];
            CGFloat startPoint = 1.0f * 100.0f / durationTime;
            trimControl.leftValue = startPoint; // insert video
            CGFloat endPoint = startPoint + 3.0f * 100.0f / durationTime;
            trimControl.rightValue = endPoint;
            trimControl.length = 100;
            trimControl.delegate = self;
            [viewControl addSubview:trimControl];
            
            _sinceInsertVideo = 1;
        } else {
            _sinceInsertVideo = 0;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [avPlayer pause];
    [avPlayer release];
    avPlayer = nil;
    
    [avPlayerLayer removeAllAnimations];
    [avPlayerLayer removeFromSuperlayer];
    [avPlayerLayer release];
    avPlayerLayer = nil;
    
    [viewVideo.layer setSublayers:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onProcess:(id)sender
{
    trimControl.hidden = YES;
    [trimControl removeFromSuperview];
    progressBar.progress = 0;
    progressBar.hidden = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [SVProgressHUD showProgress:-1 status:@"Please Wait..." maskType:SVProgressHUDMaskTypeClear];

    [[VideoManager sharedManager] mergeVideoWithHandler:_globalData.currentVideoURL effectIndex:_currentEffectIndex completionHandler:^(BOOL success, NSURL *url) {
        
        [SVProgressHUD dismiss];
        if (success) {
            VEResultViewController *viewController = [[[VEResultViewController alloc] initWithNibName:@"VEResultViewController" bundle:nil] autorelease];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            [UIHelpers showAlertWithTitle:@"Failed" msg:@""];
        }
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }];
}

#pragma mark - VideoManagerDelegate
- (void)changedProgress:(float)value
{
    progressBar.progress = value;
}

#pragma mark -
#pragma mark RETrimControlDelegate

- (void)trimControl:(RETrimControl *)trimControl didChangeLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue
{
//    NSLog(@"Left = %f, right = %f", leftValue, rightValue);
    _sinceInsertVideo = (int)durationTime * leftValue / 100.0f;
    CMTime newTime = CMTimeMakeWithSeconds(_sinceInsertVideo, 1);
    [avPlayer seekToTime:newTime];
}

@end
