package org.godotengine.godot;

import com.google.android.gms.ads.*;


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

public class GodotAdMob extends Godot.SingletonBase
{
	private Activity activity = null; // The main activity of the game
	private int instance_id = 0;

	private InterstitialAd interstitialAd = null; // Interstitial object
	private AdView adView = null; // Banner view

	private boolean isReal = false; // Store if is real or not

	private FrameLayout layout = null; // Store the layout
	private FrameLayout.LayoutParams adParams = null; // Store the layout params

	/* Init
	 * ********************************************************************** */

	/**
	 * Prepare for work with AdMob
	 * @param boolean isReal Tell if the enviroment is for real or test
	 */
	public void init(boolean isReal, int instance_id)
	{
		this.isReal = isReal;
		this.instance_id = instance_id;
		Log.d("godot", "AdMob: init");
	}

	/* Banner
	 * ********************************************************************** */

	/**
	 * Load a banner
	 * @param String id AdMod Banner ID
	 * @param boolean isOnTop To made the banner top or bottom
	 */
	public void loadBanner(final String id, final boolean isOnTop)
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				layout = ((Godot) activity).layout;
				adParams = new FrameLayout.LayoutParams(
					FrameLayout.LayoutParams.MATCH_PARENT,
					FrameLayout.LayoutParams.WRAP_CONTENT
				);
				if(isOnTop) adParams.gravity = Gravity.TOP;
				else adParams.gravity = Gravity.BOTTOM;

				adView = new AdView(activity);
				adView.setAdUnitId(id);

				adView.setBackgroundColor(Color.TRANSPARENT);

				adView.setAdSize(AdSize.SMART_BANNER);
				adView.setAdListener(new AdListener()
				{
					@Override
					public void onAdLoaded() {
						Log.w("godot", "AdMob: onAdLoaded");
						GodotLib.calldeferred(instance_id, "_on_admob_ad_loaded", new Object[]{ });
					}

					@Override
					public void onAdFailedToLoad(int errorCode)
					{
						String	str;
						switch(errorCode) {
							case AdRequest.ERROR_CODE_INTERNAL_ERROR:
								str	= "ERROR_CODE_INTERNAL_ERROR";
								break;
							case AdRequest.ERROR_CODE_INVALID_REQUEST:
								str	= "ERROR_CODE_INVALID_REQUEST";
								break;
							case AdRequest.ERROR_CODE_NETWORK_ERROR:
								str	= "ERROR_CODE_NETWORK_ERROR";
								GodotLib.calldeferred(instance_id, "_on_admob_network_error", new Object[]{ });
								break;
							case AdRequest.ERROR_CODE_NO_FILL:
								str	= "ERROR_CODE_NO_FILL";
								break;
							default:
								str	= "Code: " + errorCode;
								break;
						}
						Log.w("godot", "AdMob: onAdFailedToLoad -> " + str);
					}
				});
				layout.addView(adView, adParams);

