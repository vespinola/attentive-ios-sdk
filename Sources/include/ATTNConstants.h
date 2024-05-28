//
//  ATTNConstants.h
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CREATIVE_TRIGGER_STATUS_OPENED;
extern NSString * const CREATIVE_TRIGGER_STATUS_CLOSED;
extern NSString * const CREATIVE_TRIGGER_STATUS_NOT_OPENED;
extern NSString * const CREATIVE_TRIGGER_STATUS_NOT_CLOSED;

extern NSString * const SDK_VERSION;

typedef void (^ATTNCreativeTriggerCompletionHandler)(NSString * triggerStatus);

NS_ASSUME_NONNULL_END
