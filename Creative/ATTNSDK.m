//
//  CreativeSDK.m
//  test
//
//  Created by Ivan Loughman-Pawelko on 7/19/22.
//

#import <WebKit/WebKit.h>
#import "ATTNSDK.h"

@implementation ATTNSDK

UIView *parentView;

- (id)initWithDomain:(NSString *)domain {
    self.domain = domain;
    return [super init];
}

- (id)initWithDomainAndMode:(NSString *)domain mode:(NSString *)mode {
    self.domain = domain;
    self.mode = mode;
    return [super init];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId {
    parentView = theView;
    NSLog(@"Called showWebView in creativeSDK with domain: %@", self.domain);
    NSString* creativePageUrl;
    if ([self.mode isEqual:@"debug"]) {
        creativePageUrl = [NSString stringWithFormat:@"https://creatives.attn.tv/mobile-gaming/index.html?domain=%@&app_user_id=%@&debug=matter-trip-grass-symbol", self.domain, appUserId];
    } else {
        creativePageUrl = [NSString stringWithFormat:@"https://creatives.attn.tv/mobile-gaming/index.html?domain=%@&app_user_id=%@", self.domain, appUserId];
    }

    NSLog(@"Requesting creative page url: %@", creativePageUrl);
    
    NSURL *url = [NSURL URLWithString:creativePageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    WKWebViewConfiguration *wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    [[wkWebViewConfiguration userContentController] addScriptMessageHandler:self name:@"log"];
    
    NSString *userScriptWithEventListener = @"window.addEventListener('message', (event) => {if (event.data && event.data.__attentive && event.data.__attentive.action === 'CLOSE') {window.webkit.messageHandlers.log.postMessage(event.data.__attentive.action);}}, false);";
    
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:userScriptWithEventListener injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:FALSE];
    [[wkWebViewConfiguration userContentController] addUserScript:wkUserScript];
    
    _webView = [[WKWebView alloc] initWithFrame:theView.frame configuration:wkWebViewConfiguration];
    _webView.navigationDelegate = self;
    [_webView loadRequest:request ];
    
    if ([self.mode isEqual:@"debug"]) {
        [parentView addSubview:_webView];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    NSString *asyncJs = @"var p = new Promise(resolve => { "
        "setTimeout(() => { "
            "resolve(document.querySelector('iframe').id); "
        "}, 1000); "
    "}); "
    "var iframe = await p; "
    "return iframe;";

    [webView callAsyncJavaScript:asyncJs arguments:nil inFrame:nil inContentWorld:WKContentWorld.defaultClientWorld completionHandler:^(NSString *id, NSError *error) {
        if ([id isEqual:@"attentive_creative"] && ![self.mode isEqual:@"debug"]) {
            [parentView addSubview:webView];
        }
    }];
}


- (void)userContentController:(WKUserContentController *)userContentController
    didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body isEqual:@"CLOSE"]) {
        [_webView removeFromSuperview];
    }
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([navigationAction.request.URL.scheme isEqual:@"sms"]) {
        [UIApplication.sharedApplication openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


@end

