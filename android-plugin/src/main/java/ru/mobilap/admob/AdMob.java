package ru.mobilap.admob;

import com.google.android.gms.ads.*;

import java.util.Arrays;
import java.util.List;
import java.util.HashMap;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.widget.FrameLayout;
import android.view.ViewGroup.LayoutParams;
import android.provider.Settings;
import android.graphics.Color;
import android.util.Log;
import java.util.Locale;
import android.view.Gravity;
import android.view.View;
import android.os.Bundle;
import android.view.Display;
import android.util.DisplayMetrics;

import org.godotengine.godot.Godot;
import org.godotengine.godot.GodotLib;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

import com.google.android.gms.ads.AdRequest;
import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdCallback;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardItem;

public class AdMob extends GodotPlugin 
{
    private final String TAG = AdMob.class.getName();

    private Activity activity = null; // The main activity of the game

    private HashMap<String, View> zombieBanners = new HashMap<>();
    private HashMap<String, FrameLayout.LayoutParams> bannerParams = new HashMap<>();
    private HashMap<String, InterstitialAd> interstitials = new HashMap<>();
    private HashMap<String, AdView> banners = new HashMap<>();
    private HashMap<String, RewardedAd> rewardeds = new HashMap<>();
    private HashMap<String, RewardedAdCallback> rewardedCallbacks = new HashMap<>();

    private boolean isReal = false; // Store if is real or not
    private boolean isForChildDirectedTreatment = false; // Store if is children directed treatment desired
    private String maxAdContentRating = ""; // Store maxAdContentRating ("G", "PG", "T" or "MA")
    private Bundle extras = null;

    private FrameLayout layout = null; // Store the layout

    /* Init
     * ********************************************************************** */

    /**
     * Prepare for work with AdMob
     * @param boolean isReal Tell if the enviroment is for real or test
     * @param int gdscript instance id
     */
    public void init(boolean isReal) {
        this.initWithContentRating(isReal, false, "");
    }

    /**
     * Init with content rating additional options 
     * @param boolean isReal Tell if the enviroment is for real or test
     * @param int gdscript instance id
     * @param boolean isForChildDirectedTreatment
     * @param String maxAdContentRating must be "G", "PG", "T" or "MA"
     */
    public void initWithContentRating(boolean isReal, boolean isForChildDirectedTreatment, String maxAdContentRating)
    {
        layout = (FrameLayout)activity.getWindow().getDecorView().getRootView();
        this.isReal = isReal;
        this.isForChildDirectedTreatment = isForChildDirectedTreatment;
        this.maxAdContentRating = maxAdContentRating;
        if (maxAdContentRating != null && maxAdContentRating != "") {
            extras = new Bundle();
            extras.putString("max_ad_content_rating", maxAdContentRating);
        }
        Log.d(TAG, "AdMob: init with content rating options");
    }


    /**
     * Returns AdRequest object constructed considering the parameters set in constructor of this class.
     * @return AdRequest object
     */
    private AdRequest getAdRequest()
    {
        AdRequest.Builder adBuilder = new AdRequest.Builder();
        AdRequest adRequest;
        if (!this.isForChildDirectedTreatment && extras != null) {
            adBuilder.addNetworkExtrasBundle(AdMobAdapter.class, extras);
        }
        if (this.isForChildDirectedTreatment) {
            adBuilder.tagForChildDirectedTreatment(true);
        }
        if (!isReal) {
            adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
            adBuilder.addTestDevice(getAdmobDeviceId());
        }
        adRequest = adBuilder.build();
        return adRequest;
    }

