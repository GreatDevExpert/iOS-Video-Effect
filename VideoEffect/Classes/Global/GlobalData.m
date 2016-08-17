//
//  GlobalData.m
//  A Day in The Life
//
//  Created by iDeveloper on 7/26/12.
//  Copyright (c) 2012 HongJi Soft. All rights reserved.
//


#import "GlobalData.h"
#import "Global.h"

GlobalData *_globalData = nil;
int _currentEffectIndex;
int _sinceInsertVideo = 3;
BOOL _isLockPackage1 = YES;
BOOL _isLockPackage2 = YES;
BOOL _isLockPackage3 = YES;

@implementation GlobalData

@synthesize currentVideoURL;
@synthesize currentMediaSize;

+(id) sharedData
{
	@synchronized(self)
    {
        if (_globalData == nil)
        {
            [[self alloc] init]; // assignment not done here
        }		
	}

	return _globalData;
}

//==================================================================================

+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (_globalData == nil)
        {
			_globalData = [super allocWithZone:zone];
			
			return _globalData;  
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}

//==================================================================================

-(id) init
{
	if ((self = [super init])) {
		// @todo
	}
	
	return self;
}

//==================================================================================

-(void) dealloc
{
    self.currentVideoURL = nil;
    self.currentMediaSize = CGSizeZero;

	[super dealloc];
}

//==================================================================================

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//==================================================================================

- (id)retain
{
    return self;
}

//==================================================================================

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

//==================================================================================

- (oneway void)release
{
    //do nothing
}

//==================================================================================

- (id)autorelease
{
    return self;
}

-(void) loadInitData
{
    self.currentVideoURL = nil;
    self.currentMediaSize = CGSizeZero;
    
    [self loadConfig];
}

- (void)loadConfig
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    _isLockPackage1 = [self readBoolEntry:config key:IAP_KEY_PACKAGE1 defaults:YES];
    _isLockPackage2 = [self readBoolEntry:config key:IAP_KEY_PACKAGE2 defaults:YES];
    _isLockPackage3 = [self readBoolEntry:config key:IAP_KEY_PACKAGE3 defaults:YES];
}

-(void) resetData
{
}

#pragma mark - Syncthesize Part -
- (void)setPurchasedPackage:(int)index
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];

    switch (index) {
        case 1:
            _isLockPackage1 = NO;
            [config setObject:[NSNumber numberWithBool:_isLockPackage1] forKey:IAP_KEY_PACKAGE1];
            break;
            
        case 2:
            _isLockPackage2 = NO;
            [config setObject:[NSNumber numberWithBool:_isLockPackage2] forKey:IAP_KEY_PACKAGE2];
            break;
            
        case 3:
            _isLockPackage3 = NO;
            [config setObject:[NSNumber numberWithBool:_isLockPackage3] forKey:IAP_KEY_PACKAGE3];
            break;
            
        default:
            break;
    }
    
    [config synchronize];
}

#pragma mark - Config Manager -
-(BOOL) readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.boolValue;
    }
    
    return defaults;
}

-(float) readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.floatValue;
    }
    
    return defaults;
}

-(int) readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.intValue;
    }
    
    return defaults;
}

-(double) readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.doubleValue;
    }
    
    return defaults;
}

-(NSString *) readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str;
    }
    
    return defaults;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (NSString *)convertDateToString:(NSDate *)aDate format:(NSString *)format
{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    if (!format)
        [formatter setDateFormat:@"MMM dd, yyyy"];
    else
        [formatter setDateFormat:format];
    
    return [formatter stringFromDate:aDate];
}

// pseudo function
- (NSString *)stringFromColor:(UIColor *)color
{
    const size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X",
            (int)(255 * components[MIN(0,totalComponents-2)]),
            (int)(255 * components[MIN(1,totalComponents-2)]),
            (int)(255 * components[MIN(2,totalComponents-2)])];
}

@end
