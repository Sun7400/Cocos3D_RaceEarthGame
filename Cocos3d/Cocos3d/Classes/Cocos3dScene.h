/**
 *  Cocos3dScene.h
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */


#import "CC3Scene.h"

#import "Box2D.h"
#import "Cocos3dAppDelegate.h"

/** A sample application-specific CC3Scene subclass.*/
@interface Cocos3dScene : CC3Scene {
    
    // Box2d
	b2World* _world;
	b2Fixture* _earthFixture;
    b2Fixture* _ballFixture;

    double previousTime;
    double deltaTime;
    
    CCTexture2D *spriteTexture_;	// weak ref

    
    //joystick
    CGPoint _playerDirectionControl;
	CGPoint _playerLocationControl;
}

/**
 * This property controls the velocity of the change in direction of the 3D camera
 * (a proxy for the player). This property is set by the CC3Layer, from the velocity
 * of the corresponding joystick control.
 *
 * The initial value of this property is CGPointZero.
 */
@property(nonatomic, assign) CGPoint playerDirectionControl;

/**
 * This property controls the velocity of the change in location of the 3D camera
 * (a proxy for the player). This property is set by the CC3Layer, from the velocity
 * of the corresponding joystick control.
 *
 * The initial value of this property is CGPointZero.
 */
@property(nonatomic, assign) CGPoint playerLocationControl;

@end
