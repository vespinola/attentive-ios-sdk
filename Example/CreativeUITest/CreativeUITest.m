//
//  CreativeUITest.m
//  CreativeUITest
//
//  Created by Olivia Kim on 2/14/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CreativeUITest-Swift.h"

@interface CreativeUITest : XCTestCase

@end


@implementation CreativeUITest {
  XCUIApplication *app;
}


- (void)setUp {
  [super setUp];
  // In UI tests it is usually best to stop immediately when a failure occurs.
  self.continueAfterFailure = NO;

  app = [[XCUIApplication alloc] init];
}

- (void)tearDown {
  // reset cookies & user defaults after all tests have run
  [self clearCookies];
  [self resetUserDefaults];

  [app terminate];
  [self deleteApp];

  [super tearDown];
}


- (void)testLoadCreative_clickClose_closesCreative {
  [self launchAppWithMode:@"production"];
  [app.buttons[@"Push me for Creative!"] tapOnElement];

  sleep(2);

  // Close the creative
  [app.webViews.buttons[@"Dismiss this popup"] tapOnElement];

  // Assert that the creative is closed
  XCTAssertTrue([app.buttons[@"Push me for Creative!"] elementExists]);
  XCTAssertEqual(app.buttons[@"Push me for Creative!"].isHittable, true);
}


- (void)testLoadCreative_fillOutFormAndSubmit_launchesSmsAppWithPrePopulatedText {
  [self launchAppWithMode:@"production"];
  [app.buttons[@"Push me to clear the User!"] tapOnElement];
  [app.buttons[@"Push me for Creative!"] tapOnElement];

  // Fill in the email
  XCUIElement *emailField = app.webViews.textFields[@"Email Address"];
  [emailField tapOnElement];
  [emailField fillTextField:@"testemail@attentivemobile.com"];

  // Tap something else on the creative to dismiss the keyboard
  [app.staticTexts[@"10% OFF"] tapOnElement];

  // Submit email
  [app.webViews.buttons[@"CONTINUE"] tapOnElement];

  [app.buttons[@"GET 10% OFF NOW when you sign up for email and texts"] tapOnElement];

  // Assert that the SMS app is opened with prepopulated text if running locally
  // (AWS Device Farm doesn't allow use of SMS apps)
  NSString *envHost = [[[NSProcessInfo processInfo] environment] objectForKey:@"COM_ATTENTIVE_EXAMPLE_HOST"];
  if ([envHost isEqualToString:@"local"]) {
    XCUIApplication *smsApp = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.MobileSMS"];

    // Close Info Screen when SMS App is opened for the first time
    if ([smsApp.buttons[@"OK"] elementExists]) {
      [smsApp.buttons[@"OK"] tapOnElement];
    }

    XCTAssertTrue([smsApp.textFields[@"Message"] elementExists]);
    XCTAssertTrue([smsApp.textFields[@"Message"].value containsString:@"Send this text to subscribe to recurring automated personalized marketing alerts (e.g. cart reminders) from Attentive Mobile Apps Test"]);

    [app activate];
    sleep(1);
  }
}


- (void)testLoadCreative_clickPrivacyLink_opensPrivacyPageInWebApp {
  [self launchAppWithMode:@"production"];
  [app.buttons[@"Push me for Creative!"] tapOnElement];

  // Click privacy link
  [app.links[@"Privacy"] tapOnElement];

  // AWS Device Farm doesn't always acknowledge separate apps, leading to flakiness here
  NSString *envHost = [[[NSProcessInfo processInfo] environment] objectForKey:@"COM_ATTENTIVE_EXAMPLE_HOST"];
  if ([envHost isEqualToString:@"local"]) {
    // Verify that the privacy page is visible in the external browser
    XCUIApplication *safariApp = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.mobilesafari"];
    BOOL privacyPolicyExists = [safariApp.staticTexts[@"Privacy Policy"] elementExists];
    BOOL messagingPrivacyPolicyExists = [safariApp.staticTexts[@"Messaging Privacy Policy"] elementExists];

    XCTAssertTrue(privacyPolicyExists || messagingPrivacyPolicyExists);

    [app activate];

    sleep(1);
  }
}


- (void)testLoadCreative_inDebugMode_showsDebugMessage {
  [self launchAppWithMode:@"debug"];
  [app.buttons[@"Push me for Creative!"] tapOnElement];

  // Verify debug page shows
  XCTAssertTrue([app.staticTexts[@"Debug output JSON"] elementExists]);
}

- (void)testLoadCreative_clickProductPage_closesCreative {
  [self launchAppWithMode:@"production"];
  [app.buttons[@"Push me for Creative!"] tapOnElement];

  // Click privacy link
  [app.tabBars.buttons[@"Product"] tapOnElement];

  // Verify that the product page is visible
  XCTAssertTrue([app.buttons[@"Add To Cart"] elementExists]);

  // Nav back, and verify the creative is closed
  [app.tabBars.buttons[@"Main"] tapOnElement];
  XCTAssertTrue([app.buttons[@"Push me for Creative!"] elementExists]);
}


- (void)clearCookies {
  NSLog(@"Clearing cookies!");
  NSSet *websiteDataTypes = [NSSet setWithArray:@[ WKWebsiteDataTypeCookies ]];
  NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
  [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                             modifiedSince:dateFrom
                                         completionHandler:^() {
                                           NSLog(@"Cleared cookies!");
                                         }];
}


- (void)resetUserDefaults {
  // Reset user defaults for example app, not the test runner
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.attentive.ExampleTest"];
}


- (void)launchAppWithMode:(NSString *)mode {
  app.launchEnvironment = @{
    @"COM_ATTENTIVE_EXAMPLE_DOMAIN" : @"mobileapps",
    @"COM_ATTENTIVE_EXAMPLE_MODE" : mode,
    @"COM_ATTENTIVE_EXAMPLE_IS_UI_TEST" : @"YES",
  };
  [app launch];
}


@end
