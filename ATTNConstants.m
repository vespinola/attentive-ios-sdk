//
//  ATTNConstants.m
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-28.
//

#import "ATTNConstants.h"

// Status passed to ATTNCreativeTriggerCompletionHandler when the creative is opened sucessfully
NSString *const CREATIVE_TRIGGER_STATUS_OPENED = @"CREATIVE_TRIGGER_STATUS_OPENED";
// Status passed to ATTNCreativeTriggerCompletionHandler when the creative is closed sucessfully
NSString *const CREATIVE_TRIGGER_STATUS_CLOSED = @"CREATIVE_TRIGGER_STATUS_CLOSED";
// Status passed to the ATTNCreativeTriggerCompletionHandler when the Creative has been triggered but it is not
// opened successfully. This can happen if there is no available mobile app creative, if the creative
// is fatigued, if the creative call has been timed out, or if an unknown exception occurs.
NSString *const CREATIVE_TRIGGER_STATUS_NOT_OPENED = @"CREATIVE_TRIGGER_STATUS_NOT_OPENED";
// Status passed to the ATTNCreativeTriggerCompletionHandler when the Creative is not closed due to an unknown
// exception
NSString *const CREATIVE_TRIGGER_STATUS_NOT_CLOSED = @"CREATIVE_TRIGGER_STATUS_NOT_CLOSED";
