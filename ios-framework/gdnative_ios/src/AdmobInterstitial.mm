#include <Godot.hpp>
#import "AdmobInterstitial.h"

using namespace godot;

@implementation AdmobInterstitial

- (void)dealloc {
    interstitial.delegate = nil;
}

- (void)initialize:(BOOL)is_real callbackObj:(Object*)cbObj {
    isReal = is_real;
    initialized = true;
    callbackObj = cbObj;
    rootController = UIApplication.sharedApplication.keyWindow.rootViewController;
}

-(NSString*)unitId {
    return adUnitId;
}

- (void) loadInterstitial:(NSString*)interstitialId {
    
    NSLog(@"Calling loadInterstitial");
    //init
    if (!initialized) {
        return;
    }
    adUnitId = interstitialId;
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:interstitialId];
    interstitial.delegate = self;
    
    //load
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
}

- (void) showInterstitial {
    NSLog(@"Calling showInterstitial");
    //show
    
    if (interstitial == nil || !initialized) {
        return;
    }
    
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:rootController];
    } else {
        NSLog(@"Interstitial Ad wasn't ready");
    }
}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    callbackObj->call_deferred("_on_interstitial_loaded", String(adUnitId.UTF8String));
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    callbackObj->call_deferred("_on_interstitial_failed_to_load", String(adUnitId.UTF8String), String(error.description.UTF8String));
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    callbackObj->call_deferred("_on_interstitial_close", String(adUnitId.UTF8String));
    [NSNotificationCenter.defaultCenter postNotificationName:@"AdMobInterstitialClosed" object:nil];
    if(_closeCallback != nil) _closeCallback();
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}


@end
