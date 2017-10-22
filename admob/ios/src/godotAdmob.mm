#include "godotAdmob.h"

#import "app_delegate.h"

#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADRewardBasedVideoAd.h>
#import <GoogleMobileAds/GADAdReward.h>
#import <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>

GodotAdmob* instance = NULL;
GADBannerView *bannerView = nil;
GADInterstitial *interstitial = nil;
ViewController *root_controller = nil;


@interface InterstitialDelegateBridge : NSObject<GADInterstitialDelegate>
@property int _instanceId;
@end

@interface BannerViewDelegateBridge : NSObject<GADBannerViewDelegate>
@property int _instanceId;
@end

@interface RewardedVideoDelegateBridge : NSObject<GADRewardBasedVideoAdDelegate>
@property int _instanceId;
@end



GodotAdmob::GodotAdmob() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    isReal = false;
    initialized = false;
}

GodotAdmob::~GodotAdmob() {
    instance = NULL;
}

void GodotAdmob::init(bool isReal, int instanceId) {
    if (initialized) {
        NSLog(@"Module already initialized");
        return;
    }
    
    this->isReal = isReal;
    this->instanceId = instanceId;
    root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    initialized = true;
}


void GodotAdmob::loadBanner(const String &bannerId, bool isOnTop) {
    NSLog(@"Calling loadBanner");
    
    if (!initialized) {
        return;
    }

    if (bannerView == nil) {
        bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
        if(!isReal) {
            bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        }
        else {
            bannerView.adUnitID = [NSString stringWithCString:bannerId.utf8().get_data() encoding:NSUTF8StringEncoding];
        }
        bannerView.delegate = [[BannerViewDelegateBridge alloc] init:instanceId];
        
        bannerView.rootViewController = root_controller;
        [root_controller.view addSubview:bannerView];
        
    }
    
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
        
    if(!isOnTop) {
        //TODO: pegar largura e altura daqui
        float height = root_controller.view.frame.size.height;
        float width = root_controller.view.frame.size.width;
        NSLog(@"height: %f, width: %f", height, width);
        [bannerView setFrame:CGRectMake(0, height-bannerView.bounds.size.height, bannerView.bounds.size.width, bannerView.bounds.size.height)];
    }
    
}

void GodotAdmob::showBanner() {
    NSLog(@"Calling showBanner");
    
    if (bannerView == nil || !initialized) {
        return;
    }
    
    [bannerView setHidden:NO];
}

void GodotAdmob::hideBanner() {
    NSLog(@"Calling hideBanner");
    if (bannerView == nil || !initialized) {
        return;
    }
    [bannerView setHidden:YES];
}


void GodotAdmob::resize() {
    NSLog(@"Not implemented for iOS");
}

int GodotAdmob::getBannerWidth() {
    return bannerView.bounds.size.width;
}

int GodotAdmob::getBannerHeight() {
    return bannerView.bounds.size.height;
}

void GodotAdmob::loadInterstitial(const String &interstitialId) {
    
    NSLog(@"Calling loadInterstitial");
    //init
    if (!initialized) {
        return;
    }
    
    interstitial = nil;
    if(!isReal) {
        interstitial = [[GADInterstitial alloc]
                        initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    }
    else {
        interstitial = [[GADInterstitial alloc]
                        initWithAdUnitID:[NSString stringWithCString:interstitialId.utf8().get_data() encoding:NSUTF8StringEncoding]];
    }

    interstitial.delegate = [[InterstitialDelegateBridge alloc] init:instanceId];

    
    //load
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
}

void GodotAdmob::showInterstitial() {
    NSLog(@"Calling showInterstitial");
    //show
    
    if (interstitial == nil || !initialized) {
        return;
    }
    
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:root_controller];
    } else {
        NSLog(@"Interstitial Ad wasn't ready");
    }
    
    
}

void GodotAdmob::loadRewardedVideo(const String &rewardedId) {
    NSLog(@"Calling loadRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    
    if(!isReal) {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
                                                          withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];
    }
    else {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
                                                          withAdUnitID:[NSString stringWithCString:rewardedId.utf8().get_data() encoding:NSUTF8StringEncoding]];
    }
    
    
    [GADRewardBasedVideoAd sharedInstance].delegate = [[RewardedVideoDelegateBridge alloc] init:instanceId];
    
}

void GodotAdmob::showRewardedVideo() {
    NSLog(@"Calling showRewardedVideo");
    //init
    if (!initialized) {
        return;
    }
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:root_controller];
    }
    
}



@implementation BannerViewDelegateBridge

- (id) init: (int) instanceId {
    self = [super init];
    if (self) {
        self._instanceId = instanceId;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_admob_ad_loaded");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_admob_network_error");
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end


@implementation InterstitialDelegateBridge

- (id) init: (int) instanceId {
    self = [super init];
    if (self) {
        self._instanceId = instanceId;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_interstitial_loaded");
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_interstitial_not_loaded");
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_interstitial_close");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}


@end


@implementation RewardedVideoDelegateBridge

- (id) init: (int) instanceId {
    self = [super init];
    if (self) {
        self._instanceId = instanceId;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage =
    [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
     reward.type,
     [reward.amount doubleValue]];
    NSLog(rewardMessage);
    
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded", [reward.type UTF8String], reward.amount.doubleValue);
    
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_ad_loaded");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_ad_opened");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_started");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_ad_closed");
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_ad_left_application");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load: %@ ", error.localizedDescription);
    Object *obj = ObjectDB::get_instance(self._instanceId);
    obj->call_deferred("_on_rewarded_video_ad_failed_to_load", error.code);
}

@end


void GodotAdmob::_bind_methods() {
    ObjectTypeDB::bind_method("init",&GodotAdmob::init);
    ObjectTypeDB::bind_method("loadBanner",&GodotAdmob::loadBanner);
    ObjectTypeDB::bind_method("showBanner",&GodotAdmob::showBanner);
    ObjectTypeDB::bind_method("hideBanner",&GodotAdmob::hideBanner);
    ObjectTypeDB::bind_method("loadInterstitial",&GodotAdmob::loadInterstitial);
    ObjectTypeDB::bind_method("showInterstitial",&GodotAdmob::showInterstitial);
    ObjectTypeDB::bind_method("loadRewardedVideo",&GodotAdmob::loadRewardedVideo);
    ObjectTypeDB::bind_method("showRewardedVideo",&GodotAdmob::showRewardedVideo);
    ObjectTypeDB::bind_method("resize",&GodotAdmob::resize);
    ObjectTypeDB::bind_method("getBannerWidth",&GodotAdmob::getBannerWidth);
    ObjectTypeDB::bind_method("getBannerHeight",&GodotAdmob::getBannerHeight);
}
