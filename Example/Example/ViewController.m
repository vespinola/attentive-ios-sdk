#import "ViewController.h"
#import "ImportAttentiveSDK.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *creativeButton;
@property (weak, nonatomic) IBOutlet UIButton *sendIdentifiersButton;
@property (weak, nonatomic) IBOutlet UIButton *clearUserButton;
@property (weak, nonatomic) IBOutlet UILabel *domainLabel;

@end


@implementation ViewController {
  NSDictionary *_userIdentifiers;
  NSString *_domain;
  NSString *_mode;
}

ATTNSDK *sdk;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor systemGray3Color];

  CGFloat contentWidth = self.scrollView.bounds.size.width;
  CGFloat contentHeight = self.scrollView.bounds.size.height * 3;
  self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);

  CGFloat subviewHeight = (CGFloat)120;
  CGFloat currentViewOffset = (CGFloat)600;

  while (currentViewOffset < contentHeight) {
    CGRect frame = CGRectInset(CGRectMake(0, currentViewOffset, contentWidth, subviewHeight), 5, 5);
    CGFloat hue = currentViewOffset / contentHeight;
    UIView *subview = [[UIView alloc] initWithFrame:frame];
    subview.backgroundColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    [self.scrollView addSubview:subview];

    currentViewOffset += subviewHeight;
  }

  // Replace with your Attentive domain to test with your Attentive account
  _domain = @"games";
  _mode = @"debug";

  // Setup for Testing purposes only
  [self setupForUITests];

  // Intialize the Attentive SDK.
  // This only has to be done once per application lifecycle so you can do
  // this in a singleton class rather than each time a view loads.
  sdk = [[ATTNSDK alloc] initWithDomain:_domain mode:_mode];

  // Initialize the ATTNEventTracker. This must be done before the ATTNEventTracker can be used to send any events.
  [ATTNEventTracker setupWithSdk:sdk];

  // Register the current user with the Attentive SDK by calling the `identify` method. Each identifier is optional, but the more identifiers you provide the better the Attentive SDK will function.
  _userIdentifiers = @{IDENTIFIER_TYPE_PHONE : @"+14156667777",
                       IDENTIFIER_TYPE_EMAIL : @"someemail@email.com",
                       IDENTIFIER_TYPE_CLIENT_USER_ID : @"APP_USER_ID",
                       IDENTIFIER_TYPE_SHOPIFY_ID : @"207119551",
                       IDENTIFIER_TYPE_KLAVIYO_ID : @"555555",
                       IDENTIFIER_TYPE_CUSTOM_IDENTIFIERS : @{@"customId" : @"customIdValue"}};
  [sdk identify:_userIdentifiers];

  // Attentive Example app specific setup code
  [_domainLabel setText:_domain];
}

- (IBAction)creativeButtonPress:(id)sender {
  // Clear cookies to avoid Creative filtering during testing. Do not clear
  // cookies if you want to test Creative fatigue and filtering.
  [self clearCookies];

  // Display the creative, with a callback handler
  // You can also call [sdk trigger:self.view] without a callback handler
  [sdk trigger:self.view
       handler:^(NSString *triggerStatus) {
         if (triggerStatus == CREATIVE_TRIGGER_STATUS_OPENED) {
           NSLog(@"Opened the Creative!");
         } else if (triggerStatus == CREATIVE_TRIGGER_STATUS_NOT_OPENED) {
           NSLog(@"Couldn't open the Creative!");
         } else if (triggerStatus == CREATIVE_TRIGGER_STATUS_CLOSED) {
           NSLog(@"Closed the Creative!");
         } else if (triggerStatus == CREATIVE_TRIGGER_STATUS_NOT_CLOSED) {
           NSLog(@"Couldn't close the Creative!");
         }
       }];
}

- (IBAction)sendIdentifiersButtonPress:(id)sender {
  // Sends the identifiers to Attentive. This should be done whenever a new identifier becomes
  // available
  [sdk identify:_userIdentifiers];
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

- (IBAction)clearUserButtonPressed:(id)sender {

  NSLog(@"Clear user button pressed!");
  [sdk clearUser];
}

// Method for setting up UI Tests. Only used for testing purposes
- (void)setupForUITests {
  // Override the hard-coded domain & mode with the values from the environment variables
  NSString *envDomain = [[[NSProcessInfo processInfo] environment] objectForKey:@"COM_ATTENTIVE_EXAMPLE_DOMAIN"];
  NSString *envMode = [[[NSProcessInfo processInfo] environment] objectForKey:@"COM_ATTENTIVE_EXAMPLE_MODE"];

  if (envDomain != nil) {
    _domain = envDomain;
  }
  if (envMode != nil) {
    _mode = envMode;
  }

  // Reset the standard user defaults - this must be done from within the app to avoid
  // race conditions
  NSString *isUITest = [[[NSProcessInfo processInfo] environment] objectForKey:@"COM_ATTENTIVE_EXAMPLE_IS_UI_TEST"];
  if ([isUITest isEqualToString:@"YES"]) {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleIdentifier];
  }
}

@end
