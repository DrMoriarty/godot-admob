#import "AdmobBanner.h"
#include "reference.h"

@implementation AdmobBanner

- (void)dealloc {
    bannerView_.delegate = nil;
    [bannerView_ release];
    [super dealloc];
}

- (void)initialize:(BOOL)is_real: (int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
}

- (void) loadBanner:(NSString*)bannerId: (BOOL)isOnTop {
    NSLog(@"Calling loadBanner");
    
    if (!initialized) {
        return;
    }
    
    if (bannerView_ == nil) {
        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
        if(!isReal) {
            bannerView_.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        }
        else {
            bannerView_.adUnitID = bannerId;
        }

        bannerView_.delegate = self;
        
        bannerView_.rootViewController = rootController;
        [rootController.view addSubview:bannerView_];
        
    }
    
    GADRequest *request = [GADRequest request];
    [bannerView_ loadRequest:request];
    
    if(!isOnTop) {
        float height = rootController.view.frame.size.height;
        float width = rootController.view.frame.size.width;
        NSLog(@"height: %f, width: %f", height, width);
        [bannerView_ setFrame:CGRectMake(0, height-bannerView_.bounds.size.height, bannerView_.bounds.size.width, bannerView_.bounds.size.height)];
    }
    
}

- (void)showBanner {
    NSLog(@"Calling showBanner");
    
    if (bannerView_ == nil || !initialized) {
        return;
    }
    
    [bannerView_ setHidden:NO];
}

- (void) hideBanner {
    NSLog(@"Calling hideBanner");
    if (bannerView_ == nil || !initialized) {
        return;
    }
    [bannerView_ setHidden:YES];
}

- (void) resize {
    NSLog(@"Not implemented for iOS");
}

- (int) getBannerWidth {
    return bannerView_.bounds.size.width;
}

- (int) getBannerHeight {
    return bannerView_.bounds.size.height;
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
