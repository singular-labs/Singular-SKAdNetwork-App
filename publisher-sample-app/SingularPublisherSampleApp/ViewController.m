//
//  ViewController.m
//  SingularPublisherSampleApp
//
//  Created by Eyal Rabinovich on 24/06/2020.
//

#import "ViewController.h"
#import "AdController.h"

// Don't forget to import this to have access to the SKAdnetwork consts
#import <StoreKit/SKAdNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

// Ad Request Keys
NSString * const REQUEST_SOURCE_APP_ID_KEY = @"source_app_id";
NSString * const REQUEST_SKADNETWORK_VERSION_KEY = @"skadnetwork_version";

// Ad Request Values
NSString * const REQUEST_AD_SERVER_ADDRESS = @"http://<ENTER_YOU_SERVER_IP_HERE>:8000/get-ad-impression";
NSString * const REQUEST_SOURCE_APP_ID = @"<ENTER_SOURCE_APP_ID_HERE>";
NSString * const REQUEST_SKADNETWORK_V1 = @"1.0";
NSString * const REQUEST_SKADNETWORK_V2 = @"2.0";

// Ad Response Keys - These are the same as our server, but real Ad Networks may return different keys.
NSString * const RESPONSE_AD_NETWORK_ID_KEY = @"adNetworkId";
NSString * const RESPONSE_SOURCE_APP_ID_KEY = @"sourceAppId";
NSString * const RESPONSE_SKADNETWORK_VERSION_KEY = @"adNetworkVersion";
NSString * const RESPONSE_TARGET_APP_ID_KEY = @"id";
NSString * const RESPONSE_SIGNATURE_KEY = @"signature";
NSString * const RESPONSE_CAMPAIGN_ID_KEY = @"campaignId";
NSString * const RESPONSE_TIMESTAMP_KEY = @"timestamp";
NSString * const RESPONSE_NONCE_KEY = @"nonce";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showAdClick:(id)sender {
    // Step 1: Retrieving ad data from a python server to imitate a real Ad Network.
    // Our server uses the adnetwork key to sign the ad payload.
    // For more information please check out the skadnetwork_server folder in the repo.
    [self getProductDataFromServer];
}

- (void)getProductDataFromServer {
    // Building the URL for the GET request to the server
    NSURLComponents *components = [NSURLComponents componentsWithString:REQUEST_AD_SERVER_ADDRESS];
    NSURLQueryItem *sourceAppId = [NSURLQueryItem queryItemWithName:REQUEST_SOURCE_APP_ID_KEY value:REQUEST_SOURCE_APP_ID];
    
    // The Ad Network needs to generate different signature according to the SKAdNetwork version.
    // For OS version below 14.0 we should pass '1.0', and for 14.0 and above we need to pass '2.0'.
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSURLQueryItem *skAdNetworkVersion = [NSURLQueryItem
                                          queryItemWithName:REQUEST_SKADNETWORK_VERSION_KEY
                                          value:osVersion < 14 ? REQUEST_SKADNETWORK_V1 : REQUEST_SKADNETWORK_V2];
    
    components.queryItems = @[ skAdNetworkVersion, sourceAppId ];
    
    // Sending an Async GET request to the server to get the Ad data.
    [[[NSURLSession sharedSession] dataTaskWithURL:components.URL
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            return;
        }
        
        // Step 2: Parsing the data that we got from the Ad Network to fit the `loadProductWithParameters` format in the AdController.
        NSDictionary* productData = [self parseResponseData:data];
        
        if (!productData){
            return;
        }
        
        // Step 3: Show the AdController with the product data we got from the Ad Network.
        [self loadProductFromResponseData:productData];
    }] resume];
}

- (void)loadProductFromResponseData:(NSDictionary*)productData {
    if (!productData){
        return;
    }
    
    // Initializing and showing the AdController with the product data.
    // Check out the `viewDidLoad` method in the AdController for the next step.
    dispatch_async(dispatch_get_main_queue(), ^{
        AdController* adController = [[AdController alloc] initWithProductData:productData];
        [self showViewController:adController sender:self];
    });
}

- (NSDictionary*)parseResponseData:(NSData*)data{
    if (!data){
        return nil;
    }
    
    NSError* error;
    NSDictionary* responseData = [[NSMutableDictionary alloc]initWithDictionary:
                                        [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&error]];
    
    if (error){
        return nil;
    }
    
    NSMutableDictionary* productData = [[NSMutableDictionary alloc] init];
    
    NSString* skAdNetworkVersion = [responseData objectForKey:RESPONSE_SKADNETWORK_VERSION_KEY];
    
    // These product params should be of NSString* type.
    [productData setObject:[responseData objectForKey:RESPONSE_SIGNATURE_KEY] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
    [productData setObject:[responseData objectForKey:RESPONSE_TARGET_APP_ID_KEY] forKey:SKStoreProductParameterITunesItemIdentifier];
    [productData setObject:skAdNetworkVersion forKey:SKStoreProductParameterAdNetworkVersion];
    
    // These product params should be of NSNumber* type.
    [productData setObject:@([[responseData objectForKey:RESPONSE_CAMPAIGN_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
    [productData setObject:@([[responseData objectForKey:RESPONSE_TIMESTAMP_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkTimestamp];
    
    // These product params are only included in SKAdNetwork version 2.0
    if ([skAdNetworkVersion isEqualToString:REQUEST_SKADNETWORK_V2]) {
        [productData setObject:[responseData objectForKey:RESPONSE_AD_NETWORK_ID_KEY] forKey:SKStoreProductParameterAdNetworkIdentifier];
        [productData setObject:@([[responseData objectForKey:RESPONSE_SOURCE_APP_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
    }
    
    // This param has to be of NSUUID type, an exception is thrown if it is passed in NSString* type.
    [productData setObject:[[NSUUID alloc] initWithUUIDString:[responseData objectForKey:RESPONSE_NONCE_KEY]] forKey:SKStoreProductParameterAdNetworkNonce];
    
    return productData;
}

- (IBAction)showSingularClick:(id)sender {
    NSURL* singular = [NSURL URLWithString:@"https://www.singular.net?utm_medium=sample-app&utm_source=sample-app"];
    
    if( [[UIApplication sharedApplication] canOpenURL:singular]){
        [[UIApplication sharedApplication] openURL:singular options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

@end
