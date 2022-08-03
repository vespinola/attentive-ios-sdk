//
//  CreativeSDK.m
//  test
//
//  Created by Ivan Loughman-Pawelko on 7/19/22.
//

#import <WebKit/WebKit.h>
#import "SDK.h"

@implementation SDK

- (id)initWithDomain:(NSString *)domain {
    self.domain = domain;
    return [super init];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId {
    [self trigger:theView appUserId:appUserId xOffset:0 yOffset:0 debug:@""];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId debug:(NSString *)debug {
    [self trigger:theView appUserId:appUserId xOffset:0 yOffset:0 debug:debug];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId xOffset:(int)xOffset yOffset:(int)yOffset {
    [self trigger:theView appUserId:appUserId xOffset:xOffset yOffset:yOffset debug:@""];
}

- (void)trigger:(UIView *)theView appUserId:(NSString *)appUserId xOffset:(int)xOffset yOffset:(int)yOffset debug:(NSString *)debug {
    self.parentView = theView;
    NSLog(@"Called showWebView in creativeSDK with domain: %@", self.domain);
    self.creativePageUrl = [NSString stringWithFormat:@"https://creatives.attn.tv/mobile-gaming/index.html?domain=%@&app_user_id=%@&debug=%@", self.domain, appUserId, debug];

    NSURL *url = [NSURL URLWithString:self.creativePageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    WKWebViewConfiguration *wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    [[wkWebViewConfiguration userContentController] addScriptMessageHandler:self name:@"log"];
    
    NSString *userScriptWithEventListener = @"window.addEventListener('message', (event) => {if (event.data && event.data.__attentive && event.data.__attentive.action === 'CLOSE') {window.webkit.messageHandlers.log.postMessage(event.data.__attentive.action);}}, false);";
    
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:userScriptWithEventListener injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:FALSE];
    [[wkWebViewConfiguration userContentController] addUserScript:wkUserScript];
    
    CGRect frame = CGRectMake((xOffset)/2, (yOffset)/2, theView.frame.size.width - xOffset, theView.frame.size.height - yOffset);
    _webView = [[WKWebView alloc] initWithFrame:frame configuration:wkWebViewConfiguration];
    _webView.navigationDelegate = self;
    [_webView loadRequest:request ];
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
        if ([id isEqual:@"attentive_creative"]) {
            [self.parentView addSubview:webView];
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

