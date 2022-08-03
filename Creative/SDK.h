//
//  SDK.h
//  test
//
//  Created by Ivan Loughman-Pawelko on 7/19/22.
//
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface SDK : UIViewController <WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@property(strong, nonatomic) UIView *parentView;
@property(strong,nonatomic) WKWebView *webView;
@property (strong, nonatomic) NSString *creativePageUrl;
@property (strong, nonatomic) NSString * domain;
@property (strong, nonatomic) NSString * domain;

- (id)initWithDomain:(NSString *)domain;

- (id)initWithDomainAndMode:(NSString *)domain mode:(NSString *)mode;

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId;

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId xOffset:(int)xOffset yOffset:(int)yOffset;

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end
