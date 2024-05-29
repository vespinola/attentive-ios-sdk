//
//  ATTNConstants.h
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: ATTNSDK

extern NSString * const CREATIVE_TRIGGER_STATUS_OPENED;
extern NSString * const CREATIVE_TRIGGER_STATUS_CLOSED;
extern NSString * const CREATIVE_TRIGGER_STATUS_NOT_OPENED;
extern NSString * const CREATIVE_TRIGGER_STATUS_NOT_CLOSED;

typedef void (^ATTNCreativeTriggerCompletionHandler)(NSString * triggerStatus);

// MARK: ATTNUserIdentify
extern NSString * const IDENTIFIER_TYPE_CLIENT_USER_ID;
extern NSString * const IDENTIFIER_TYPE_PHONE;
extern NSString * const IDENTIFIER_TYPE_EMAIL;
extern NSString * const IDENTIFIER_TYPE_SHOPIFY_ID;
extern NSString * const IDENTIFIER_TYPE_KLAVIYO_ID;
extern NSString * const IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS;

NS_ASSUME_NONNULL_END
