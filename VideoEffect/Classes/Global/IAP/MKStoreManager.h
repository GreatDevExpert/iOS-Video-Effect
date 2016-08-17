//
//  StoreManager.h
//  MKSync
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@protocol MKStoreManagerDelegate <NSObject>

- (void)reconfigureUI;

@end

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {
}

@property (nonatomic, assign) id <MKStoreManagerDelegate> uiDelegate;
@property (nonatomic, strong) NSMutableArray *purchasableObjects;
@property (nonatomic, strong) MKStoreObserver *storeObserver;

- (void)requestProductData;

- (void)buyPackage:(int)index;

// do not call this directly. This is like a private method
- (void)buyFeature:(NSString*) featureId;
- (void)restorePurchase;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

@end
