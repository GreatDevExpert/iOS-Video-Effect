//
//  VEResultViewController.m
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import "VEResultViewController.h"
#import "YouTubeTestViewController.h"

@interface VEResultViewController ()
@property (nonatomic, assign) BOOL isPlay;
@end

@implementation VEResultViewController

@synthesize viewVideo;
@synthesize btnReplay, btnPlayAndPause;
@synthesize isPlay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!IS_IPAD)
        nibNameOrNil = [nibNameOrNil stringByAppendingString:@"~iPhone"];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    currentTime = 0;
    durationTime = 0;
    
    isPlay = NO;
    
    [SaveAndUploadManager sharedManager].parentController = self;
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

- (void)loadVideo
{
    if (_globalData.currentVideoURL) {
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:_globalData.currentVideoURL options:nil];
        CMTime duration = sourceAsset.duration;
        
        durationTime = ceil(duration.value/duration.timescale);
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_globalData.currentVideoURL];
        avPlayer = [[AVPlayer playerWithPlayerItem:playerItem] retain];
        avPlayerLayer = [[AVPlayerLayer playerLayerWithPlayer:avPlayer] retain];
        
        avPlayerLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewVideo.frame), CGRectGetHeight(self.viewVideo.frame));
        [avPlayerLayer setBackgroundColor:[UIColor blackColor].CGColor];
        [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];

        [viewVideo.layer addSublayer:avPlayerLayer];
        
        [avPlayer pause];
        
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(loadVideo) withObject:nil afterDelay:0.5f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[avPlayer currentItem]];

    [timer invalidate];
    timer = nil;

    [avPlayer pause];
    [avPlayer release];
    avPlayer = nil;
    
    [avPlayerLayer removeAllAnimations];
    [avPlayerLayer removeFromSuperlayer];
    [avPlayerLayer release];
    avPlayerLayer = nil;
    
    [viewVideo.layer setSublayers:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    btnReplay.hidden = NO;
    
    isPlay = NO;
    [btnPlayAndPause setImage:[UIImage imageNamed:@"5th-Page_play1_button"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onReplay:(id)sender
{
    btnReplay.hidden = YES;
    
    [self onPlayAndPause:nil];
}

- (IBAction)onPlayAndPause:(id)sender
{
    isPlay = !isPlay;

    if (isPlay) {
        
        [avPlayer play];
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:PLAY_VIDEO_TIMEOUT target:self selector:@selector(playTimeout) userInfo:nil repeats:YES];
        
    } else {
        [avPlayer pause];
        
        [timer invalidate];
        timer = nil;
    }

    btnReplay.hidden = isPlay;
    [btnPlayAndPause setImage:[UIImage imageNamed:(isPlay ? @"5th-Page_pause_button.png" : @"5th-Page_play1_button")] forState:UIControlStateNormal];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onShare:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Video"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Upload to Youtube", @"Share to Facebook", @"Send via Email", @"Save to Library", nil];
    [actionSheet showFromRect:CGRectMake(700, 685, 400, 580) inView:self.view animated:YES];
    [actionSheet release];
}

- (IBAction)onRewind:(id)sender
{
    isPlay = NO;
    
    [timer invalidate];
    timer = nil;
    
    currentTime = 0;
    
    CMTime newTime = CMTimeMakeWithSeconds(0.0, 1);
    [avPlayer seekToTime:newTime];
    [avPlayer pause];
    
    btnReplay.hidden = YES;
    
    [self onPlayAndPause:nil];
}

- (IBAction)onDelete:(id)sender
{
    UIAlertView *resetAlert = [[[UIAlertView alloc] initWithTitle:@"Remove Video" message:@"This video will be deleted.\n Do you want to continue?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"DELETE!", nil] autorelease];
    [resetAlert show];
}

- (void)playTimeout
{
    if (currentTime >= durationTime) {
        
        [self onPlayAndPause:nil];

        currentTime = 0;
        
        CMTime newTime = CMTimeMakeWithSeconds(0.2, 1);
        [avPlayer seekToTime:newTime];
        [avPlayer pause];

        return;
    }
    
    currentTime += PLAY_VIDEO_TIMEOUT;
}

- (void)playerItemDidReachEnd:(NSNotificationCenter *)notification
{
    isPlay = NO;
    
    [timer invalidate];
    timer = nil;
    
    currentTime = 0;
    
    CMTime newTime = CMTimeMakeWithSeconds(0.0, 1);
    [avPlayer seekToTime:newTime];
    [avPlayer pause];
    
    [btnPlayAndPause setImage:[UIImage imageNamed:(isPlay ? @"5th-Page_pause_button" : @"5th-Page_play1_button")] forState:UIControlStateNormal];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // clicked ok
        if ([[NSFileManager defaultManager] fileExistsAtPath:_globalData.currentVideoURL.relativePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_globalData.currentVideoURL.relativePath error:nil];
            
            _globalData.currentVideoURL = nil;
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[SaveAndUploadManager sharedManager] uploadYoutube];
            break;
        case 1:
            [[SaveAndUploadManager sharedManager] uploadFacebook];
            break;
        case 2:
            [[SaveAndUploadManager sharedManager] sendEmail];
            break;
        case 3:
            [[SaveAndUploadManager sharedManager] saveToLibrary];
            break;
            
        default:
            break;
    }
}

- (void)uploadedVideo
{
    
}

@end
