#import <GoogleMobileAds/GADRewardedAdDelegate.h>

@interface AdmobRewarded: NSObject <GADRewardedAdDelegate> {
    bool initialized;
    bool isReal;
    godot::Object* callbackObj;
    NSString *adUnitId;
    UIViewController *rootController;
}

@property (nonatomic, readonly) NSString *unitId;
@property (nonatomic, strong) void(^closeCallback)(void);

- (void)initialize:(BOOL)is_real callbackObj:(godot::Object*)cbObj;
- (void)loadRewardedVideo:(NSString*)rewardedId;
- (void)showRewardedVideo;

@end
