#include <Godot.hpp>
#import "AdmobRewarded.h"
#import <GoogleMobileAds/GADRewardedAd.h>
#import <GoogleMobileAds/GADAdReward.h>

using namespace godot;

@implementation AdmobRewarded {
    GADRewardedAd *rewarded;
}


- (void)initialize:(BOOL)is_real callbackObj:(Object*)cbObj {
    isReal = is_real;
    initialized = true;
    callbackObj = cbObj;
    rootController = UIApplication.sharedApplication.keyWindow.rootViewController;
}

-(NSString*)unitId {
    return adUnitId;
}

- (void) loadRewardedVideo:(NSString*) rewardedId {
    NSLog(@"Calling loadRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    adUnitId = rewardedId;
    
    rewarded = [[GADRewardedAd alloc] initWithAdUnitID:rewardedId];
    
    GADRequest *request = [GADRequest request];
    [rewarded loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
            if (error) {
                // Handle ad failed to load case.
                NSLog(@"Reward based video ad failed to load: %@ ", error.localizedDescription);
                callbackObj->call_deferred("_on_rewarded_video_ad_failed_to_load", String(adUnitId.UTF8String), String(error.description.UTF8String));
            } else {
                // Ad successfully loaded.
                NSLog(@"Reward based video ad is received.");
                callbackObj->call_deferred("_on_rewarded_video_ad_loaded", String(adUnitId.UTF8String));
            }
        }];
}

- (void) showRewardedVideo {
    NSLog(@"Calling showRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    
    if (rewarded.isReady) {
        [rewarded presentFromRootViewController:rootController delegate:self];
    } else {
        NSLog(@"RewardedAd wasn't ready");
    }    
}

- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    NSLog(@"rewardedAdDidPresent:");
    callbackObj->call_deferred("_on_rewarded_video_ad_opened", String(adUnitId.UTF8String));
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"rewardedAd:didFailToPresentWithError: %@ ", error.localizedDescription);
    callbackObj->call_deferred("_on_rewarded_video_ad_failed_to_load", String(adUnitId.UTF8String), String(error.description.UTF8String));
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"rewardedAdDidDismiss:");
    callbackObj->call_deferred("_on_rewarded_video_ad_closed", String(adUnitId.UTF8String));
    [NSNotificationCenter.defaultCenter postNotificationName:@"AdMobRewardedClosed" object:nil];
    if(_closeCallback != nil) _closeCallback();
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    NSLog(@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]);
    callbackObj->call_deferred("_on_rewarded", adUnitId, String(reward.type.UTF8String), reward.amount.doubleValue);
}

/*
- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_started");
}
         
- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_left_application");
}
         
- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad has completed.");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_completed");
}
*/

@end
