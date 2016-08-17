//
//  MKStoreManager.m
//
//

#import "MKStoreManager.h"
//#import "Constants.h"

@implementation MKStoreManager

@synthesize uiDelegate;
@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;

static NSString *iap_package1 = @"com.OldToysStudio.FearEffect.package1";
static NSString *iap_package2 = @"com.OldToysStudio.FearEffect.package2";
static NSString *iap_package3 = @"com.OldToysStudio.FearEffect.package3";

static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
    [super dealloc];

//	[_sharedStoreManager release];
    
	self.purchasableObjects = nil;
    self.storeObserver = nil;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
        }
    }
    
    return _sharedStoreManager;
}
#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}

-(id) init
{
	if ((self = [super init])) {
        _sharedStoreManager.purchasableObjects = [NSMutableArray array];
        [_sharedStoreManager requestProductData];
        
        _sharedStoreManager.storeObserver = [[[MKStoreObserver alloc] init] autorelease];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (oneway void)release
{
    //do nothing
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (id)autorelease
{
    return self;
}

- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects:iap_package1, iap_package2, iap_package3, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[_purchasableObjects addObjectsFromArray:response.products];
    
	// populate your UI Controls here
	for(int i=0;i<[_purchasableObjects count];i++)
	{
		SKProduct *product = [_purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);  
	}
	
	[request autorelease];
}

- (void)buyFeature:(NSString*)featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void)buyPackage:(int)index
{
    switch (index) {
        case 1:
            [self buyFeature:iap_package1];
            break;
            
        case 2:
            [self buyFeature:iap_package2];
            break;
            
        case 3:
            [self buyFeature:iap_package3];
            break;
            
        default:
            break;
    }
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	NSLog(@"Failed - Manager");
}

- (void)provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:iap_package1]) {
        NSLog(@"success purcharsed : package 1");
        [_globalData setPurchasedPackage:1];
        [uiDelegate reconfigureUI];
        
    } else if ( [productIdentifier isEqualToString:iap_package2] ) {
        NSLog(@"success purcharsed : package 2");
        [_globalData setPurchasedPackage:2];
        [uiDelegate reconfigureUI];
        
    }  else if ( [productIdentifier isEqualToString:iap_package3] ) {
        NSLog(@"success purcharsed : package 3");
        [_globalData setPurchasedPackage:3];
        [uiDelegate reconfigureUI];
    }
}

- (void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
