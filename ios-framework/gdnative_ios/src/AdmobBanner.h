#import <GoogleMobileAds/GADBannerView.h>

@interface AdmobBanner: NSObject <GADBannerViewDelegate> {
    GADBannerView *bannerView;
    bool initialized;
    bool isReal;
    bool isOnTop;
    godot::Object* callbackObj;
    NSString *adUnitId;
    UIViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;

- (void)initialize:(BOOL)is_real callbackObj:(godot::Object*)cbObj;
- (void)loadBanner:(NSString*)bannerId top:(BOOL)is_on_top;
- (void)showBanner;
- (void)hideBanner;
- (void)disableBanner;
- (void)enableBanner;
- (void)resize;
- (int)getBannerWidth;
- (int)getBannerHeight;

@end
