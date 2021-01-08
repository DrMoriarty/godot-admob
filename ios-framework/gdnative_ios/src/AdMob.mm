#include "AdMob.hpp"
#import "AdmobBanner.h"
#import "AdmobInterstitial.h"
#import "AdmobRewarded.h"

#define BANNER_ENABLE_DELAY 5
 
static NSMutableDictionary *banners = nil;
static NSMutableDictionary *interstitials = nil;
static NSMutableDictionary *rewardeds = nil;
static NSString *lastBannerId = nil;

using namespace godot;

AdMob::AdMob() {
    banners = [NSMutableDictionary new];
    interstitials = [NSMutableDictionary new];
    rewardeds = [NSMutableDictionary new];
}

AdMob::~AdMob() {
}

void AdMob::_init() {
    
}

void AdMob::init(bool isReal) {
    productionMode = isReal;
}

void AdMob::loadBanner(const String &bannerId, bool isOnTop, Object* callbackObj) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner *banner = [AdmobBanner alloc];
    [banner initialize :productionMode callbackObj:callbackObj];
    [banner loadBanner:idStr top:isOnTop];
    [banners setObject:banner forKey:idStr];
}

void AdMob::showBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner showBanner];
    lastBannerId = idStr;
    bannerShown = true;
}

void AdMob::hideBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner hideBanner];
    bannerShown = false;
}

void AdMob::removeBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner disableBanner];
    [banners removeObjectForKey:idStr];
}

void AdMob::resize() {
    //[banner resize];
}

int AdMob::getBannerWidth(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    return (uintptr_t)[banner getBannerWidth];
}

int AdMob::getBannerHeight(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    return (uintptr_t)[banner getBannerHeight];
}

void AdMob::loadInterstitial(const String &interstitialId, Object* callbackObj) {
    NSString *idStr = [NSString stringWithCString:interstitialId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobInterstitial * interstitial = [AdmobInterstitial alloc];
    [interstitial initialize:productionMode callbackObj:callbackObj];
    [interstitial loadInterstitial:idStr];
    [interstitials setObject:interstitial forKey:idStr];
}

void AdMob::showInterstitial(const String &interstitialId) {
    // need to disable active banner
    disableAllBanners();
    
    NSString *idStr = [NSString stringWithCString:interstitialId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobInterstitial * interstitial = [interstitials objectForKey:idStr];
    interstitial.closeCallback = ^()
        {
         // may enable banner
         enableAllBanners();
        };
    [interstitial showInterstitial];
}

void AdMob::loadRewardedVideo(const String &rewardedId, Object* callbackObj) {
    NSString *idStr = [NSString stringWithCString:rewardedId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobRewarded * rewarded = [AdmobRewarded alloc];
    [rewarded initialize:productionMode callbackObj:callbackObj];
    [rewarded loadRewardedVideo: idStr];
    [rewardeds setObject:rewarded forKey:idStr];
}

void AdMob::showRewardedVideo(const String &rewardedId) {
    // need to disable active banner
    disableAllBanners();

    NSString *idStr = [NSString stringWithCString:rewardedId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobRewarded * rewarded = [rewardeds objectForKey:idStr];
    rewarded.closeCallback = ^()
        {
         // may enable banner
         enableAllBanners();
        };
    [rewarded showRewardedVideo];
}

void AdMob::disableAllBanners() {
    for(NSString *bid in banners.allKeys) {
        AdmobBanner *b = [banners objectForKey:bid];
        [b disableBanner];
    }
}

void AdMob::enableAllBanners() {
    for(NSString *bid in banners.allKeys) {
        AdmobBanner *b = [banners objectForKey:bid];
        [b enableBanner];
    }
    if(bannerShown && lastBannerId != nil) {
        AdmobBanner * banner = [banners objectForKey:lastBannerId];
        [banner showBanner];
    }
}

void AdMob::_register_methods() {
    register_method("init",&AdMob::init);
    register_method("loadBanner",&AdMob::loadBanner);
    register_method("showBanner",&AdMob::showBanner);
    register_method("hideBanner",&AdMob::hideBanner);
    register_method("loadInterstitial",&AdMob::loadInterstitial);
    register_method("showInterstitial",&AdMob::showInterstitial);
    register_method("loadRewardedVideo",&AdMob::loadRewardedVideo);
    register_method("showRewardedVideo",&AdMob::showRewardedVideo);
    register_method("resize",&AdMob::resize);
    register_method("getBannerWidth",&AdMob::getBannerWidth);
    register_method("getBannerHeight",&AdMob::getBannerHeight);
}
