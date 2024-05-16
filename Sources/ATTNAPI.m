//
//  ATTNAPI.m
//  attentive-ios-sdk
//
//  Created by Wyatt Davis on 11/28/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ATTNParameterValidation.h"
#import "ATTNUserIdentity.h"
#import "ATTNAPI.h"
#import "ATTNEvent.h"
#import "ATTNItem.h"
#import "ATTNPrice.h"
#import "ATTNOrder.h"
#import "ATTNCart.h"
#import "ATTNPurchaseEvent.h"
#import "ATTNAddToCartEvent.h"
#import "ATTNProductViewEvent.h"
#import "ATTNCustomEvent.h"
#import "Internal/ATTNUserAgentBuilder.h"
#import "Internal/ATTNInfoEvent.h"
#import <attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h>
//#import "attentive_ios_sdk_framework/attentive_ios_sdk_framework-Swift.h"

// A single event can create multiple requests. The EventRequest class represents a single request.
@interface EventRequest : NSObject

@property (readonly) NSMutableDictionary* metadata;
@property (readonly) NSString* eventNameAbbreviation;

- (instancetype)initWithMetadata:(NSMutableDictionary*)metadata eventNameAbbreviation:(NSString*)abbreviation;

@end

@implementation EventRequest

- (instancetype)initWithMetadata:(NSMutableDictionary*)metadata eventNameAbbreviation:(NSString*)abbreviation {
  if (self = [super init]) {
    self->_metadata = metadata;
    self->_eventNameAbbreviation = abbreviation;
  }

  return self;
}

@end

@interface NSMutableDictionary (Custom)

- (void)addEntryIfNotNil:(NSString*)key value:(NSObject* _Nullable)value;

@end

@implementation NSMutableDictionary (Custom)

- (void)addEntryIfNotNil:(NSString*)key value:(NSObject* _Nullable)value {
  if (value != nil) {
    self[key] = value;
  }
}

@end

static NSString* const DTAG_URL_FORMAT = @"https://cdn.attn.tv/%@/dtag.js";
static NSString* const EXTERNAL_VENDOR_TYPE_SHOPIFY = @"0";
static NSString* const EXTERNAL_VENDOR_TYPE_KLAVIYO = @"1";
static NSString* const EXTERNAL_VENDOR_TYPE_CLIENT_USER = @"2";
static NSString* const EXTERNAL_VENDOR_TYPE_CUSTOM_USER = @"6";

static NSString* const EVENT_TYPE_PURCHASE = @"p";
static NSString* const EVENT_TYPE_ADD_TO_CART = @"c";
static NSString* const EVENT_TYPE_PRODUCT_VIEW = @"d";
static NSString* const EVENT_TYPE_ORDER_CONFIRMED = @"oc";
static NSString* const EVENT_TYPE_USER_IDENTIFIER_COLLECTED = @"idn";
static NSString* const EVENT_TYPE_INFO = @"i";
static NSString* const EVENT_TYPE_CUSTOM_EVENT = @"ce";

@implementation ATTNAPI {
  NSURLSession* _Nonnull _urlSession;
  NSNumberFormatter* _Nonnull _priceFormatter;
  NSString* _Nonnull _domain;
  NSString* _Nullable _cachedGeoAdjustedDomain;
}

- (instancetype)initWithDomain:(NSString*)domain {
  return [self initWithDomain:domain urlSession:[self buildUrlSession]];
}

- (NSURLSession*)buildUrlSession {
  NSURLSessionConfiguration* configWithUserAgent = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSDictionary* additionalHeadersWithUserAgent = @{@"User-Agent" : [ATTNUserAgentBuilder buildUserAgent]};
  [configWithUserAgent setHTTPAdditionalHeaders:additionalHeadersWithUserAgent];

  return [NSURLSession sessionWithConfiguration:configWithUserAgent];
}

// Private constructor that makes testing easier
- (instancetype)initWithDomain:domain urlSession:(NSURLSession*)urlSession {
  if (self = [super init]) {
    _urlSession = urlSession;
    _domain = domain;
    _priceFormatter = [NSNumberFormatter new];
    [_priceFormatter setMinimumFractionDigits:2];
    _cachedGeoAdjustedDomain = nil;
  }

  return [super init];
}

// TODO: When we add the other events, the USER_IDENTIFIER_COLLECTED event code will be wrapped into the generic event code
- (void)sendUserIdentity:(ATTNUserIdentity*)userIdentity {
  [self sendUserIdentity:userIdentity callback:nil];
}