    /* Rewarded Video
     * ********************************************************************** */
    private RewardedAd initRewardedVideo(final String id, final int callback_id)
    {
        RewardedAd rewardedAd = new RewardedAd(activity, id);
        RewardedAdLoadCallback adLoadCallback = new RewardedAdLoadCallback() {
                @Override
                public void onRewardedAdLoaded() {
                    // Ad successfully loaded.
                    Log.w(TAG, "AdMob: onRewardedVideoAdLoaded");
                    GodotLib.calldeferred(callback_id, "_on_rewarded_video_ad_loaded", new Object[] { id });
                }

                @Override
                public void onRewardedAdFailedToLoad(int errorCode) {
                    // Ad failed to load.
                    Log.w(TAG, "AdMob: onRewardedVideoAdFailedToLoad. errorCode: " + errorCode);
                    GodotLib.calldeferred(callback_id, "_on_rewarded_video_ad_failed_to_load", new Object[] { id, ""+errorCode });
                }
            };
        RewardedAdCallback adCallback = new RewardedAdCallback() {
                @Override
                public void onRewardedAdOpened() {
                    // Ad opened.
                    Log.w(TAG, "AdMob: onRewardedVideoAdOpened");
                    GodotLib.calldeferred(callback_id, "_on_rewarded_video_ad_opened", new Object[] { id });
                }

                @Override
                public void onRewardedAdClosed() {
                    // Ad closed.
                    Log.w(TAG, "AdMob: onRewardedVideoAdClosed");
                    GodotLib.calldeferred(callback_id, "_on_rewarded_video_ad_closed", new Object[] { id });
                }

                @Override
                public void onUserEarnedReward(RewardItem reward) {
                    // User earned reward.
                    Log.w(TAG, "AdMob: " + String.format(" onRewarded! currency: %s amount: %d", reward.getType(), reward.getAmount()));
                    GodotLib.calldeferred(callback_id, "_on_rewarded", new Object[] { id, reward.getType(), reward.getAmount() });
                }

                @Override
                public void onRewardedAdFailedToShow(int errorCode) {
                    // Ad failed to display.
                    Log.w(TAG, "AdMob: onRewardedVideoAdFailedToShow. errorCode: " + errorCode);
                    GodotLib.calldeferred(callback_id, "_on_rewarded_video_ad_failed_to_load", new Object[] { id, ""+errorCode });
                }
            };
        rewardedCallbacks.put(id, adCallback);
        rewardedAd.loadAd(getAdRequest(), adLoadCallback);
        return rewardedAd;
    }

