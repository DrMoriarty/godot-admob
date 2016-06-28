extends Node

var admob = null
var isReal = true
var isTop = true
var adId = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" # [Replace with your Ad Unit ID and delete this message.]

func _ready():
	if(Globals.has_singleton("AdMob")):
		admob = Globals.get_singleton("AdMob")
		admob.init(isReal, get_instance_ID())
	
func loadBanner():
	if admob != null:
		admob.loadBanner(adId, isTop)
		get_tree().connect("screen_resized", self, "onResize")

func onResize():
	if admob != null:
		admob.resize()

func _on_admob_network_error():
	print("Network Error")

func _on_admob_ad_loaded():
	print("Ad loaded success")