- (void)sendUserIdentity:(ATTNUserIdentity*)userIdentity callback:(ATTNAPICallback)callback {
  // TODO we should add retries for transient errors
  [self getGeoAdjustedDomain:_domain
           completionHandler:^(NSString* geoAdjustedDomain, NSError* error) {
             if (error) {
               NSLog(@"Error sending user identity: '%@'", error);
               return;
             }

             [self sendUserIdentityInternal:userIdentity domain:geoAdjustedDomain callback:callback];
           }];
}

- (void)sendEvent:(id<ATTNEvent>)event userIdentity:(ATTNUserIdentity*)userIdentity {
  [self sendEvent:event userIdentity:userIdentity callback:nil];
}

- (void)sendEvent:(id<ATTNEvent>)event userIdentity:(ATTNUserIdentity*)userIdentity callback:(ATTNAPICallback)callback {
  [self getGeoAdjustedDomain:_domain
           completionHandler:^(NSString* geoAdjustedDomain, NSError* error) {
             if (error) {
               NSLog(@"Error sending event: '%@'.", error);
             }

             [self sendEventInternal:event userIdentity:userIdentity domain:geoAdjustedDomain callback:callback];
           }];
}

- (void)sendEventInternal:(id<ATTNEvent>)event userIdentity:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain callback:(ATTNAPICallback)callback {
  // slice up the Event into individual EventRequests
  NSArray<EventRequest*>* requests = [self convertEventToRequests:event];

  for (EventRequest* request in requests) {
    [self sendEventInternalForRequest:request userIdentity:userIdentity domain:domain callback:callback];
  }
}

- (void)sendEventInternalForRequest:(EventRequest*)request userIdentity:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain callback:(ATTNAPICallback)callback {
  NSURL* url = [self constructEventUrlComponentsForEventRequest:request userIdentity:userIdentity domain:domain].URL;
  NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  NSURLSessionDataTask* task = [_urlSession dataTaskWithRequest:urlRequest
                                              completionHandler:^void(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
                                                NSString* message;
                                                if (error) {
                                                  message = [NSString stringWithFormat:@"Error sending for event '%@'. Error: '%@'", request.eventNameAbbreviation, [error description]];
                                                } else {
                                                  // The response is an HTTP response because the URL had an HTTPS scheme
                                                  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                  if ([httpResponse statusCode] > 400) {
                                                    message = [NSString stringWithFormat:@"Error sending the event. Incorrect status code: '%ld'", (long)[httpResponse statusCode]];
                                                  } else {
                                                    message = [NSString stringWithFormat:@"Successfully sent event of type '%@'", request.eventNameAbbreviation];
                                                  }
                                                }

                                                NSLog(@"%@", message);
                                                if (callback != nil) {
                                                  callback(data, url, response, error);
                                                }
                                              }];

  [task resume];
}

