//
//  ATTNPurchaseEvent.m
//  attentive-ios-sdk
//
//  Created by Wyatt Davis on 12/7/22.
//

#import "ATTNEvent.h"
#import "ATTNPurchaseEvent.h"
#if __has_include(<attentive_ios_sdk_framework/ATTNSDK.h>)
#import "attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h"
#else
// Load the headers from the attentive-ios-sdk Pod
#import "attentive_ios_sdk/attentive_ios_sdk-Swift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation ATTNPurchaseEvent

- (instancetype)initWithItems:(NSArray<ATTNItem *> *)items order:(ATTNOrder *)order {
  if (self = [super init]) {
    self->_items = items;
    self->_order = order;
    
    
    ATTCart * cart = [[ATTCart alloc] initWithCartId:@"test" andCartCoupon:@"test"];
    cart.cartCoupon = @"coupon";
  }

  return self;
}

@end

NS_ASSUME_NONNULL_END
