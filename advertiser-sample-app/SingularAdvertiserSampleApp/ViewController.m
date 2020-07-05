//
//  ViewController.m
//  SingularAdvertiserSampleApp
//
//  Created by Eyal Rabinovich on 25/06/2020.
//

#import "ViewController.h"

// Important: Add the AppTrackingTransparency.framework in the build phases tab.
#import <AppTrackingTransparency/ATTrackingManager.h>

// Don't forget to import this to have access to the SKAdnetwork framework
#import <StoreKit/SKAdNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showTrackingConsentDialog:(id)sender {
    // Checking the OS version before calling the Tracking Consent dialog, it's available only in iOS 14 and above
    if (@available(iOS 14, *)) {
        // If the tracking authorization status is other than not determined, this means that the Tracking Consent dialog has already been shown.
        // The `trackingAuthorizationStatus` persists the result of the Tracking Consent dialog and can only be changed through the iOS settings screen.
        // Tracking Consent dialog is only shown once per install, meaning that calling `requestTrackingAuthorizationWithCompletionHandler` won't show the dialog again.
        if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusNotDetermined){
            [self alertTrackingConsentIsAlreadySet];
        }
        
        // Before showing the Tracking Consent dialog, you'll need to add the `Privacy - Tracking Usage Description` to your app's info.plist.
        // If you don't add it, an exception will be thrown.
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // Here we get the result of the dialog
            // If `requestTrackingAuthorizationWithCompletionHandler` was called twice, the completion handler will be called twice, but will show the dialog on the first time.
            // On the second time this method is called the completion handler will be called with the value returned by `trackingAuthorizationStatus`
        }];
    } else {
        // No need to display the dialog in earlier versions
    }
}

- (IBAction)updateConversionValueClick:(id)sender {
    // Once `registerAppForAdNetworkAttribution` is called for the first time
    // (check the AppDelegate.m for explanations on `registerAppForAdNetworkAttribution`),
    // a 24 hours window is opened to update conversion value for attribution data.
    
    // Using `updateConversionValue` we can add a value (a number between 0-63) to be sent with the attribution notification.
    // Every time we call this method, we start a new 24 hours window until the notification is sent.
    // Please note that calling `updateConversionValue` is only effective in the first 24 hours since `registerAppForAdNetworkAttribution` is first called.
    // Any calls after 24 hours will not update the conversion value in the attribution notification.
    [SKAdNetwork updateConversionValue:3];
    [self alertConversionValueUpdated];
}

- (IBAction)showSingularClick:(id)sender {
    NSURL* singular = [NSURL URLWithString:@"https://www.singular.net?utm_medium=sample-app&utm_source=sample-app-advertiser"];
    
    if( [[UIApplication sharedApplication] canOpenURL:singular]){
        [[UIApplication sharedApplication] openURL:singular options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

- (void)alertConversionValueUpdated {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Conversion Value Updated!"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertTrackingConsentIsAlreadySet {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Can't Display Dialog"
                                                                   message:@"Can't display Tracking Consent dialog because it has already been displayed. "
                                                                           @"To see this dialog again please remove & reinstall this app."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
