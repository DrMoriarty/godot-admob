#import "app_delegate.h"
#import <GoogleMobileAds/GADRewardedAdDelegate.h>

@interface AdmobRewarded: NSObject <GADRewardedAdDelegate> {
    bool initialized;
    bool isReal;
    int instanceId;
    NSString *adUnitId;
    ViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;
@property (nonatomic, strong) void(^closeCallback)(void);

- (void)initialize:(BOOL)is_real callbackId:(int)instance_id;
- (void)loadRewardedVideo:(NSString*)rewardedId;
- (void)showRewardedVideo;

@end
