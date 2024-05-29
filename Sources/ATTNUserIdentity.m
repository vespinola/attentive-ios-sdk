//
//  ATTNUserIdentifiers.h
//  Example
//
//  Created by Wyatt Davis on 11/9/22.
//

#import <Foundation/Foundation.h>

#import "ATTNParameterValidation.h"
#import "ATTNUserIdentity.h"
#import "ATTNVisitorService.h"
#import "ATTNConstants.h"

@implementation ATTNUserIdentity {
  ATTNVisitorService *_visitorService;
}

- (id)init {
  return [self initWithIdentifiers:@{}];
}

- (id)initWithIdentifiers:(nonnull NSDictionary *)identifiers {
  if (self = [super init]) {
    [self validateIdentifiers:identifiers];
    _identifiers = identifiers;
    _visitorService = [[ATTNVisitorService alloc] init];
    _visitorId = [_visitorService getVisitorId];
  }
  return self;
}

- (void)mergeIdentifiers:(nonnull NSDictionary *)newIdentifiers {
  [self validateIdentifiers:newIdentifiers];

  NSMutableDictionary *currentIdentifiersCopy = [_identifiers mutableCopy];
  [currentIdentifiersCopy addEntriesFromDictionary:newIdentifiers];
  _identifiers = currentIdentifiersCopy;
}

- (void)validateIdentifiers:(nonnull NSDictionary *)identifiers {
  NSArray *keys = @[ IDENTIFIER_TYPE_CLIENT_USER_ID,
                     IDENTIFIER_TYPE_PHONE,
                     IDENTIFIER_TYPE_EMAIL,
                     IDENTIFIER_TYPE_SHOPIFY_ID,
                     IDENTIFIER_TYPE_KLAVIYO_ID ];
  for (id key in keys) {
    [ATTNParameterValidation verifyStringOrNil:identifiers[key] inputName:key];
  }
  [ATTNParameterValidation verify1DStringDictionaryOrNil:identifiers[IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS] inputName:IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS];
}

- (void)clearUser {
  _identifiers = @{};
  _visitorId = [_visitorService createNewVisitorId];
}


@end
