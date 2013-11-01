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
	b2Fixture* _ballFixture;

    double previousTime;
    double deltaTime;
}

@end
