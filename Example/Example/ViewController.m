#import "ViewController.h"
#import "ATTNSDKFramework/ATTNSDKFramework-Swift.h"
#import <WebKit/WebKit.h>

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

  // Replace with your Attentive domain to test with your Attentive account
  _domain = @"mobileapps";
  _mode = @"production";

  // Setup for Testing purposes only
  [self setupForUITests];

  // Intialize the Attentive SDK.
  // This only has to be done once per application lifecycle so you can do
  // this in a singleton class rather than each time a view loads.
  sdk = [[ATTNSDK alloc] initWithDomain:_domain mode:_mode];

  // Initialize the ATTNEventTracker. This must be done before the ATTNEventTracker can be used to send any events.
  [ATTNEventTracker setupWithSdk:sdk];

  // Register the current user with the Attentive SDK by calling the `identify` method. Each identifier is optional, but the more identifiers you provide the better the Attentive SDK will function.
  _userIdentifiers = @{ATTNIdentifierType.phone : @"+14156667777",
                       ATTNIdentifierType.email : @"someemail@email.com",
                       ATTNIdentifierType.clientUserId : @"APP_USER_ID",
                       ATTNIdentifierType.shopifyId : @"207119551",
                       ATTNIdentifierType.klaviyoId : @"555555",
                       ATTNIdentifierType.customIdentifiers : @{@"customId" : @"customIdValue"}};
  [sdk identify:_userIdentifiers];

  // Attentive Example app specific setup code
  [_domainLabel setText: [NSString stringWithFormat:@"Domain: %@", _domain]];
}

- (IBAction)creativeButtonPress:(id)sender {
  // Clear cookies to avoid Creative filtering during testing. Do not clear
  // cookies if you want to test Creative fatigue and filtering.
  [self clearCookies];

  // Display the creative, with a callback handler
  // You can also call [sdk trigger:self.view] without a callback handler
  [sdk trigger:self.view
       handler:^(NSString *triggerStatus) {
         if (triggerStatus == ATTNCreativeTriggerStatus.opened) {
           NSLog(@"Opened the Creative!");
         } else if (triggerStatus == ATTNCreativeTriggerStatus.notOpened) {
           NSLog(@"Couldn't open the Creative!");
         } else if (triggerStatus == ATTNCreativeTriggerStatus.closed) {
           NSLog(@"Closed the Creative!");
         } else if (triggerStatus == ATTNCreativeTriggerStatus.notClosed) {
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

- (IBAction)swichDomainTapped:(id)sender {
  [self showAlertForSwitchingDomains];
}

- (void)showAlertForSwitchingDomains {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Switch Domain"
                                                                           message:@"Here you will test switching domains"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

  [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = @"Enter the new Domain here";
  }];

  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
    UITextField *textField = alertController.textFields.firstObject;
    [self handleDomainInput:textField.text];
  }];

  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
  [alertController addAction:okAction];
  [alertController addAction:cancelAction];

  [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleDomainInput:(NSString *)text {
  [sdk updateDomain:text];

  _domain = text;

  [_domainLabel setText: [NSString stringWithFormat:@"Domain: %@", _domain]];

  [self showToast:[NSString stringWithFormat:@"New domain is %@", text]];
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

- (void)showToast:(NSString*)message {
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];

  [self presentViewController:alert animated:YES completion:nil];

  int duration = 3; // duration in seconds

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [alert dismissViewControllerAnimated:YES completion:nil];
  });
}

@end