// A single event can create multiple requests to our servers. This method converts an event to multiple request objects.
- (NSArray<EventRequest*>*)convertEventToRequests:(id<ATTNEvent>)event {
  NSMutableArray<EventRequest*>* eventRequests = [[NSMutableArray alloc] init];

  if ([event isKindOfClass:[ATTNPurchaseEvent class]]) {
    ATTNPurchaseEvent* purchase = (ATTNPurchaseEvent*)event;

    if ([purchase.items count] == 0) {
      NSLog(@"No items found in the purchase event.");
      return @[];
    }

    // Create EventRequests for each of the items in the PurchaseEvent
    NSDecimalNumber* cartTotal = [NSDecimalNumber zero];
    for (ATTNItem* item in purchase.items) {
      NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
      [self addProductDataToDictionary:item dictionary:metadata];

      metadata[@"orderId"] = purchase.order.orderId;

      if (purchase.cart != nil) {
        [metadata addEntryIfNotNil:@"cartId" value:purchase.cart.cartId];
        [metadata addEntryIfNotNil:@"cartCoupon" value:purchase.cart.cartCoupon];
      }

      [eventRequests addObject:[[EventRequest alloc] initWithMetadata:metadata eventNameAbbreviation:EVENT_TYPE_PURCHASE]];

      cartTotal = [cartTotal decimalNumberByAdding:item.price.price];
    }

    // Add cart total to each Purchase metadata
    NSString* cartTotalString = [_priceFormatter stringFromNumber:cartTotal];
    for (EventRequest* eventRequest in eventRequests) {
      eventRequest.metadata[@"cartTotal"] = cartTotalString;
    }

    // create another EventRequest for an OrderConfirmed
    NSMutableDictionary* orderConfirmedMetadata = [[NSMutableDictionary alloc] init];
    orderConfirmedMetadata[@"orderId"] = purchase.order.orderId;
    orderConfirmedMetadata[@"cartTotal"] = cartTotalString;
    orderConfirmedMetadata[@"currency"] = purchase.items[0].price.currency;

    NSMutableArray<NSMutableDictionary*>* products = [[NSMutableArray alloc] init];
    for (ATTNItem* item in purchase.items) {
      NSMutableDictionary* product = [[NSMutableDictionary alloc] init];
      [self addProductDataToDictionary:item dictionary:product];
      [products addObject:product];
    }
    orderConfirmedMetadata[@"products"] = [self convertObjectToJson:products defaultValue:@"[]"];
    [eventRequests addObject:[[EventRequest alloc] initWithMetadata:orderConfirmedMetadata eventNameAbbreviation:EVENT_TYPE_ORDER_CONFIRMED]];

    return eventRequests;
  } else if ([event isKindOfClass:[ATTNAddToCartEvent class]]) {
    ATTNAddToCartEvent* addToCart = (ATTNAddToCartEvent*)event;

    if ([addToCart.items count] == 0) {
      NSLog(@"No items found in the AddToCart event.");
      return @[];
    }

    for (ATTNItem* item in addToCart.items) {
      NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
      [self addProductDataToDictionary:item dictionary:metadata];

      [eventRequests addObject:[[EventRequest alloc] initWithMetadata:metadata eventNameAbbreviation:EVENT_TYPE_ADD_TO_CART]];
    }

    return eventRequests;
  } else if ([event isKindOfClass:[ATTNProductViewEvent class]]) {
    ATTNProductViewEvent* productView = (ATTNProductViewEvent*)event;

    if ([productView.items count] == 0) {
      NSLog(@"No items found in the ProductView event.");
      return @[];
    }

    for (ATTNItem* item in productView.items) {
      NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
      [self addProductDataToDictionary:item dictionary:metadata];

      [eventRequests addObject:[[EventRequest alloc] initWithMetadata:metadata eventNameAbbreviation:EVENT_TYPE_PRODUCT_VIEW]];
    }

    return eventRequests;
  } else if ([event isKindOfClass:[ATTNInfoEvent class]]) {
    [eventRequests addObject:[[EventRequest alloc] initWithMetadata:[[NSMutableDictionary alloc] init] eventNameAbbreviation:EVENT_TYPE_INFO]];
    return eventRequests;
  } else if ([event isKindOfClass:[SATTNCustomEvent class]]) {
    SATTNCustomEvent* customEvent = (SATTNCustomEvent*)event;

    NSMutableDictionary* customEventMetadata = [[NSMutableDictionary alloc] init];
    customEventMetadata[@"type"] = customEvent.type;
    customEventMetadata[@"properties"] = [self convertObjectToJson:customEvent.properties defaultValue:@"{}"];

    [eventRequests addObject:[[EventRequest alloc] initWithMetadata:customEventMetadata eventNameAbbreviation:EVENT_TYPE_CUSTOM_EVENT]];
    return eventRequests;
  } else {
    NSLog(@"ERROR: Unknown event type: %@", [event class]);
    return @[];
  }
}

- (void)addProductDataToDictionary:(ATTNItem*)item dictionary:(NSMutableDictionary*)dictionary {
  dictionary[@"productId"] = item.productId;
  dictionary[@"subProductId"] = item.productVariantId;
  dictionary[@"price"] = [_priceFormatter stringFromNumber:item.price.price];
  dictionary[@"currency"] = item.price.currency;
  dictionary[@"quantity"] = [NSString stringWithFormat:@"%d", item.quantity];
  [dictionary addEntryIfNotNil:@"category" value:item.category];
  [dictionary addEntryIfNotNil:@"image" value:item.productImage];
  [dictionary addEntryIfNotNil:@"name" value:item.name];
}

