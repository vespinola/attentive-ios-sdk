//
//  ATTNConstants.h
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Status passed to `ATTNCreativeTriggerCompletionHandler` when the creative is opened successfully
extern NSString *const CREATIVE_TRIGGER_STATUS_OPENED __attribute__((deprecated("Please use ATTNCreativeTriggerStatus.opened instead.")));
/// Status passed to `ATTNCreativeTriggerCompletionHandler` when the creative is closed sucessfully
extern NSString *const CREATIVE_TRIGGER_STATUS_CLOSED __attribute__((deprecated("Please use ATTNCreativeTriggerStatus.closed instead.")));
/** Status passed to the`ATTNCreativeTriggerCompletionHandler` when the Creative has been triggered but it is not
 opened successfully. This can happen if there is no available mobile app creative, if the creative
 is fatigued, if the creative call has been timed out, or if an unknown exception occurs.
 */
extern NSString *const CREATIVE_TRIGGER_STATUS_NOT_OPENED __attribute__((deprecated("Please use ATTNCreativeTriggerStatus.notOpened instead.")));
/// Status passed to the `ATTNCreativeTriggerCompletionHandler` when the Creative is not closed due to an unknown exception
extern NSString *const CREATIVE_TRIGGER_STATUS_NOT_CLOSED __attribute__((deprecated("Please use ATTNCreativeTriggerStatus.notClosed instead.")));


/// Your unique identifier for the user - this should be consistent across the user's lifetime, for example a database id
extern NSString *const IDENTIFIER_TYPE_CLIENT_USER_ID __attribute__((deprecated("Please use ATTNIdentifierType.clientUserId instead.")));
/// The user's phone number in E.164 format
extern NSString *const IDENTIFIER_TYPE_PHONE __attribute__((deprecated("Please use ATTNIdentifierType.phone instead.")));
/// The user's email
extern NSString *const IDENTIFIER_TYPE_EMAIL __attribute__((deprecated("Please use ATTNIdentifierType.email instead.")));
/// The user's Shopify Customer ID
extern NSString *const IDENTIFIER_TYPE_SHOPIFY_ID __attribute__((deprecated("Please use ATTNIdentifierType.shopifyId instead.")));
/// The user's Klaviyo ID
extern NSString *const IDENTIFIER_TYPE_KLAVIYO_ID __attribute__((deprecated("Please use ATTNIdentifierType.klaviyoId instead.")));
/// Key-value pairs of custom identifier names and values (both Strings) to associate with this user
extern NSString *const IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS __attribute__((deprecated("Please use ATTNIdentifierType.customIdentifiers instead.")));

NS_ASSUME_NONNULL_END
