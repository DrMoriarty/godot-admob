#include "godotAdmob.h"
#import "app_delegate.h"
#import "AdmobBanner.h"
#import "AdmobInterstitial.h"
#import "AdmobRewarded.h"

#if VERSION_MAJOR == 3
#define CLASS_DB ClassDB
#else
#define CLASS_DB ObjectTypeDB
#endif

#define BANNER_ENABLE_DELAY 5
 
static NSMutableDictionary *banners = nil;
static NSMutableDictionary *interstitials = nil;
static NSMutableDictionary *rewardeds = nil;
static NSString *lastBannerId = nil;

GodotAdmob::GodotAdmob() {
    banners = [NSMutableDictionary new];
    interstitials = [NSMutableDictionary new];
    rewardeds = [NSMutableDictionary new];
}

GodotAdmob::~GodotAdmob() {
}

void GodotAdmob::init(bool isReal, int instanceId) {
    productionMode = isReal;
    defaultCallbackId = instanceId;
}

void GodotAdmob::loadBanner(const String &bannerId, bool isOnTop, int callbackId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner *banner = [AdmobBanner alloc];
    [banner initialize :productionMode callbackId:(callbackId > 0 ? callbackId : defaultCallbackId)];
    [banner loadBanner:idStr top:isOnTop];
    [banners setObject:banner forKey:idStr];
}

void GodotAdmob::showBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner showBanner];
    lastBannerId = idStr;
    bannerShown = true;
}

void GodotAdmob::hideBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner hideBanner];
    bannerShown = false;
}

void GodotAdmob::removeBanner(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    [banner disableBanner];
    [banners removeObjectForKey:idStr];
}

void GodotAdmob::resize() {
    //[banner resize];
}

int GodotAdmob::getBannerWidth(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    return (uintptr_t)[banner getBannerWidth];
}

int GodotAdmob::getBannerHeight(const String &bannerId) {
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobBanner * banner = [banners objectForKey:idStr];
    return (uintptr_t)[banner getBannerHeight];
}

void GodotAdmob::loadInterstitial(const String &interstitialId, int callbackId) {
    NSString *idStr = [NSString stringWithCString:interstitialId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobInterstitial * interstitial = [AdmobInterstitial alloc];
    [interstitial initialize:productionMode callbackId:(callbackId > 0 ? callbackId : defaultCallbackId)];
    [interstitial loadInterstitial:idStr];
    [interstitials setObject:interstitial forKey:idStr];
}

void GodotAdmob::showInterstitial(const String &interstitialId) {
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

void GodotAdmob::loadRewardedVideo(const String &rewardedId, int callbackId) {
    NSString *idStr = [NSString stringWithCString:rewardedId.utf8().get_data() encoding: NSUTF8StringEncoding];
    AdmobRewarded * rewarded = [AdmobRewarded alloc];
    [rewarded initialize:productionMode callbackId:(callbackId > 0 ? callbackId : defaultCallbackId)];
    [rewarded loadRewardedVideo: idStr];
    [rewardeds setObject:rewarded forKey:idStr];
}

void GodotAdmob::showRewardedVideo(const String &rewardedId) {
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

void GodotAdmob::disableAllBanners() {
    for(NSString *bid in banners.allKeys) {
        AdmobBanner *b = [banners objectForKey:bid];
        [b disableBanner];
    }
}

void GodotAdmob::enableAllBanners() {
    for(NSString *bid in banners.allKeys) {
        AdmobBanner *b = [banners objectForKey:bid];
        [b enableBanner];
    }
    if(bannerShown && lastBannerId != nil) {
        AdmobBanner * banner = [banners objectForKey:lastBannerId];
        [banner showBanner];
    }
}

void GodotAdmob::_bind_methods() {
    CLASS_DB::bind_method("init",&GodotAdmob::init);
    CLASS_DB::bind_method("loadBanner",&GodotAdmob::loadBanner);
    CLASS_DB::bind_method("showBanner",&GodotAdmob::showBanner);
    CLASS_DB::bind_method("hideBanner",&GodotAdmob::hideBanner);
    CLASS_DB::bind_method("loadInterstitial",&GodotAdmob::loadInterstitial);
    CLASS_DB::bind_method("showInterstitial",&GodotAdmob::showInterstitial);
    CLASS_DB::bind_method("loadRewardedVideo",&GodotAdmob::loadRewardedVideo);
    CLASS_DB::bind_method("showRewardedVideo",&GodotAdmob::showRewardedVideo);
    CLASS_DB::bind_method("resize",&GodotAdmob::resize);
    CLASS_DB::bind_method("getBannerWidth",&GodotAdmob::getBannerWidth);
    CLASS_DB::bind_method("getBannerHeight",&GodotAdmob::getBannerHeight);
}
