AdMob
=====
This is the AdMob module for Godot Engine (https://github.com/okamstudio/godot)
- Android only
- Banner
- Interstitial
 
How to use
----------
Drop the "admob" directory inside the "modules" directory on the Godot source.

~~Move file GodotAdMob.java from "admob/android/" to "platform/android/java/src/org/godotengine/godot/".~~

Recompile android export template (For documentation: http://docs.godotengine.org/en/latest/reference/compiling_for_android.html#compiling-export-templates).


In Example project goto Export > Target > Android:

	Options:
		Custom Package:
			- place your apk from build
		Permissions on:
			- Access Network State
			- Internet

Configuring your game
---------------------

To enable the module on Android, add the path to the module to the "modules" property on the [android] section of your engine.cfg file. It should look like this:

	[android]
	modules="org/godotengine/godot/GodotAdMob"

If you have more separate by comma.

API Reference
-------------

The following methods are available:
```python

# Init AdMob
# @param bool isReal Show real ad or test ad
# @param int instance_id The instance id from Godot (get_instance_ID())
init(isReal, instance_id)

# Callback for Ad Loaded
_on_admob_ad_loaded()

# Callback for Network error
_on_admob_network_error()

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
getAdWidth()

# Get the Banner height
# @return int Banner height
getAdHeight()

# Interstitial Methods
# --------------------

# Load Interstitial Ads
# @param String id The interstitial unit id
loadInterstitial(id)

# Show the interstitial ad
showInterstitial()

# Callback for insterstitial ad close action
_on_interstitial_close()
```

References
-------------
Based on the work of:
* https://github.com/Mavhod/GodotAdmob

License
-------------
MIT license


