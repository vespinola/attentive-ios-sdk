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
WKWebView *webView;
NSString * domain;
NSString * mode;


- (id)initWithDomain:(NSString *)domain {
    domain = domain;
    return [super init];
}

- (id)initWithDomain:(NSString *)domain mode:(NSString *)mode {
    domain = domain;
    mode = mode;
    return [super init];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId {
    parentView = theView;
    NSLog(@"Called showWebView in creativeSDK with domain: %@", domain);
    NSString* creativePageUrl;
    if ([mode isEqual:@"debug"]) {
        creativePageUrl = [NSString stringWithFormat:@"https://creatives.attn.tv/mobile-gaming/index.html?domain=%@&app_user_id=%@&debug=matter-trip-grass-symbol", domain, appUserId];
    } else {
        creativePageUrl = [NSString stringWithFormat:@"https://creatives.attn.tv/mobile-gaming/index.html?domain=%@&app_user_id=%@", domain, appUserId];
    }

    NSLog(@"Requesting creative page url: %@", creativePageUrl);
    
    NSURL *url = [NSURL URLWithString:creativePageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    WKWebViewConfiguration *wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    [[wkWebViewConfiguration userContentController] addScriptMessageHandler:self name:@"log"];
    
    NSString *userScriptWithEventListener = @"window.addEventListener('message', (event) => {if (event.data && event.data.__attentive && event.data.__attentive.action === 'CLOSE') {window.webkit.messageHandlers.log.postMessage(event.data.__attentive.action);}}, false);";
    
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:userScriptWithEventListener injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:FALSE];
    [[wkWebViewConfiguration userContentController] addUserScript:wkUserScript];
    
    webView = [[WKWebView alloc] initWithFrame:theView.frame configuration:wkWebViewConfiguration];
    webView.navigationDelegate = self;
    [webView loadRequest:request ];
    
    if ([mode isEqual:@"debug"]) {
        [parentView addSubview:webView];
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
        if ([id isEqual:@"attentive_creative"] && ![mode isEqual:@"debug"]) {
            [parentView addSubview:webView];
        }
    }];
}


- (void)userContentController:(WKUserContentController *)userContentController
    didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.body isEqual:@"CLOSE"]) {
        [webView removeFromSuperview];
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

