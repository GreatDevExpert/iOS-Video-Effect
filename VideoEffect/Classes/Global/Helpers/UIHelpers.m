
#import "UIHelpers.h"

@implementation UIHelpers

#pragma mark -
#pragma mark UIAlertView showing Methods

+ (void)showAlertWithTitle:(NSString *)title
                        msg:(NSString *)msg
                buttonTitle:(NSString *)btnTitle
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:msg
                                                delegate:nil
                                       cancelButtonTitle:btnTitle
                                       otherButtonTitles:nil];
    [av show];
    [av release];
}

+ (void)showAlertWithTitle:(NSString *)title
{
    [UIHelpers showAlertWithTitle:title
                              msg:nil
                      buttonTitle:NSLocalizedString(@"OK", @"ok")];
}

+ (void)showAlertWithTitle:(NSString *)title
                        msg:(NSString *)msg
{
    [UIHelpers showAlertWithTitle:title
                              msg:msg
                      buttonTitle:NSLocalizedString(@"OK", @"ok")];
}

@end
