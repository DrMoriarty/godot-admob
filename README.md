AdMob
=====
This is the AdMob module for Godot Engine (https://github.com/okamstudio/godot)
- Android & iOS
- Banner
- Interstitial
- Rewarded Video

How to use
----------

### Android
Drop the "admob" directory inside the "modules" directory on the Godot source.

Recompile android export template (For documentation: http://docs.godotengine.org/en/latest/reference/compiling_for_android.html#compiling-export-templates).


In Example project goto Export > Target > Android:

	Options:
		Custom Package:
			- place your apk from build
		Permissions on:
			- Access Network State
			- Internet
### iOS
- Drop the "admob" directory inside the "modules" directory on the Godot source;
- Download and extract the [Google Mobile Ads SDK](https://developers.google.com/admob/ios/download) inside the directory "admob/ios/lib";
- Recompile the iOS export template (For documentation: http://docs.godotengine.org/en/stable/development/compiling/compiling_for_ios.html).

Configuring your game
---------------------

### Android
To enable the module on Android, add the path to the module to the "modules" property on the [android] section of your  ```engine.cfg``` file (Godot 2) or ```project.godot``` (Godot 3). It should look like this:

	[android]
	modules="org/godotengine/godot/GodotAdMob"

If you have more separate by comma.

### iOS
Follow the [exporting to iOS official documentation](http://docs.godotengine.org/en/stable/learning/workflow/export/exporting_for_ios.html).

#### Godot 2
Just make sure you're using your custom template (compiled in the previous step), for that  rename it to "godot_opt.iphone" and replace the file with same name inside the Xcode project.

#### Godot 3
- Export your project from Godot, it'll create an Xcode project;
- Copy the library (.a) you have compiled following the official documentation inside the exported Xcode project. You must override the 'your_project_name.a' file with this file.
- Copy the GoogleMobileAds.framwork inside the exported Xcode project folder and link it using the "Link Binary with Libraries" option;
- Add the following frameworks to the project:
	- StoreKit
	- GameKit
	- CoreVideo
	- AdSupport
	- MessageUI
	- CoreTelephony
	- CFNetwork
	- MobileCoreServices

API Reference (Android & iOS)
-------------

The following methods are available:
```python

# Init AdMob
# @param bool isReal Show real ad or test ad
# @param int instance_id The instance id from Godot (get_instance_ID())
init(isReal, instance_id)

# Banner Methods
# --------------

# Load Banner Ads (and show inmediatly)
# @param String id The banner unit id
# @param boolean isTop Show the banner on top or bottom
loadBanner(id, isTop)

# Show the banner
showBanner()

# Hide the banner
hideBanner()

# Resize the banner (when orientation change for example)
resize()

# Get the Banner width
# @return int Banner width
getBannerWidth()

# Get the Banner height
# @return int Banner height
getBannerHeight()

# Callback on ad loaded (Banner)
_on_admob_ad_loaded()

# Callback on ad network error (Banner)
_on_admob_network_error()

# Interstitial Methods
# --------------------

# Load Interstitial Ads
# @param String id The interstitial unit id
loadInterstitial(id)

# Show the interstitial ad
showInterstitial()

# Callback for interstitial ad fail on load
_on_interstitial_not_loaded()

# Callback for interstitial loaded
_on_interstitial_loaded

# Callback for insterstitial ad close action
_on_interstitial_close()

# Rewarded Videos Methods
# -----------------------

# Load rewarded videos ads
# @param String id The rewarded video unit id
loadRewardedVideo(id)

# Show the rewarded video ad
showRewardedVideo()

# Callback for rewarded video ad left application
_on_rewarded_video_ad_left_application()

# Callback for rewarded video ad closed 
_on_rewarded_video_ad_closed()

# Callback for rewarded video ad failed to load
# @param int errorCode the code of error
_on_rewarded_video_ad_failed_to_load(errorCode)

# Callback for rewarded video ad loaded
_on_rewarded_video_ad_loaded()

# Callback for rewarded video ad opened
_on_rewarded_video_ad_opened()

# Callback for rewarded video ad reward user
# @param String currency The reward item description, ex: coin
# @param int amount The reward item amount
_on_rewarded(currency, amount)

# Callback for rewarded video ad started do play
_on_rewarded_video_started()
```

References
-------------
Based on the work of:
* https://github.com/Mavhod/GodotAdmob

License
-------------
MIT license
