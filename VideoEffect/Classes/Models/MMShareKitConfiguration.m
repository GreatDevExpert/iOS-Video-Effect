//
//  MMShareKitConfiguration.m
//
//  Created by Lion on 12/9/12.
//  Copyright (c) 2012 Lion. All rights reserved.
//


#import "MMShareKitConfiguration.h"

@implementation MMShareKitConfiguration

// Application
- (NSString*)appName {
	return @"Fear Effect";
}

- (NSString*)appURL {
	return @"http://72.249.31.73/~ipadkios";
}

// Facebook
- (NSString*)facebookAppId {
	return @"158057040992377";
}

- (NSString*)facebookLocalAppId {
	return @"";
}

// Twitter
- (NSNumber*)forcePreIOS5TwitterAccess {
	return [NSNumber numberWithBool:false];
}

- (NSString*)twitterConsumerKey {
	return @"ZeljUxbduLU5ryPCuGJz2Q";
}

- (NSString*)twitterSecret {
	return @"FwQxVFYa0QjtDqPDJfaotqrydn0Top4D0adBKsd0Y";
}

- (NSString*)twitterCallbackUrl {
	return @"http://diamond.com/ipadkios";
}

- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}

- (NSString*)twitterUsername {
	return @"buadren";
}

// UI
- (NSString*)barStyle {
	return @"UIBarStyleBlack";
}

- (UIColor*)barTintForView:(UIViewController*)vc {
	
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKTwitter"])
        return [UIColor colorWithRed:0 green:151.0f/255 blue:222.0f/255 alpha:1];
    
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKFacebook"])
        return [UIColor colorWithRed:59.0f/255 green:89.0f/255 blue:152.0f/255 alpha:1];
    
    return nil;
}
@end
