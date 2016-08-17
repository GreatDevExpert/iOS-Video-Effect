//
//  VEGalleryViewController.h
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEGalleryViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;

- (IBAction)onBack:(id)sender;
- (IBAction)onChooseVideo:(id)sender;

@end