    /**
     * Load a Rewarded Video
     * @param String id AdMod Rewarded video ID
     */
    public void loadRewardedVideo(final String id, final int callback_id) {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    RewardedAd rew = initRewardedVideo(id, callback_id);
                    rewardeds.put(id, rew);
                }
            });
    }

    /**
     * Show a Rewarded Video
     */
    public void showRewardedVideo(final String id) {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(rewardeds.containsKey(id)) {
                        RewardedAd r = rewardeds.get(id);
                        RewardedAdCallback cb = rewardedCallbacks.get(id);
                        if (r.isLoaded()) {
                            //r.show();
                            r.show(activity, cb);
                        } else {
                            Log.w(TAG, "AdMob: showRewardedVideo - rewarded not loaded");
                        }
                    }
                }
            });
    }


    /* Banner
     * ********************************************************************** */

    private AdSize getAdSize() {
        // Step 2 - Determine the screen width (less decorations) to use for the ad width.
        Display display = activity.getWindowManager().getDefaultDisplay();
        DisplayMetrics outMetrics = new DisplayMetrics();
        display.getMetrics(outMetrics);

        float widthPixels = outMetrics.widthPixels;
        float density = outMetrics.density;

        int adWidth = (int) (widthPixels / density);

        // Step 3 - Get adaptive ad size and return for setting on the ad view.
        return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(activity, adWidth);
    }

    private AdView initBanner(final String id, final boolean isOnTop, final int callback_id)
    {
        FrameLayout.LayoutParams adParams = new FrameLayout.LayoutParams(
                                                                         FrameLayout.LayoutParams.MATCH_PARENT,
                                                                         FrameLayout.LayoutParams.WRAP_CONTENT
                                                                         );
        if(isOnTop) adParams.gravity = Gravity.TOP;
        else adParams.gravity = Gravity.BOTTOM;
        bannerParams.put(id, adParams);
                
        AdView adView = new AdView(activity);
        adView.setAdUnitId(id);
        adView.setBackgroundColor(Color.TRANSPARENT);

        AdSize adSize = getAdSize();
        adView.setAdSize(adSize);
        //adView.setAdSize(AdSize.SMART_BANNER);
        adView.setAdListener(new AdListener() {
                @Override
                public void onAdLoaded() {
                    Log.w(TAG, "AdMob: onAdLoaded");
                    GodotLib.calldeferred(callback_id, "_on_banner_loaded", new Object[]{ id });
                }

                @Override
                public void onAdFailedToLoad(int errorCode)
                {
                    String str;
                    String callbackFunctionName = "_on_banner_failed_to_load";
                    switch(errorCode) {
                    case AdRequest.ERROR_CODE_INTERNAL_ERROR:
                        str = "ERROR_CODE_INTERNAL_ERROR";
                        break;
                    case AdRequest.ERROR_CODE_INVALID_REQUEST:
                        str = "ERROR_CODE_INVALID_REQUEST";
                        break;
                    case AdRequest.ERROR_CODE_NETWORK_ERROR:
                        str = "ERROR_CODE_NETWORK_ERROR";
                        callbackFunctionName = "_on_admob_network_error";
                        break;                              
                    case AdRequest.ERROR_CODE_NO_FILL:
                        str = "ERROR_CODE_NO_FILL";
                        break;
                    default:
                        str = "Code: " + errorCode;
                        break;
                    }
                    Log.w(TAG, "AdMob: onAdFailedToLoad -> " + str);
                    Log.w(TAG, "AdMob: callbackfunction -> " + callbackFunctionName);
                        
                    GodotLib.calldeferred(callback_id, callbackFunctionName, new Object[]{ id, str });
                }
            });

        return adView;
    }

    private void placeBannerOnScreen(final String id, final AdView banner)
    {
        FrameLayout.LayoutParams adParams = bannerParams.get(id);
        layout.addView(banner, adParams);
    }

    /**
     * Load a banner
     * @param String id AdMod Banner ID
     * @param boolean isOnTop To made the banner top or bottom
     */
    public void loadBanner(final String id, final boolean isOnTop, final int callback_id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(!banners.containsKey(id)) {
                        AdView b = initBanner(id, isOnTop, callback_id);
                        // Request
                        b.loadAd(getAdRequest());
                        banners.put(id, b);
                    } else {
                        AdView b = banners.get(id);
                        b.loadAd(getAdRequest());
                    }
                }
            });
    }

    /**
     * Show the banner
     */
    public void showBanner(final String id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(banners.containsKey(id)) {
                        AdView b = banners.get(id);
                        if(b.getParent() == null) {
                            placeBannerOnScreen(id, b);
                        }
                        //if (b.getVisibility() == View.VISIBLE) return;
                        b.setVisibility(View.VISIBLE);
                        b.resume();
                        for (String key : banners.keySet()) {
                            if(!key.equals(id)) {
                                AdView b2 = banners.get(key);
                                //if (b2.getVisibility() != View.GONE) {
                                b2.setVisibility(View.GONE);
                                b2.pause();
                                //}
                            }
                        }
                        Log.d(TAG, "AdMob: Show Banner");
                    } else {
                        Log.w(TAG, "AdMob: Banner not found: "+id);
                    }
                }
            });
    }

    public void removeBanner(final String id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(banners.containsKey(id)) {
                        AdView b = banners.get(id);
                        banners.remove(id);
                        layout.removeView(b); // Remove the banner
                        Log.d(TAG, "AdMob: Remove Banner");
                    } else {
                        Log.w(TAG, "AdMob: Banner not found: "+id);
                    }
                }
            });
    }

    /**
     * Hide the banner
     */
    public void hideBanner(final String id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(banners.containsKey(id)) {
                        AdView b = banners.get(id);
                        //if (b.getVisibility() == View.GONE) return;
                        b.setVisibility(View.GONE);
                        b.pause();
                        Log.d(TAG, "AdMob: Hide Banner");
                    } else {
                        Log.w(TAG, "AdMob: Banner not found: "+id);
                    }
                }
            });
    }

    /**
     * Get the banner width
     * @return int Banner width
     */
    public int getBannerWidth(final String id)
    {
        //return AdSize.SMART_BANNER.getWidthInPixels(activity);
        return getAdSize().getWidthInPixels(activity);
    }

    /**
     * Get the banner height
     * @return int Banner height
     */
    public int getBannerHeight(final String id)
    {
        //return AdSize.SMART_BANNER.getHeightInPixels(activity);
        return getAdSize().getHeightInPixels(activity);
    }

    public String makeZombieBanner(final String id)
    {
        if (banners.containsKey(id)) {
            AdView b = banners.get(id);
            String zid = java.util.UUID.randomUUID().toString();
            banners.remove(id);
            zombieBanners.put(zid, b);
            Log.i(TAG, "makeZombieBanner: OK");
            return zid;
        } else {
            Log.w(TAG, "makeZombieBanner: Banner not found: "+id);
            return "";
        }
    }

    public void killZombieBanner(final String zid)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if (zombieBanners.containsKey(zid)) {
                        View z = zombieBanners.get(zid);
                        zombieBanners.remove(zid);
                        layout.removeView(z); // Remove the zombie banner
                        Log.w(TAG, "killZombieBanner: OK");
                    } else {
                        Log.w(TAG, "killZombieBanner: Banner not found: "+zid);
                    }
                }
            });
    }


    /* Interstitial
     * ********************************************************************** */

    public InterstitialAd initInterstitial(final String id, final int callback_id)
    {
        InterstitialAd interstitialAd = new InterstitialAd(activity);
        interstitialAd.setAdUnitId(id);
        interstitialAd.setAdListener(new AdListener() {
                @Override
                public void onAdLoaded() {
                    Log.w(TAG, "AdMob: onAdLoaded");
                    GodotLib.calldeferred(callback_id, "_on_interstitial_loaded", new Object[] { id });
                }

                @Override
                public void onAdFailedToLoad(int errorCode) {
                    Log.w(TAG, "AdMob: onAdFailedToLoad(int errorCode) - error code: " + Integer.toString(errorCode));
                    Log.w(TAG, "AdMob: _on_interstitial_not_loaded");
                    GodotLib.calldeferred(callback_id, "_on_interstitial_failed_to_load", new Object[] { id, Integer.toString(errorCode) });
                }

                @Override
                public void onAdOpened() {
                    Log.w(TAG, "AdMob: onAdOpened()");
                }

                @Override
                public void onAdLeftApplication() {
                    Log.w(TAG, "AdMob: onAdLeftApplication()");
                }

                @Override
                public void onAdClosed() {
                    GodotLib.calldeferred(callback_id, "_on_interstitial_close", new Object[] { id });
                    Log.w(TAG, "AdMob: onAdClosed");
                }
            });

        interstitialAd.loadAd(getAdRequest());
        return interstitialAd;
    }

    /**
     * Load a interstitial
     * @param String id AdMod Interstitial ID
     */
    public void loadInterstitial(final String id, final int callback_id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    InterstitialAd interstitial = initInterstitial(id, callback_id);
                    interstitials.put(id, interstitial);
                }
            });
    }

    /**
     * Show the interstitial
     */
    public void showInterstitial(final String id)
    {
        activity.runOnUiThread(new Runnable() {
                @Override public void run() {
                    if(interstitials.containsKey(id)) {
                        InterstitialAd interstitial = interstitials.get(id);
                        if (interstitial.isLoaded()) {
                            interstitial.show();
                        } else {
                            Log.w(TAG, "AdMob: showInterstitial - interstitial not loaded");
                        }
                    }
                }
            });
    }

    /* Utils
     * ********************************************************************** */

    /**
     * Generate MD5 for the deviceID
     * @param String s The string to generate de MD5
     * @return String The MD5 generated
     */
    private String md5(final String s)
    {
        try {
            // Create MD5 Hash
            MessageDigest digest = MessageDigest.getInstance("MD5");
            digest.update(s.getBytes());
            byte messageDigest[] = digest.digest();

            // Create Hex String
            StringBuffer hexString = new StringBuffer();
            for (int i=0; i<messageDigest.length; i++) {
                String h = Integer.toHexString(0xFF & messageDigest[i]);
                while (h.length() < 2) h = "0" + h;
                hexString.append(h);
            }
            return hexString.toString();
        } catch(NoSuchAlgorithmException e) {
            //Logger.logStackTrace(TAG,e);
        }
        return "";
    }

    /**
     * Get the Device ID for AdMob
     * @return String Device ID
     */
    private String getAdmobDeviceId()
    {
        String android_id = Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
        String deviceId = md5(android_id).toUpperCase(Locale.US);
        return deviceId;
    }

    /* Definitions
     * ********************************************************************** */

    public AdMob(Godot godot) 
    {
        super(godot);
        activity = godot;
    }

    @Override
    public String getPluginName() {
        return "AdMob";
    }

    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList(
                             "init", "initWithContentRating",
                             // banner
                             "loadBanner", "showBanner", "hideBanner", "removeBanner", "getBannerWidth", "getBannerHeight",
                             "makeZombieBanner", "killZombieBanner",
                             // Interstitial
                             "loadInterstitial", "showInterstitial",
                             // Rewarded video
                             "loadRewardedVideo", "showRewardedVideo"
                             );
    }

    /*
    @Override
    public Set<SignalInfo> getPluginSignals() {
        return Collections.singleton(loggedInSignal);
    }
    */

    @Override
    public View onMainCreateView(Activity activity) {
        return null;
    }
}
