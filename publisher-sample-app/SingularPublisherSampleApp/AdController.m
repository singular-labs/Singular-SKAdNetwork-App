//
//  AdController.m
//  SingularPublisherSampleApp
//
//  Created by Eyal Rabinovich on 24/06/2020.
//

#import "AdController.h"


@implementation AdController

- (id)initWithProductData:(NSDictionary*)data {
    self = [super init];
    self->productData = data;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Step 4: Showing the AppStore window with the product we got from the Ad Network.
    [self loadProductWithParameters:self->productData completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error || !result){
            // Loading the ad failed, try to load another ad or retry the current ad.
        } else {
            // Ad loaded successfully! :)
        }
    }];
}

@end
