#ifndef GODOT_ADMOB_H
#define GODOT_ADMOB_H

#include <version_generated.gen.h>

#include "reference.h"

/*
#ifdef __OBJC__
@class AdmobBanner;
typedef AdmobBanner *bannerPtr;
@class AdmobInterstitial;
typedef AdmobInterstitial *interstitialPtr;
@class AdmobRewarded;
typedef AdmobRewarded *rewardedPtr;
#else
typedef void *bannerPtr;
typedef void *interstitialPtr;
typedef void *rewardedPtr;
#endif
*/

class GodotAdmob : public Reference {
    
#if VERSION_MAJOR == 3
    GDCLASS(GodotAdmob, Reference);
#else
    OBJ_TYPE(GodotAdmob, Reference);
#endif

    int defaultCallbackId;
    bool productionMode;
    bool bannerShown;

protected:
    static void _bind_methods();

    void disableAllBanners();
    void enableAllBanners();

public:

    void init(bool isReal, int instanceId);
    void loadBanner(const String &bannerId, bool isOnTop, int callbackId);
    void showBanner(const String &bannerId);
    void hideBanner(const String &bannerId);
    void removeBanner(const String &bannerId);
    void resize();
    int getBannerWidth(const String &bannerId);
    int getBannerHeight(const String &bannerId);
    void loadInterstitial(const String &interstitialId, int callbackId);
    void showInterstitial(const String &interstitialId);
    void loadRewardedVideo(const String &rewardedId, int callbackId);
    void showRewardedVideo(const String &rewardedId);

    GodotAdmob();
    ~GodotAdmob();
};

#endif
