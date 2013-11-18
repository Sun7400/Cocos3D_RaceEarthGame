/**
 *  Cocos3dLayer.h
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */


#import "CC3Layer.h"
#import <CoreMotion/CoreMotion.h>

#import "Joystick.h"


/** A sample application-specific CC3Layer subclass. */
@interface Cocos3dLayer : CC3Layer {
    Joystick* directionJoystick;
	Joystick* locationJoystick;
}

- (void)updateLabel;
- (void)gameWin;

@end
