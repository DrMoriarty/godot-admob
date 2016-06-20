extends Node

var admob = null
var isReal = true
var isTop = true
var ad_id = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX" # [Replace with your Ad Unit ID and delete this message.]

func _ready():
	if(Globals.has_singleton("AdMob")):
		admob = Globals.get_singleton("AdMob")
		admob.init(isReal)
		admob.loadBanner(ad_id, isTop)
	
