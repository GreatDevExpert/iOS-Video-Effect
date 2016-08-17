//
//  VESelectViewController.h
//  VideoEffect
//
//  Created by iDeveloper on 12/6/13.
//  Copyright (c) 2013 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "MKStoreManager.h"

@interface VESelectViewController : UIViewController <iCarouselDataSource, iCarouselDelegate,
                                                MKStoreManagerDelegate, UIAlertViewDelegate> {
    int currentPurchasePackage;
}

@property (nonatomic, strong) IBOutlet iCarousel *carousel;

- (IBAction)onFearEffect:(id)sender;
- (IBAction)onGallery:(id)sender;
- (IBAction)onRestore:(id)sender;

@end
