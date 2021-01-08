#import <GoogleMobileAds/GADInterstitial.h>

@interface AdmobInterstitial: NSObject <GADInterstitialDelegate> {
    GADInterstitial *interstitial;
    bool initialized;
    bool isReal;
    godot::Object* callbackObj;
    NSString *adUnitId;
    UIViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;
@property (nonatomic, strong) void(^closeCallback)(void);

- (void)initialize:(BOOL)is_real callbackObj:(godot::Object*)cbObj;
- (void)loadInterstitial:(NSString*)interstitialId;
- (void)showInterstitial;

@end
