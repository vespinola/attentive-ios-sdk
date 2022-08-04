//
//  SDK.h
//  test
//
//  Created by Ivan Loughman-Pawelko on 7/19/22.
//
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface SDK : UIViewController <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property(strong,nonatomic) WKWebView *webView;
@property (strong, nonatomic) NSString * domain;
@property (strong, nonatomic) NSString * mode;

- (id)initWithDomain:(NSString *)domain;

- (id)initWithDomainAndMode:(NSString *)domain mode:(NSString *)mode;

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId;

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId xOffset:(int)xOffset yOffset:(int)yOffset;

@end