				// Request
				AdRequest.Builder adBuilder = new AdRequest.Builder();
				adBuilder.tagForChildDirectedTreatment(true);
				if (!isReal) {
					adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
					adBuilder.addTestDevice(getAdmobDeviceId());
				}
				adView.loadAd(adBuilder.build());
			}
		});
	}

	/**
	 * Show the banner
	 */
	public void showBanner()
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (adView.getVisibility() == View.VISIBLE) return;
				adView.setVisibility(View.VISIBLE);
				adView.resume();
				Log.d("godot", "AdMob: Show Banner");
			}
		});
	}

	/**
	 * Resize the banner
	 *
	 */
	public void resize()
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				layout.removeView(adView); // Remove the old view

				// Extract params

				int gravity = adParams.gravity;
				FrameLayout	layout = ((Godot)activity).layout;
				adParams = new FrameLayout.LayoutParams(
					FrameLayout.LayoutParams.MATCH_PARENT,
					FrameLayout.LayoutParams.WRAP_CONTENT
				);
				adParams.gravity = gravity;
				AdListener adListener = adView.getAdListener();
				String id = adView.getAdUnitId();

				// Create new view & set old params
				adView = new AdView(activity);
				adView.setAdUnitId(id);
				adView.setBackgroundColor(Color.TRANSPARENT);
				adView.setAdSize(AdSize.SMART_BANNER);
				adView.setAdListener(adListener);

				// Add to layout and load ad
				layout.addView(adView, adParams);

				// Request
				AdRequest.Builder adBuilder = new AdRequest.Builder();
				adBuilder.tagForChildDirectedTreatment(true);
				if (!isReal) {
					adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
					adBuilder.addTestDevice(getAdmobDeviceId());
				}
				adView.loadAd(adBuilder.build());

				Log.d("godot", "AdMob: Banner Resized");
			}
		});
	}

	/**
	 * Hide the banner
	 */
	public void hideBanner()
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (adView.getVisibility() == View.GONE) return;
				adView.setVisibility(View.GONE);
				adView.pause();
				Log.d("godot", "AdMob: Hide Banner");
			}
		});
	}

	/**
	 * Get the banner width
	 * @return int Banner width
	 */
	public int getBannerWidth()
	{
		return AdSize.SMART_BANNER.getWidthInPixels(activity);
	}

	/**
	 * Get the banner height
	 * @return int Banner height
	 */
	public int getBannerHeight()
	{
		return AdSize.SMART_BANNER.getHeightInPixels(activity);
	}

	/* Interstitial
	 * ********************************************************************** */

	/**
	 * Load a interstitial
	 * @param String id AdMod Interstitial ID
	 */
	public void loadInterstitial(final String id)
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				interstitialAd = new InterstitialAd(activity);
				interstitialAd.setAdUnitId(id);
		        interstitialAd.setAdListener(new AdListener()
				{
					@Override
					public void onAdLoaded() {
						Log.w("godot", "AdMob: onAdLoaded");
						GodotLib.calldeferred(instance_id, "_on_interstitial_loaded", new Object[] { });
					}

					@Override
					public void onAdClosed() {
						GodotLib.calldeferred(instance_id, "_on_interstitial_close", new Object[] { });

						AdRequest.Builder adBuilder = new AdRequest.Builder();
						adBuilder.tagForChildDirectedTreatment(true);
						if (!isReal) {
							adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
							adBuilder.addTestDevice(getAdmobDeviceId());
						}
						interstitialAd.loadAd(adBuilder.build());

						Log.w("godot", "AdMob: onAdClosed");
					}
				});

				AdRequest.Builder adBuilder = new AdRequest.Builder();
				adBuilder.tagForChildDirectedTreatment(true);
				if (!isReal) {
					adBuilder.addTestDevice(AdRequest.DEVICE_ID_EMULATOR);
					adBuilder.addTestDevice(getAdmobDeviceId());
				}

				interstitialAd.loadAd(adBuilder.build());
			}
		});
	}

	/**
	 * Show the interstitial
	 */
	public void showInterstitial()
	{
		activity.runOnUiThread(new Runnable()
		{
			@Override public void run()
			{
				if (interstitialAd.isLoaded()) {
					interstitialAd.show();
				} else {
					Log.w("godot", "AdMob: _on_interstitial_not_loaded");
					GodotLib.calldeferred(instance_id, "_on_interstitial_not_loaded", new Object[] { });
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

	/**
	 * Initilization Singleton
	 * @param Activity The main activity
	 */
 	static public Godot.SingletonBase initialize(Activity activity)
 	{
 		return new GodotAdMob(activity);
 	}

	/**
	 * Constructor
	 * @param Activity Main activity
	 */
	public GodotAdMob(Activity p_activity) {
		registerClass("AdMob", new String[] {
			"init",
			"loadBanner", "showBanner", "hideBanner", "getBannerWidth", "getBannerHeight", "resize",
			"loadInterstitial", "showInterstitial"
		});
		activity = p_activity;
	}
}
