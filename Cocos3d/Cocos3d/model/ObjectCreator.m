//
//  ObjectCreator.m
//  Cocos3d
//
//  Created by Yuhua Mai on 11/11/13.
//  Copyright (c) 2013 Yuhua Mai. All rights reserved.
//

#if __cplusplus
extern "C" {
#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#endif

#import "ObjectCreator.h"

#import "CC3MeshNode.h"
#import "CC3ActionInterval.h"
#import "CC3PODResourceNode.h"


#import "CC3Camera.h"
#import "CC3Light.h"


#import "CC3ControllableLayer.h"

#import "CC3ShaderProgram.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3UtilityMeshNodes.h"

#import "ccTypes.h"

#import "CCPhysicsSprite.h"

#import "b2Body.h"




@implementation ObjectCreator

- (void)addEarth:(CC3Scene*)scene
{
    [scene addContentFromPODFile:@"earth.pod" withName:@"earth"];
    
    CC3MeshNode* earth = (CC3MeshNode*)[scene getNodeNamed: @"earth"];
    [earth setLocation:cc3v(0.0, 100.0, 0.0)];
    [earth setRotation:cc3v(-20.0, 0.0, 0.0)];
    //    [earth translateBy:cc3v(100.0, 0.0, 0.0)];
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                          rotateBy: cc3v(0.0, 30.0, 0.0)];
    [earth runAction: [CCRepeatForever actionWithAction: partialRot]];
    [scene addChild:earth];
    
    // Create the camera, place it back a bit, and add it to the world
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 3.0 );
	[earth addChild: cam];
    
    // Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the world
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 3.0 );
	lamp.isDirectionalOnly = NO;
	[earth addChild: lamp];
    
    
    //create earth body
    b2BodyDef earthBodyDef;
    earthBodyDef.type = b2_dynamicBody;
    //    earthBodyDef.position.Set(0.0, 10.0);
    earthBodyDef.position.Set(0, 100);
    earthBodyDef.userData = earth;
    earthBodyDef.linearVelocity = b2Vec2(0.0f, 0.0f);
    earthBody = _world->CreateBody(&earthBodyDef);
    
    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = 15; //not sure what the earth raidus is
    
    // Create shape definition and add to body
    b2FixtureDef earthShapeDef;
    earthShapeDef.shape = &circle;
    earthShapeDef.density = 0.0f;
    earthShapeDef.friction = 0.2f;
    earthShapeDef.restitution = 0.35f;
    earthShapeDef.isSensor = FALSE;
    _earthFixture = earthBody->CreateFixture(&earthShapeDef);
}

@end
