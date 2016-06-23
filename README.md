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

Recompile.


In Example project goto Export->Target->Android:

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

If you have more separete by comma.

API Reference
-------------

The following methods are available:

	void init(boolean isReal)
		isReal: show real ad or test ad
	
	void showBanner(String id, boolean isTop)
		id: banner unit id
		isTop: banner is top of screen or buttom
	
	void showBanner()
	void hideBanner()

	void loadInterstitial(String id)
		id: banner unit id

	void showInterstitial()

	int getAdWidth()
	int getAdHeight()

License
-------------
MIT license
	