- (void)getGeoAdjustedDomain:(NSString*)domain completionHandler:(void (^)(NSString* _Nullable, NSError* _Nullable))completionHandler {
  if (_cachedGeoAdjustedDomain != nil) {
    completionHandler(_cachedGeoAdjustedDomain, nil);
    return;
  }

  NSLog(@"%@", [NSString stringWithFormat:@"Getting the geoAdjustedDomain for domain '%@'...", domain]);

  NSString* urlString = [NSString stringWithFormat:DTAG_URL_FORMAT, domain];

  NSURL* url = [NSURL URLWithString:urlString];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  NSURLSessionDataTask* task = [_urlSession dataTaskWithRequest:request
                                              completionHandler:^void(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
                                                if (error) {
                                                  NSLog(@"Error getting the geo-adjusted domain. Error: '%@'", [error description]);
                                                  completionHandler(nil, error);
                                                  return;
                                                }

                                                // The response is an HTTP response because the URL had an HTTPS scheme
                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                // The body/data only contains the tag data if the endpoint returns a 200
                                                if ([httpResponse statusCode] != 200) {
                                                  NSLog(@"Error getting the geo-adjusted domain. Incorrect status code: '%ld'", (long)[httpResponse statusCode]);
                                                  completionHandler(nil, [NSError errorWithDomain:@"com.attentive.API" code:NSURLErrorBadServerResponse userInfo:nil]);
                                                  return;
                                                }

                                                NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                                NSString* geoAdjustedDomain = [ATTNAPI extractDomainFromTag:dataString];

                                                if (!geoAdjustedDomain) {
                                                  NSError* error = [NSError errorWithDomain:@"com.attentive.API" code:NSURLErrorBadServerResponse userInfo:nil];
                                                  completionHandler(nil, error);
                                                  return;
                                                }

                                                self->_cachedGeoAdjustedDomain = geoAdjustedDomain;
                                                completionHandler(geoAdjustedDomain, nil);
                                              }];

  [task resume];
}

- (void)sendUserIdentityInternal:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain callback:(ATTNAPICallback)callback {
  NSURL* url = [self constructUserIdentityUrl:userIdentity domain:domain].URL;
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  NSURLSessionDataTask* task = [_urlSession dataTaskWithRequest:request
                                              completionHandler:^void(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
                                                NSString* message;
                                                if (error) {
                                                  message = [NSString stringWithFormat:@"Error sending user identity. Error: '%@'", [error description]];
                                                } else {
                                                  // The response is an HTTP response because the URL had an HTTPS scheme
                                                  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                  if ([httpResponse statusCode] > 400) {
                                                    message = [NSString stringWithFormat:@"Error sending the event. Incorrect status code: '%ld'", (long)[httpResponse statusCode]];
                                                  } else {
                                                    message = @"Successfully sent user identity event";
                                                  }
                                                }

                                                NSLog(@"%@", message);
                                                if (callback != nil) {
                                                  callback(data, url, response, error);
                                                }
                                              }];

  [task resume];
}

- (NSURLComponents*)constructEventUrlComponentsForEventRequest:(EventRequest*)eventRequest userIdentity:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain {
  NSURLComponents* urlComponents = [[NSURLComponents alloc] initWithString:@"https://events.attentivemobile.com/e"];

  NSMutableDictionary* queryParams = [self constructBaseQueryParams:userIdentity domain:domain];
  NSMutableDictionary* combinedMetadata = [self buildBaseMetadata:userIdentity];
  [combinedMetadata addEntriesFromDictionary:eventRequest.metadata];
  queryParams[@"m"] = [self convertObjectToJson:combinedMetadata defaultValue:@"{}"];
  queryParams[@"t"] = eventRequest.eventNameAbbreviation;

  NSMutableArray* queryItems = [NSMutableArray array];
  for (NSString* key in queryParams) {
    [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryParams[key]]];
  }

  urlComponents.queryItems = queryItems;

  return urlComponents;
}

- (NSMutableDictionary*)constructBaseQueryParams:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain {
  NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
  queryParams[@"tag"] = @"modern";
  queryParams[@"v"] = @"mobile-app";
  queryParams[@"c"] = domain;
  queryParams[@"lt"] = @"0";
  queryParams[@"evs"] = [self buildExternalVendorIdsJson:userIdentity];
  queryParams[@"u"] = userIdentity.visitorId;
  return queryParams;
}

- (NSURLComponents*)constructUserIdentityUrl:(ATTNUserIdentity*)userIdentity domain:(NSString*)domain {
  NSURLComponents* urlComponents = [[NSURLComponents alloc] initWithString:@"https://events.attentivemobile.com/e"];

  NSMutableDictionary* queryParams = [self constructBaseQueryParams:userIdentity domain:domain];

  queryParams[@"m"] = [self buildMetadataJson:userIdentity];
  queryParams[@"t"] = EVENT_TYPE_USER_IDENTIFIER_COLLECTED;

  // create query "items" for each query param
  NSMutableArray* queryItems = [NSMutableArray array];
  for (NSString* key in queryParams) {
    [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryParams[key]]];
  }

  urlComponents.queryItems = queryItems;

  return urlComponents;
}

