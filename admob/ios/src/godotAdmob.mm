#include "godotAdmob.h"
#import "app_delegate.h"


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
    
    initialized = true;
    
    banner = [AdmobBanner alloc];
    [banner initialize :isReal :instanceId];
    
    interstitial = [AdmobInterstitial alloc];
    [interstitial initialize:isReal :instanceId];
    
    rewarded = [AdmobRewarded alloc];
    [rewarded initialize:isReal :instanceId];
}


void GodotAdmob::loadBanner(const String &bannerId, bool isOnTop) {
    if (!initialized) {
        return;
    }
    
    NSString *idStr = [NSString stringWithCString:bannerId.utf8().get_data() encoding: NSUTF8StringEncoding];
    [banner loadBanner:idStr :isOnTop];

}

void GodotAdmob::showBanner() {
    if (!initialized) {
        return;
    }
    
    [banner showBanner];
}

void GodotAdmob::hideBanner() {
    if (!initialized) {
        return;
    }
    [banner hideBanner];
}


void GodotAdmob::resize() {
    [banner resize];
}

int GodotAdmob::getBannerWidth() {
    return (int)[banner getBannerWidth];
}

int GodotAdmob::getBannerHeight() {
    return (int)[banner getBannerHeight];
}

void GodotAdmob::loadInterstitial(const String &interstitialId) {
    if (!initialized) {
        return;
    }
    
    NSString *idStr = [NSString stringWithCString:interstitialId.utf8().get_data() encoding: NSUTF8StringEncoding];
    [interstitial loadInterstitial:idStr];

}

void GodotAdmob::showInterstitial() {
    if (!initialized) {
        return;
    }
    
    [interstitial showInterstitial];
    
}

void GodotAdmob::loadRewardedVideo(const String &rewardedId) {
    //init
    if (!initialized) {
        return;
    }
    
    NSString *idStr = [NSString stringWithCString:rewardedId.utf8().get_data() encoding: NSUTF8StringEncoding];
    [rewarded loadRewardedVideo: idStr];
    
}

void GodotAdmob::showRewardedVideo() {
    //init
    if (!initialized) {
        return;
    }
    
    [rewarded showRewardedVideo];
}



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
