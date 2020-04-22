#import <GoogleMobileAds/GADBannerView.h>
#import "app_delegate.h"

@interface AdmobBanner: NSObject <GADBannerViewDelegate> {
    GADBannerView *bannerView;
    bool initialized;
    bool isReal;
    bool isOnTop;
    int instanceId;
    NSString *adUnitId;
    ViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;

- (void)initialize:(BOOL)is_real callbackId:(int)instance_id;
- (void)loadBanner:(NSString*)bannerId top:(BOOL)is_on_top;
- (void)showBanner;
- (void)hideBanner;
- (void)disableBanner;
- (void)enableBanner;
- (void)resize;
- (int)getBannerWidth;
- (int)getBannerHeight;

@end
