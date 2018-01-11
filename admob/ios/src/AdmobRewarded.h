#import "app_delegate.h"
#import <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>


@interface AdmobRewarded: UIViewController <GADRewardBasedVideoAdDelegate> {
    bool initialized;
    bool isReal;
    int instanceId;
    ViewController *rootController;
}

- (void)initialize:(BOOL)is_real: (int)instance_id;
- (void)loadRewardedVideo:(NSString*)rewardedId;
- (void)showRewardedVideo;

@end
