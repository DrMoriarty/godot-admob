#ifndef GODOT_ADMOB_H
#define GODOT_ADMOB_H

#include "reference.h"

class GodotAdmob : public Reference {
    OBJ_TYPE(GodotAdmob,Reference);

    bool initialized;
    int instanceId;
    bool isReal;
    

protected:
    static void _bind_methods();

public:

    void init(bool isReal, int instanceId);
    void loadBanner(const String &bannerId, bool isOnTop);
    void showBanner();
    void hideBanner();
    void resize();
    int getBannerWidth();
    int getBannerHeight();
    void loadInterstitial(const String &interstitialId);
    void showInterstitial();
    void loadRewardedVideo(const String &rewardedId);
    void showRewardedVideo();

    GodotAdmob();
    ~GodotAdmob();
};

#endif
