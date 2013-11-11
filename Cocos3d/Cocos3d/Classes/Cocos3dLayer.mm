/**
 *  Cocos3dLayer.m
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */

#import "Cocos3dLayer.h"
#import "Cocos3dScene.h"

#import "CCNodeAdornments.h"


/** Parameters for setting up the joystick and button controls */
#define kJoystickThumbFileName			@"JoystickThumb.png"
#define kJoystickSideLength				80.0
#define kJoystickPadding				8.0


@interface Cocos3dLayer()
{
    AdornableMenuItemImage* switchViewMI;
    AdornableMenuItemImage* shadowMI;
	AdornableMenuItemImage* zoomMI;
	AdornableMenuItemImage* invasionMI;
	AdornableMenuItemImage* sunlightMI;
}

@property (nonatomic, retain) CMMotionManager *motionManager;

@end

@implementation Cocos3dLayer

@synthesize motionManager = _motionManager;

-(void) dealloc {
    [super dealloc];
}

/**
 * Returns the contained CC3Scene, cast into the appropriate type.
 * This is a convenience method to perform automatic casting.
 */
-(Cocos3dScene*) cocos3dScene {
    return (Cocos3dScene*) self.cc3Scene;
}

/**
 * Override to set up your 2D controls and other initial state, and to initialize update processing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
	// Set the touchEnabled property to NO to control the scene using iOS gestures,
	// and to YES to control the scene using lower-level touch events.
	self.touchEnabled = YES;
    self.mouseEnabled = YES;	// Under OSX, use mouse events since gestures are not supported.
    
	[self addJoysticks];
    [self addSwitchViewButton];
    
    //set up gyroscope
    [self initializeDeviceMotion];

	[self scheduleUpdate];   // Schedule updates on each frame
}





/** Creates the two joysticks that control the 3D camera direction and location. */
-(void) addJoysticks {
	CCSprite* jsThumb;
    
	// Change thumb scale if you like smaller or larger controls.
	// Initially, just compensate for Retina display.
	GLfloat thumbScale = CC_CONTENT_SCALE_FACTOR();
    
	// The joystick that controls the player's (camera's) direction
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = thumbScale;

	directionJoystick = [Joystick joystickWithThumb: jsThumb
											andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	
	// If you want to see the size of the Joystick backdrop, comment out the line above
	// and uncomment the three lines below. This just adds a simple bland colored backdrop
	// to demonstrate that the thumb and backdrop can be any CCNode, but normally you
	// would use a nice graphical CCSprite for the Joystick backdrop.
//    CCLayer* jsBackdrop = [CCLayerColor layerWithColor: ccc4(255, 255, 255, 63)
//     											 width: kJoystickSideLength height: kJoystickSideLength];
//    jsBackdrop.isRelativeAnchorPoint = YES;
//    directionJoystick = [Joystick joystickWithThumb: jsThumb andBackdrop: jsBackdrop];
	
	directionJoystick.position = ccp(kJoystickPadding, kJoystickPadding);
	[self addChild: directionJoystick];
	
	// The joystick that controls the player's (camera's) location
	jsThumb = [CCSprite spriteWithFile: kJoystickThumbFileName];
	jsThumb.scale = thumbScale;
	
	locationJoystick = [Joystick joystickWithThumb: jsThumb
										   andSize: CGSizeMake(kJoystickSideLength, kJoystickSideLength)];
	[self positionLocationJoystick];
	[self addChild: locationJoystick];
}



/**
 * Positions the right-side location joystick at the right of the layer.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the joystick in the correct location within the new layer dimensions.
 */
-(void) positionLocationJoystick {
	locationJoystick.position = ccp(self.contentSize.width - kJoystickSideLength - kJoystickPadding, kJoystickPadding);
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    Cocos3dAppDelegate* mainDelegate = (Cocos3dAppDelegate *)[[UIApplication sharedApplication]delegate];
    
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
    
    mainDelegate.wGx = 20.0f*accelX;
    mainDelegate.wGy = 20.0f*accelY;
    
}

/**
 * Creates a button (actually a single-item menu) in the bottom center of the layer that will
 * allow the user to switch between four different views of the 3D scene.
 */
-(void) addSwitchViewButton {
#define kSwitchViewButtonFileName		@"ArrowLeftButton48x48.png"
#define kButtonRingFileName				@"ButtonRing48x48.png"

	// Set up the menu item and position it in the bottom center of the layer
	switchViewMI = [AdornableMenuItemImage itemWithNormalImage: kSwitchViewButtonFileName
												 selectedImage: kSwitchViewButtonFileName
														target: self
													  selector: @selector(switchViewSelected:)];
	[self positionButtons];
	
	// Instead of having different normal and selected images, the toggle menu item uses an
	// adornment, which is displayed whenever an item is selected.
	CCNodeAdornmentBase* adornment;
	
	// The adornment is a ring that fades in around the menu item and then fades out when
	// the menu item is no longer selected.
	CCSprite* ringSprite = [CCSprite spriteWithFile: kButtonRingFileName];
	adornment = [CCNodeAdornmentOverlayFader adornmentWithAdornmentNode: ringSprite];
	adornment.zOrder = kAdornmentUnderZOrder;
	
	// The adornment could also be a "shine" image that is faded in on-top of the
	// menu item when it is selected, similar to some UIKit toolbar button implementations.
	// To try a "shine" adornment instead, uncomment the following.
    //	CCSprite* shineSprite = [CCSprite spriteWithFile: kButtonShineFileName];
    //	shineSprite.color = ccYELLOW;
    //	adornment = [CCNodeAdornmentOverlayFader adornmentWithAdornmentNode: shineSprite
    //	 													    peakOpacity: kPeakShineOpacity];
	
	// Or the menu item adornment could be one that scales the menu item when activated.
	// To try a scaler adornment, uncomment the following line.
    //	adornment = [CCNodeAdornmentScaler adornmentToScaleUniformlyBy: kButtonAdornmentScale];
	
	// Attach the adornment to the menu item and center it on the menu item
	adornment.position = ccpCompMult(ccpFromSize(switchViewMI.contentSize), switchViewMI.anchorPoint);
	switchViewMI.adornment = adornment;
	
	CCMenu* viewMenu = [CCMenu menuWithItems: switchViewMI, nil];
	viewMenu.position = CGPointZero;
	[self addChild: viewMenu];
}

/** The user has pressed the switch camera view button. Tell the 3D scene so it can move the camera. */
-(void) switchViewSelected: (CCMenuItemToggle*) svMI {
	[self.cc3Scene switchCameraTarget];
}



/**
 * Positions the buttons between the two joysticks.
 * This is called at initialization, and anytime the content size of the layer changes
 * to keep the button in the correct location within the new layer dimensions.
 */
-(void) positionButtons {
#define kButtonGrid						40.0
    
	GLfloat middle = self.contentSize.width / 2.0;
	GLfloat btnY = (kJoystickPadding * 0.5) + (kButtonGrid * 0.5);
    
	shadowMI.position = ccp(middle - (kButtonGrid * 0.5), btnY);
	zoomMI.position = ccp(middle + (kButtonGrid * 0.5), btnY);
    
	btnY += kButtonGrid;
	switchViewMI.position = ccp(middle - (kButtonGrid * 1.0), btnY);
	invasionMI.position = ccp(middle, btnY);
	sunlightMI.position = ccp(middle + (kButtonGrid * 1.0), btnY);
}

#pragma mark Updating layer

/**
 * Updates the player (camera) direction and location from the joystick controls
 * and then updates the 3D scene.
 */
-(void) update: (ccTime)dt {
	[self sampleDeviceMotion];
    
	// Update the player direction and position in the scene from the joystick velocities
	self.cocos3dScene.playerDirectionControl = directionJoystick.velocity;
	self.cocos3dScene.playerLocationControl = locationJoystick.velocity;
	[super update: dt];
}
/**
 * Override to perform set-up activity prior to the scene being opened
 * on the view, such as adding gesture recognizers.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onOpenCC3Layer {}

/**
 * Override to perform tear-down activity prior to the scene disappearing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onCloseCC3Layer {}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, uncomment the following method implementation.
 */
/*
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
 */

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch!");
}

