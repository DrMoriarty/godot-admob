#import <GoogleMobileAds/GADBannerView.h>
#import "app_delegate.h"

@interface AdmobBanner: UIViewController <GADBannerViewDelegate> {
    GADBannerView *bannerView_;
    bool initialized;
    bool isReal;
    int instanceId;
    ViewController *rootController;
}

- (void)initialize:(BOOL)is_real: (int)instance_id;
- (void)loadBanner:(NSString*)bannerId :(BOOL)isOnTop;
- (void)showBanner;
- (void)hideBanner;
- (void)resize;
- (int)getBannerWidth;
- (int)getBannerHeight;

@end
