#include "godotAdmob.h"
#include "core/globals.h"
#include "core/variant.h"
#include "core/message_queue.h"

#import <GoogleMobileAds/GADRequest.h>
#import <UIKit/UIKit.h>

#import "app_delegate.h"


#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADInterstitial.h>


GodotAdmob* instance = NULL;
GADBannerView *bannerView_ = nil;
GADInterstitial *interstitial = nil;
ViewController *root_controller = nil;

GodotAdmob::GodotAdmob() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    isReal = false;
}

GodotAdmob::~GodotAdmob() {
    instance = NULL;
}

void GodotAdmob::init(bool isReal, int instanceId) {
    this->isReal = isReal;
    this->instanceId = instanceId;
    root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
}


void GodotAdmob::loadBanner(const String &bannerId, bool isOnTop) {
    NSLog(@"Calling loadBanner");
    if (bannerView_ != nil) {
        return;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
    if(!isReal) {
        bannerView_.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    }
    else {
        bannerView_.adUnitID = [NSString stringWithCString:bannerId.utf8().get_data() encoding:NSUTF8StringEncoding];
    }
        
    NSLog(@"adUnitID: %@", bannerView_.adUnitID);
        

    bannerView_.rootViewController = root_controller;
        
        
    GADRequest *request = [GADRequest request];
        
    request.testDevices = @[ kGADSimulatorID ];
    [bannerView_ loadRequest:request];
        
    if(!isOnTop) {
        //TODO: pegar largura e altura daqui
        float height = root_controller.view.frame.size.height;
        float width = root_controller.view.frame.size.width;
        NSLog(@"height: %f, width: %f", height, width);
        [bannerView_ setFrame:CGRectMake(0, height-bannerView_.bounds.size.height, bannerView_.bounds.size.width, bannerView_.bounds.size.height)];
    }
        
    [root_controller.view addSubview:bannerView_];
    
    
}

void GodotAdmob::showBanner() {
    NSLog(@"Calling showBanner");
    if (bannerView_ == nil) {
        return;
    }
    
    [bannerView_ setHidden:NO];
}

void GodotAdmob::hideBanner() {
    NSLog(@"Calling hideBanner");
    [bannerView_ setHidden:YES];
}


void GodotAdmob::loadInterstitial(const String &interstitialId) {
    
    NSLog(@"Calling loadInterstitial");
    //init
    interstitial = [[GADInterstitial alloc]
                    initWithAdUnitID:[NSString stringWithCString:interstitialId.utf8().get_data() encoding:NSUTF8StringEncoding]];
    
    //load
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
}

void GodotAdmob::showInterstitial() {
    NSLog(@"Calling showInterstitial");
    //show
    
    if (interstitial.isReady) {
        [interstitial presentFromRootViewController:root_controller];
    } else {
        NSLog(@"Interstitial Ad wasn't ready");
    }
    
    
}

void GodotAdmob::_bind_methods() {
    ObjectTypeDB::bind_method("init",&GodotAdmob::init);
    ObjectTypeDB::bind_method("loadBanner",&GodotAdmob::loadBanner);
    ObjectTypeDB::bind_method("showBanner",&GodotAdmob::showBanner);
    ObjectTypeDB::bind_method("hideBanner",&GodotAdmob::hideBanner);
    ObjectTypeDB::bind_method("loadInterstitial",&GodotAdmob::loadInterstitial);
    ObjectTypeDB::bind_method("showInterstitial",&GodotAdmob::showInterstitial);
}
