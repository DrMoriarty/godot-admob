#import "AdmobRewarded.h"
#import <GoogleMobileAds/GADRewardedAd.h>
#import <GoogleMobileAds/GADAdReward.h>
#include "reference.h"


@implementation AdmobRewarded {
    GADRewardedAd *rewarded;
}


- (void)initialize:(BOOL)is_real callbackId:(int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = [AppDelegate getViewController];
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
    
    if(!isReal) {
        rewarded = [[GADRewardedAd alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];
    } else {
        rewarded = [[GADRewardedAd alloc] initWithAdUnitID:rewardedId];
    }
    
    GADRequest *request = [GADRequest request];
    [rewarded loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
            if (error) {
                // Handle ad failed to load case.
                NSLog(@"Reward based video ad failed to load: %@ ", error.localizedDescription);
                Object *obj = ObjectDB::get_instance(instanceId);
                obj->call_deferred("_on_rewarded_video_ad_failed_to_load", adUnitId, error.localizedDescription);
            } else {
                // Ad successfully loaded.
                NSLog(@"Reward based video ad is received.");
                Object *obj = ObjectDB::get_instance(instanceId);
                obj->call_deferred("_on_rewarded_video_ad_loaded", adUnitId);
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
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_opened", adUnitId);
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"rewardedAd:didFailToPresentWithError: %@ ", error.localizedDescription);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_failed_to_load", adUnitId, error.localizedDescription);
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"rewardedAdDidDismiss:");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded_video_ad_closed", adUnitId);
    [NSNotificationCenter.defaultCenter postNotificationName:@"AdMobRewardedClosed" object:nil];
    if(_closeCallback != nil) _closeCallback();
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    NSLog(@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_rewarded", adUnitId, [reward.type UTF8String], reward.amount.doubleValue);
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
