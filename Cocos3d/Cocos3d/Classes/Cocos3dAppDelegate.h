/**
 *  Cocos3dAppDelegate.h
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "CC3UIViewController.h"

@interface Cocos3dAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* _window;
	CC3DeviceCameraOverlayUIViewController* _viewController;
    
    float _wGx;
    float _wGy;
}

@property (nonatomic, assign) float wGx;
@property (nonatomic, assign) float wGy;

@end
