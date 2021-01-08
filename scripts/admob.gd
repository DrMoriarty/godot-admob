extends Node2D

var _ads = null
onready var Production = not OS.is_debug_build()

func _ready():
    pause_mode = Node.PAUSE_MODE_PROCESS
    if(Engine.has_singleton("AdMob")):
        _ads = Engine.get_singleton("AdMob")
        _ads.init(Production)

# Loaders

func loadBanner(id: String, isTop: bool, callback_id: int) -> bool:
    if _ads != null:
        _ads.loadBanner(id, isTop, callback_id)
        return true
    else:
        return false

func loadInterstitial(id: String, callback_id: int) -> bool:
    if _ads != null:
        _ads.loadInterstitial(id, callback_id)
        return true
    else:
        return false
        
func loadRewardedVideo(id: String, callback_id: int) -> bool:
    if _ads != null:
        _ads.loadRewardedVideo(id, callback_id)
        return true
    else:
        return false

# Check state

func bannerWidth(id: String) -> int:
    if _ads != null:
        return _ads.getBannerWidth(id)
    else:
        return 0

func bannerHeight(id: String) -> int:
    if _ads != null:
        return _ads.getBannerHeight(id)
    else:
        return 0

# Control

func showBanner(id: String) -> bool:
    if _ads != null:
        _ads.showBanner(id)
        return true
    else:
        return false

func hideBanner(id: String) -> bool:
    if _ads != null:
        _ads.hideBanner(id)
        return true
    else:
        return false

func removeBanner(id: String) -> bool:
    if _ads != null:
        _ads.removeBanner(id)
        return true
    else:
        return false

func showInterstitial(id: String) -> bool:
    if _ads != null:
        _ads.showInterstitial(id)
        return true
    else:
        return false

func showRewardedVideo(id: String) -> bool:
    if _ads != null:
        _ads.showRewardedVideo(id)
        return true
    else:
        return false

func makeZombieBanner(id: String) -> String:
    if _ads != null:
        return _ads.makeZombieBanner(id)
    else:
        return ""

func killZombieBanner(id: String) -> void:
    if _ads != null:
        _ads.killZombieBanner(id)
