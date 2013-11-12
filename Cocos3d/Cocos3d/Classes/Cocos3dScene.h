/**
 *  Cocos3dScene.h
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */


#import "CC3Scene.h"
#import "CC3UtilityMeshNodes.h"

#import "Box2D.h"
#import "Cocos3dAppDelegate.h"
#import "Models.h"

/** Enumeration of camera zoom options. */
typedef enum {
	kCameraZoomNone,			/**< Inside the scene. */
	kCameraZoomStraightBack,	/**< Zoomed straight out to view complete scene. */
	kCameraZoomBackTopRight,	/**< Zoomed out to back top right view of complete scene. */
} CameraZoomType;

/** Enumeration of lighting options. */
typedef enum {
	kLightingSun,				/**< Sunshine. */
	kLightingFog,				/**< Sunshine with fog. */
	kLightingFlashlight,		/**< Nightime with flashlight. */
	kLightingGrayscale,			/**< Sunshine with grayscale post-processing filter. */
	kLightingDepth,				/**< Display the depth buffer using a post-processing filter. */
} LightingType;

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
    
    
    CC3PlaneNode* _ground;
    
    //camera & light
    CC3Node* _origCamTarget;
	CC3Node* _camTarget;
	CameraZoomType _cameraZoomType;
    LightingType _lightingType;
	BOOL _isManagingShadows : 1;
    
    CC3Camera* _robotCam;
	CC3Light* _robotLamp;


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



- (void)gyroscope : (double)roll andPitch:(double)pitch andYaw:(double)yaw;
-(void) switchCameraTarget;
-(void) cycleZoom;

@end
