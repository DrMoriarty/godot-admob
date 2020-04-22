#import "AdmobBanner.h"
#include "reference.h"

@implementation AdmobBanner

- (void)dealloc {
    bannerView.delegate = nil;
    [bannerView release];
    [super dealloc];
}

- (void)initialize:(BOOL)is_real callbackId:(int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = [AppDelegate getViewController];
}

-(NSString*)unitId {
    return adUnitId;
}

- (void) loadBanner:(NSString*)bannerId top:(BOOL)is_on_top {
    NSLog(@"Calling loadBanner");
    
    isOnTop = is_on_top;
    adUnitId = bannerId;
    
    if (!initialized) {
        return;
    }
    

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (bannerView == nil) {
        if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) { //portrait
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else { //landscape
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        }
        
        if(!isReal) {
            bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        }
        else {
            bannerView.adUnitID = bannerId;
        }

        bannerView.delegate = self;
        bannerView.rootViewController = rootController;
        

        [self addBannerViewToView:bannerView top:is_on_top];
    }
    CGRect frame = rootController.view.frame;
    if (@available(iOS 11.0, *)) {
        frame = UIEdgeInsetsInsetRect(frame, rootController.view.safeAreaInsets);
    }
    CGFloat viewWidth = frame.size.width;
    bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
    
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
    
}


- (void)addBannerViewToView:(UIView *_Nonnull)bv top:(BOOL)is_on_top{
    bv.translatesAutoresizingMaskIntoConstraints = NO;
    [rootController.view addSubview:bv];
    if (@available(ios 11.0, *)) {
        [self positionBannerViewFullWidthAtSafeArea:bv top:is_on_top];
    } else {
        [self positionBannerViewFullWidthAtView:bv top:is_on_top];
    }
}


- (void)positionBannerViewFullWidthAtSafeArea:(UIView *_Nonnull)bv top:(BOOL)is_on_top  NS_AVAILABLE_IOS(11.0) {
    UILayoutGuide *guide = rootController.view.safeAreaLayoutGuide;
    
    if (is_on_top) {
        [NSLayoutConstraint activateConstraints:@[
            [guide.leftAnchor constraintEqualToAnchor:bv.leftAnchor],
            [guide.rightAnchor constraintEqualToAnchor:bv.rightAnchor],
            [guide.topAnchor constraintEqualToAnchor:bv.topAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [guide.leftAnchor constraintEqualToAnchor:bv.leftAnchor],
            [guide.rightAnchor constraintEqualToAnchor:bv.rightAnchor],
            [guide.bottomAnchor constraintEqualToAnchor:bv.bottomAnchor]
        ]];
    }
}


- (void)positionBannerViewFullWidthAtView:(UIView *_Nonnull)bv top:(BOOL)is_on_top {
    
    [rootController.view addConstraint:[NSLayoutConstraint constraintWithItem:bv
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:rootController.view
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1
                                                                     constant:0]];
    [rootController.view addConstraint:[NSLayoutConstraint constraintWithItem:bv
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:rootController.view
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:0]];
    
    if (is_on_top) {
        [rootController.view addConstraint:[NSLayoutConstraint constraintWithItem:bv
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:rootController.topLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:0]];
        
    } else {
        [rootController.view addConstraint:[NSLayoutConstraint constraintWithItem:bv
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:rootController.bottomLayoutGuide
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0]];
    }
}

- (void)showBanner {
    NSLog(@"Calling showBanner");
    
    if (bannerView == nil || !initialized) {
        return;
    }
    
    [bannerView setHidden:NO];
}

- (void) hideBanner {
    NSLog(@"Calling hideBanner");
    if (bannerView == nil || !initialized) {
        return;
    }
    [bannerView setHidden:YES];
}
- (void) disableBanner {
    NSLog(@"Calling disableBanner");
    if (bannerView == nil || !initialized) {
        return;
    }
 
    [bannerView setHidden:YES];
    [bannerView removeFromSuperview];
    adUnitId = bannerView.adUnitID;
    bannerView = nil;
}
 
- (void) enableBanner {
    NSLog(@"Calling enableBanner");
    if (!initialized) {
        return;
    }
 
    if (bannerView == nil) {
        [self loadBanner:adUnitId top:isOnTop];
    }
    [bannerView setHidden:YES];
}

- (void) resize {
    NSLog(@"Calling resize");
    NSString* currentAdUnitId = bannerView.adUnitID;
    [self hideBanner];
    [bannerView removeFromSuperview];
    bannerView = nil;
    [self loadBanner:currentAdUnitId top:isOnTop];
}

- (int) getBannerWidth {
    return bannerView.bounds.size.width;
}

- (int) getBannerHeight {
    return bannerView.bounds.size.height;
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_banner_loaded", adUnitId);
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_banner_failed_to_load", adUnitId, error.localizedDescription);
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end