#pragma mark gyroscope motion

-(void) initializeDeviceMotion {
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    _motionManager.accelerometerUpdateInterval = .2;
    _motionManager.gyroUpdateInterval = .2;
    
    if (_motionManager.isDeviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdates];
    }
}


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    NSLog(@"Acceleration x:%f y:%f z:%f", acceleration.x, acceleration.y, acceleration.z);
//    self.accX.text = [NSString stringWithFormat:@" %.2fg",acceleration.x];
//    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
//    {
//        currentMaxAccelX = acceleration.x;
//    }
//    self.accY.text = [NSString stringWithFormat:@" %.2fg",acceleration.y];
//    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
//    {
//        currentMaxAccelY = acceleration.y;
//    }
//    self.accZ.text = [NSString stringWithFormat:@" %.2fg",acceleration.z];
//    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
//    {
//        currentMaxAccelZ = acceleration.z;
//    }
//    
//    self.maxAccX.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelX];
//    self.maxAccY.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelY];
//    self.maxAccZ.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelZ];
}

-(void)outputRotationData:(CMRotationRate)rotation
{
    NSLog(@"Rotation x:%f y:%f z:%f", rotation.x, rotation.y, rotation.z);

//    self.rotX.text = [NSString stringWithFormat:@" %.2fr/s",rotation.x];
//    if(fabs(rotation.x) > fabs(currentMaxRotX))
//    {
//        currentMaxRotX = rotation.x;
//    }
//    self.rotY.text = [NSString stringWithFormat:@" %.2fr/s",rotation.y];
//    if(fabs(rotation.y) > fabs(currentMaxRotY))
//    {
//        currentMaxRotY = rotation.y;
//    }
//    self.rotZ.text = [NSString stringWithFormat:@" %.2fr/s",rotation.z];
//    if(fabs(rotation.z) > fabs(currentMaxRotZ))
//    {
//        currentMaxRotZ = rotation.z;
//    }
//    
//    self.maxRotX.text = [NSString stringWithFormat:@" %.2f",currentMaxRotX];
//    self.maxRotY.text = [NSString stringWithFormat:@" %.2f",currentMaxRotY];
//    self.maxRotZ.text = [NSString stringWithFormat:@" %.2f",currentMaxRotZ];
}

-(void) sampleDeviceMotion {
    
    if (_motionManager.isDeviceMotionActive) {
        CMDeviceMotion* deviceMotion = _motionManager.deviceMotion;
        CMAttitude* currAttitude = deviceMotion.attitude;
        
    
//        NSLog(@"Roll:%f Pitch:%f Yaw:%f", currAttitude.roll, currAttitude.pitch, currAttitude.yaw);
        
        Cocos3dScene *scene = [self cocos3dScene];
        [scene gyroscope:currAttitude.roll andPitch:currAttitude.pitch andYaw:currAttitude.yaw];
        
        //        if ( !referenceAttitude ) self.referenceAttitude = [currAttitude copyAutoreleased];
        
//        [currAttitude multiplyByInverseOfAttitude: referenceAttitude];
//        LogCleanTrace(@"%@", currAttitude);
        
//        CC3Vector rotRadians = cc3v(currAttitude.pitch, currAttitude.roll, 0.0f);
//        self.myScene.cameraRotation = CC3VectorScaleUniform(rotRadians, RadiansToDegreesFactor);
    }
}

@end
