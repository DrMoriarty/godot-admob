#import "AdmobBanner.h"
#include "reference.h"

@implementation AdmobBanner

- (void)dealloc {
    bannerView.delegate = nil;
    [bannerView release];
    [super dealloc];
}

- (void)initialize:(BOOL)is_real: (int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
}

- (void) loadBanner:(NSString*)bannerId: (BOOL)is_on_top {
    NSLog(@"Calling loadBanner");
    
    isOnTop = is_on_top;
    
    if (!initialized) {
        return;
    }
    

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (bannerView == nil) {
        if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) { //portrait
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else { //landscape
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        }
        
        if(!isReal) {
            bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        }
        else {
            bannerView.adUnitID = bannerId;
        }

        bannerView.delegate = self;
        
        bannerView.rootViewController = rootController;
        [rootController.view addSubview:bannerView];
        
    }
    
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
    
    
    float height = rootController.view.frame.size.height;
    float width = rootController.view.frame.size.width;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) { // landscape: swap width/height
        float tmp = height;
        height = width;
        width = tmp;
    }
    
    NSLog(@"height: %f, width: %f", height, width);

    if(!isOnTop) {
        [bannerView setFrame:CGRectMake(0, height-bannerView.bounds.size.height, bannerView.bounds.size.width, bannerView.bounds.size.height)];
    }
}



- (void)showBanner {
    NSLog(@"Calling showBanner");
    
    if (bannerView == nil || !initialized) {
        return;
    }
    
    [bannerView setHidden:NO];
}

- (void) hideBanner {
    NSLog(@"Calling hideBanner");
    if (bannerView == nil || !initialized) {
        return;
    }
    [bannerView setHidden:YES];
}

- (void) resize {
    NSLog(@"Calling resize");
    NSString* currentAdUnitId = bannerView.adUnitID;
    [self hideBanner];
    [bannerView removeFromSuperview];
    bannerView = nil;
    [self loadBanner:currentAdUnitId:isOnTop];
}

- (int) getBannerWidth {
    return bannerView.bounds.size.width;
}

- (int) getBannerHeight {
    return bannerView.bounds.size.height;
}



/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_admob_ad_loaded");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_admob_network_error");
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end
