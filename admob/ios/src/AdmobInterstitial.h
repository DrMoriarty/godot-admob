#import <GoogleMobileAds/GADInterstitial.h>
#import "app_delegate.h"

@interface AdmobInterstitial: UIViewController <GADInterstitialDelegate> {
    GADInterstitial *interstitial;
    bool initialized;
    bool isReal;
    int instanceId;
    ViewController *rootController;
}

- (void)initialize:(BOOL)is_real: (int)instance_id;
- (void)loadInterstitial:(NSString*)interstitialId;
- (void)showInterstitial;

@end
