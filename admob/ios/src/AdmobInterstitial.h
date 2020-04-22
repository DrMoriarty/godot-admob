#import <GoogleMobileAds/GADInterstitial.h>
#import "app_delegate.h"

@interface AdmobInterstitial: NSObject <GADInterstitialDelegate> {
    GADInterstitial *interstitial;
    bool initialized;
    bool isReal;
    int instanceId;
    NSString *adUnitId;
    ViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;
@property (nonatomic, strong) void(^closeCallback)(void);

- (void)initialize:(BOOL)is_real callbackId:(int)instance_id;
- (void)loadInterstitial:(NSString*)interstitialId;
- (void)showInterstitial;

@end
