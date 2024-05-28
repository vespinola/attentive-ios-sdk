//
//  SDK.h
//  test
//
//  Created by Ivan Loughman-Pawelko on 7/19/22.
//
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ATTNConstants.h"


@class ATTNUserIdentity;


NS_ASSUME_NONNULL_BEGIN

@interface ATTNSDK : NSObject <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property (readonly) NSString* domain;

- (id)init NS_UNAVAILABLE;

- (id)initWithDomain:(NSString *)domain;

- (id)initWithDomain:(NSString *)domain mode:(NSString *)mode;

- (void)identify:(NSDictionary *)userIdentifiers;

- (void)trigger:(UIView *)theView;

- (void)trigger:(UIView *)theView handler:(_Nullable ATTNCreativeTriggerCompletionHandler)handler;

- (void)closeCreative;

- (void)clearUser;

NS_ASSUME_NONNULL_END

@end