- (NSString*)buildExternalVendorIdsJson:(ATTNUserIdentity*)userIdentity {
  NSMutableArray* ids = [[NSMutableArray alloc] init];
  if (userIdentity.identifiers[IDENTIFIER_TYPE_CLIENT_USER_ID]) {
    [ids addObject:@{@"vendor" : EXTERNAL_VENDOR_TYPE_CLIENT_USER, @"id" : userIdentity.identifiers[IDENTIFIER_TYPE_CLIENT_USER_ID]}];
  }
  if (userIdentity.identifiers[IDENTIFIER_TYPE_KLAVIYO_ID]) {
    [ids addObject:@{@"vendor" : EXTERNAL_VENDOR_TYPE_KLAVIYO, @"id" : userIdentity.identifiers[IDENTIFIER_TYPE_KLAVIYO_ID]}];
  }
  if (userIdentity.identifiers[IDENTIFIER_TYPE_SHOPIFY_ID]) {
    [ids addObject:@{@"vendor" : EXTERNAL_VENDOR_TYPE_SHOPIFY, @"id" : userIdentity.identifiers[IDENTIFIER_TYPE_SHOPIFY_ID]}];
  }
  if (userIdentity.identifiers[IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS]) {
    NSDictionary* customIdentifiers = userIdentity.identifiers[IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS];
    for (id key in customIdentifiers) {
      [ids addObject:@{@"vendor" : EXTERNAL_VENDOR_TYPE_CUSTOM_USER, @"id" : customIdentifiers[key], @"name" : key}];
    }
  }

  NSError* error = nil;
  NSData* array = [NSJSONSerialization dataWithJSONObject:ids options:0 error:&error];

  if (error) {
    NSLog(@"Could not serialize the external vendor ids. Returning an empty array. Error: '%@'", [error description]);
    return @"[]";
  }

  return [[NSString alloc] initWithData:array encoding:NSUTF8StringEncoding];
}

- (NSString*)buildMetadataJson:(ATTNUserIdentity*)userIdentity {
  NSMutableDictionary* metadata = [self buildBaseMetadata:userIdentity];

  NSError* error = nil;
  NSData* json = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:&error];

  if (error) {
    NSLog(@"Could not serialize the external vendor ids. Returning an empty blob. Error: '%@'", [error description]);
    return @"{}";
  }

  return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

- (NSString*)convertObjectToJson:(id)object defaultValue:(NSString*)defaultValue {
  NSError* error = nil;
  NSData* json = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];

  if (error) {
    NSLog(@"Could not serialize the object to JSON. Error: '%@'", [error description]);
    return defaultValue;
  }

  return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary*)buildBaseMetadata:(ATTNUserIdentity*)userIdentity {
  NSMutableDictionary* metadata = [[NSMutableDictionary alloc] init];
  metadata[@"source"] = @"msdk";
  if (userIdentity.identifiers[IDENTIFIER_TYPE_PHONE]) {
    metadata[@"phone"] = userIdentity.identifiers[IDENTIFIER_TYPE_PHONE];
  }
  if (userIdentity.identifiers[IDENTIFIER_TYPE_EMAIL]) {
    metadata[@"email"] = userIdentity.identifiers[IDENTIFIER_TYPE_EMAIL];
  }
  return metadata;
}

+ (NSString* _Nullable)extractDomainFromTag:(NSString*)tag {
  NSError* error = nil;
  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"='([a-z0-9-]+)[.]attn[.]tv'" options:0 error:&error];

  if (error) {
    NSLog(@"Error building the domain regex. Error: '%@'", [error description]);
    return nil;
  }

  NSInteger matchesCount = [regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, [tag length])];
  if (matchesCount < 1) {
    NSLog(@"No Attentive domain found in the tag");
    return nil;
  } else if (matchesCount > 1) {
    NSLog(@"More than one match found for the Attentive domain regex. Continuing with the first one...");
  }

  NSTextCheckingResult* regexResult = [regex firstMatchInString:tag options:0 range:NSMakeRange(0, [tag length])];
  if (!regexResult) {
    NSLog(@"No Attentive domain regex match object returned.");
    return nil;
  }

  NSRange domainRange = [regexResult rangeAtIndex:1];
  if (NSEqualRanges(domainRange, NSMakeRange(NSNotFound, 0))) {
    NSLog(@"No match found for Attentive domain in the tag.");
    return nil;
  }

  NSString* regionalizedDomain = [tag substringWithRange:domainRange];

  NSLog(@"Identified regionalized attentive domain: %@", regionalizedDomain);

  return regionalizedDomain;
}

// For testing only
- (NSURLSession*)session {
  return _urlSession;
}

// For testing only
- (NSString* _Nullable)getCachedGeoAdjustedDomain {
  return _cachedGeoAdjustedDomain;
}

@end
