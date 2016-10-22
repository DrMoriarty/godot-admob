extends Node2D

var admob = null
var isReal = false
var isTop = true
var adBannerId = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" # [Replace with your Ad Unit ID and delete this message.]
var adInterstitialId = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" # [Replace with your Ad Unit ID and delete this message.]

func _ready():
	if(Globals.has_singleton("AdMob")):
		admob = Globals.get_singleton("AdMob")
		admob.init(isReal, get_instance_ID())
		loadBanner()
		loadInterstitial()
	
	get_tree().connect("screen_resized", self, "onResize")

# Loaders

func loadBanner():
	if admob != null:
		admob.loadBanner(adBannerId, isTop)

func loadInterstitial():
	if admob != null:
		admob.loadInterstitial(adInterstitialId)

# Events

func _on_BtnBanner_toggled(pressed):
	if admob != null:
		if pressed: admob.showBanner()
		else: admob.hideBanner()

func _on_BtnInterstitial_pressed():
	if admob != null:
		admob.showInterstitial()

func _on_admob_network_error():
	print("Network Error")

func _on_admob_ad_loaded():
	print("Ad loaded success")
	get_node("CanvasLayer/BtnBanner").set_disabled(false)

func _on_interstitial_not_loaded():
	print("Error: Interstitial not loaded")

func _on_interstitial_loaded():
	print("Interstitial loaded")
	get_node("CanvasLayer/BtnInterstitial").set_disabled(false)

func _on_interstitial_close():
	print("Interstitial closed")
	get_node("CanvasLayer/BtnInterstitial").set_disabled(true)

# Resize

func onResize():
	if admob != null:
		admob.resize()

