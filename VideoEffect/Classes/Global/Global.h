//
//  Global.h
//  A Day in The Life
//
//  Created by iDeveloper on 6/21/12.
//  Copyright (c) 2012 HongJi Software. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

#import "GlobalData.h"

#pragma mark - Define MACRO -

// screen
#define IS_WIDESCREEN   (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPAD         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE       (([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) || ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]))
#define IS_IPOD         ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
#define IS_IPHONE_5     (IS_IPHONE && IS_WIDESCREEN)
#define IOS_VERSION     [[[UIDevice currentDevice] systemVersion] floatValue]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define SUPPORTED_ORIENTATION_MASK  UIInterfaceOrientationMaskLandscapeRight
#define SUPPORTED_ORIENTATION       UIInterfaceOrientationLandscapeRight

#pragma mark - Define Variable -
extern GlobalData *_globalData;
extern int _currentEffectIndex;
extern int _sinceInsertVideo;

extern BOOL _isLockPackage1;
extern BOOL _isLockPackage2;
extern BOOL _isLockPackage3;

#define PLAY_VIDEO_TIMEOUT 0.2f

#define IAP_KEY_PACKAGE1 @"purchased_package1"
#define IAP_KEY_PACKAGE2 @"purchased_package2"
#define IAP_KEY_PACKAGE3 @"purchased_package3"

#define USER_PATH [NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES) lastObject]
#define SAVE_IMAGE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define TEMP_IMAGE_PATH [NSTemporaryDirectory() stringByAppendingString:@"/image.png"]

#define SAVE_DATA_KEY @"stored_data"
#define SHOW_FIRSTTIME_TIP @"show_tip"

#define CONFIG_CURRENT_PLAYER @"current_player"

#define COMPONENTS_JOINED_BY_STRING @", "

