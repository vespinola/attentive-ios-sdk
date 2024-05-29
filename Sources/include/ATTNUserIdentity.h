//
//  ATTNUserIdentifiers.h
//  Example
//
//  Created by Wyatt Davis on 11/9/22.
//

#import <Foundation/Foundation.h>

@class ATTNVisitorService;


NS_ASSUME_NONNULL_BEGIN

@interface ATTNUserIdentity : NSObject

@property NSDictionary * identifiers;

@property NSString * visitorId;


- (id)init;

- (id)initWithIdentifiers:(NSDictionary *) identifiers;

- (void)mergeIdentifiers:(NSDictionary *) newIdentifiers;

- (void)clearUser;

@end


NS_ASSUME_NONNULL_END
