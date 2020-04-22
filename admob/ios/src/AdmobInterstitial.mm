#import "AdmobInterstitial.h"
#include "reference.h"


@implementation AdmobInterstitial

- (void)dealloc {
    interstitial.delegate = nil;
    [interstitial release];
    [super dealloc];
}

- (void)initialize:(BOOL)is_real callbackId:(int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = [AppDelegate getViewController];
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
    
    interstitial = nil;
    if(!isReal) {
        interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    }
    else {
        interstitial = [[GADInterstitial alloc] initWithAdUnitID:interstitialId];
    }
    
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
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_interstitial_loaded", adUnitId);
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_interstitial_failed_to_load", adUnitId, error.localizedDescription);
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
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_interstitial_close", adUnitId);
    [NSNotificationCenter.defaultCenter postNotificationName:@"AdMobInterstitialClosed" object:nil];
    if(_closeCallback != nil) _closeCallback();
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}


@end
