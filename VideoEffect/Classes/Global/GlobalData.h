//
//  GlobalData.h
//  A Day in The Life
//
//  Created by iDeveloper on 7/26/12.
//  Copyright (c) 2012 HongJi Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AnimationUtils.h"
#import "UIHelpers.h"
#import "SVProgressHUD.h"

@interface GlobalData : NSObject
{
}

@property (nonatomic, strong) NSURL *currentVideoURL;
@property (nonatomic, readwrite) CGSize currentMediaSize;

+ (id)sharedData;

- (void)loadInitData;
- (void)resetData;

- (void)setPurchasedPackage:(int)index;

- (BOOL)readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults;
- (float)readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults;
- (int)readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults;
- (double)readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults;
- (NSString *)readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults;

// check that an email address is valid.
- (BOOL)NSStringIsValidEmail:(NSString *)checkString;

- (NSString *)convertDateToString:(NSDate *)aDate format:(NSString *)format;
- (NSString *)stringFromColor:(UIColor *)color;

@end
