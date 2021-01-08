#pragma once

#include <Godot.hpp>
#include <Reference.hpp>

class AdMob : public godot::Reference {
    
    GODOT_CLASS(AdMob, godot::Reference);

    bool productionMode;
    bool bannerShown;

protected:
    void disableAllBanners();
    void enableAllBanners();

public:
    static void _register_methods();
    void _init();

    void init(bool isReal);
    void loadBanner(const godot::String &bannerId, bool isOnTop, godot::Object* callbackObj);
    void showBanner(const godot::String &bannerId);
    void hideBanner(const godot::String &bannerId);
    void removeBanner(const godot::String &bannerId);
    void resize();
    int getBannerWidth(const godot::String &bannerId);
    int getBannerHeight(const godot::String &bannerId);
    void loadInterstitial(const godot::String &interstitialId, godot::Object* callbackObj);
    void showInterstitial(const godot::String &interstitialId);
    void loadRewardedVideo(const godot::String &rewardedId, godot::Object* callbackObj);
    void showRewardedVideo(const godot::String &rewardedId);

    AdMob();
    ~AdMob();
};
