    /**
 *  Cocos3dScene.m
 *  Cocos3d
 *
 *  Created by Yuhua Mai on 10/31/13.
 *  Copyright Yuhua Mai 2013. All rights reserved.
 */

extern "C" {
#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}

#import "Cocos3dLayer.h"
#import "Cocos3dScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import <CC3Billboard.h>

#import "CCScheduler.h"

#import "CC3ControllableLayer.h"

#import "CC3ShaderProgram.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3UtilityMeshNodes.h"

#import "ccTypes.h"

#import "CCPhysicsSprite.h"



#define PTM_RATIO 32

enum {
	kTagParentNode = 1,
};



@interface Cocos3dScene ()
{
    float y;
    float z;
    
    CGSize screenSize;
    
    b2Body* earthBody;
    b2Body* groundBody;
    b2Body* cubeBody;
    
    CC3Ray _lastCameraOrientation;

}

//Background setting
@property (nonatomic) CC3MeshNode *ground;

//Objects
@property (nonatomic) CC3MeshNode *earth;
@property (nonatomic) CC3MeshNode *test;

@property (nonatomic) CC3BoxNode *cube;

//Camera
@property (nonatomic) CC3Node* cameraTarget;


@end

@implementation Cocos3dScene

//background
@synthesize ground;

//objects
@synthesize earth;
@synthesize test;

@synthesize cube;

//joysticks
@synthesize playerDirectionControl=_playerDirectionControl;
@synthesize playerLocationControl=_playerLocationControl;

//camera
@synthesize cameraTarget = _cameraTarget;


-(void) dealloc {
	[super dealloc];
}

#pragma mark Init process

/**
 * Constructs the 3D scene prior to the scene being displayed.
 *
 * Adds 3D objects to the scene, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model scene.
 *
 * You can also load scene content asynchronously while the scene is being displayed by
 * loading on a background thread. The
 *
 * NOTES:
 *
 * 1) To help you find your scene content once it is loaded, the onOpen method below contains
 *    code to automatically move the camera so that it frames the scene. You can remove that
 *    code once you know where you want to place your camera.
 *
 * 2) The POD file used for the 'hello, world' message model is fairly large, because converting a
 *    font to a mesh results in a LOT of triangles. When adapting this template project for your own
 *    application, REMOVE the POD file 'hello-world.pod' from the Resources folder of your project.
 */

-(void) initializeScene {
#define kNoFadeIn						0.0f

    z = 0.0;
    
    
    
    screenSize = [CCDirector sharedDirector].winSize;
    previousTime = nil;

    [self initCustomState];			// Set up any initial state tracked by this subclass

    [self preloadAssets];			// Loads, compiles, links, and pre-warms all shader programs
    // used by this scene, and certain textures.
    
    //Box2D
    [self setWorld];

    /*
     * Draw Backround & Ground & Billboard
     */
    [self addBackdrop];
    [self addGround];
//    [self addBillboard];
    
//    [self addLabel];
    
   
    /*
     * Add objects
     */
    [self addEarth];

    
//    [self addTestPOD];
//    [self addBall];
//    [self drawCube];

    
//    [self addRobot];				// Add an animated robot arm, a light, and a camera. This POD file
    // contains the primary camera of this scene.
//    [self drawLine];
//    [self drawSphere];
    
    [self configureLighting];		// Set up the lighting
	[self configureCamera];			// Check out some interesting camera options.

    // Configure all content added so far in a standard manner. This illustrates how CC3Node
	// properties and methods can be applied to large assemblies of nodes, and even the entire
	// scene itself, allowing us to perform this only once, for all current scene content.
	// For content that is added dynamically after this initial content, this method will also
	// be invoked on each new content component.
	[self configureForScene: self andMaterializeWithDuration: kNoFadeIn];

	
	// That's it! The scene is now constructed and is good to go.
	
	// To help you find your scene content once it is loaded, the onOpen method below contains
	// code to automatically move the camera so that it frames the scene. You can remove that
	// code once you know where you want to place your camera.
	
	// If you encounter problems displaying your models, you can uncomment one or more of the
	// following lines to help you troubleshoot. You can also use these features on a single node,
	// or a structure of nodes. See the CC3Node notes for more explanation of these properties.
	// Also, the onOpen method below contains additional troubleshooting code you can comment
	// out to move the camera so that it will display the entire scene automatically.
	
	// Displays short descriptive text for each node (including class, node name & tag).
	// The text is displayed centered on the pivot point (origin) of the node.
    //	self.shouldDrawAllDescriptors = YES;
	
	// Displays bounding boxes around those nodes with local content (eg- meshes).
    //	self.shouldDrawAllLocalContentWireframeBoxes = YES;
	
	// Displays bounding boxes around all nodes. The bounding box for each node
	// will encompass its child nodes.
    //	self.shouldDrawAllWireframeBoxes = YES;
	
	// If you encounter issues creating and adding nodes, or loading models from
	// files, the following line is used to log the full structure of the scene.
	LogInfo(@"The structure of this scene is: %@", [self structureDescription]);
    
 	// ------------------------------------------
   

//    [self  setCam];
//    [self.activeCamera moveToShowAllOf:ground withPadding:0.5];

}

- (void) setCam
{
    CC3Camera *cam = self.activeCamera;
    CC3Vector moveVector = CC3VectorAdd(CC3VectorScaleUniform(cam.globalRightDirection, 0.001),CC3VectorScaleUniform(cam.globalForwardDirection, 0.5));
    
    cam.location = CC3VectorAdd(cam.location, moveVector); //change camera location
}

- (void)addLabel
{
    CC3BitmapLabelNode *bmLabel = [[CC3BitmapLabelNode alloc] initWithName:@"I am a label."];
//    bmLabel.radius = 50;
	bmLabel.textAlignment = NSTextAlignmentCenter;
	bmLabel.relativeOrigin = ccp(0.5, 0.5);
	bmLabel.tessellation = CC3TessellationMake(4, 1);
//	bmLabel.fontFileName = @"Arial32BMGlyph.fnt";
	bmLabel.labelString = @"Hello, world!";
//	_bmLabelMessageIndex = 0;	// Keep track of which message is being displayed
	
	bmLabel.location = cc3v(-150.0, 75.0, 500.0);
	bmLabel.rotation = cc3v(0.0, 180.0, 0.0);
	bmLabel.uniformScale = 2.0;
	bmLabel.color = ccc3(0, 220, 120);
	bmLabel.shouldCullBackFaces = NO;			// Show from behind as well.
	bmLabel.shouldBlendAtFullOpacity = YES;		// We're fading in, so ensure blending remains
	bmLabel.touchEnabled = YES;

    [self addChild:bmLabel];
}

- (void)addBillboard
{
    CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: @"Race Earth Game!"
											 fontName: @"Marker Felt"
											 fontSize: 18.0];
    CC3Billboard *bb = [[CC3Billboard alloc] initWithBillboard:bbLabel];
    bb.color = ccYELLOW;
    
    // The billboard is a one-sided rectangular mesh, and would not normally be visible
	// from the back side. This is not an issue, since it is configured to always face
	// the camera. However, this also affects its ability to cast a shadow when the light
	// is behind it. Set the back faces to draw so that a shadow will be cast when the
	// light is behind the billboard.
    //	bb.shouldCullBackFaces = NO;
	
	// As the hose emitter moves around, it is sometimes in front of this billboard,
	// but emits some particles behind this billboard. The result is that those
	// particles are blocked by the transparent parts of the billboard and appear to
	// inappropriately disappear. To compensate, set the explicit Z-order of the
	// billboard to be either always in-front of (< 0) or always behind (> 0) the
	// particle emitter. You can experiment with both options here. Or set the Z-order
	// to zero (the default and same as the emitter), and see what the problem is in
	// the first place! The problem is more evident when the emitter is set to a wide
	// dispersion angle.
	bb.zOrder = -1;
	
	// Uncomment to see the extent of the label as it moves in the 3D scene
    //	bb.shouldDrawLocalContentWireframeBox = YES;
	
	// A billboard can be drawn either as part of the 3D scene, or as an overlay
	// above the 3D scene. By commenting out one of the following sections of code,
	// you can choose which method to use.
	
	// 1) In the 3D scene.
	// Locate the billboard at the end of the robot's arm, and tell it to
	// find the camera and track it, so that it always faces the camera.
	bb.location = cc3v( 0.0, 10.0, 0.0 );
	bb.shouldAutotargetCamera = YES;
    [self addChild:bb];
    
	// 2) Overlaid above the 3D scene.
	// The following lines add the emitter billboard as a 2D overlay that draws above
	// the 3D scene. The label text will not be occluded by any other 3D nodes.
	// Comment out the lines just above, and uncomment the following lines:
//	bb.shouldDrawAs2DOverlay = YES;
//	bb.location = cc3v( 0.0, 80.0, 0.0 );
//	bb.unityScaleDistance = 425.0;
//	bb.offsetPosition = ccp( 0.0, 15.0 );
//    [self addChild:bb];

    //	[[self getNodeNamed: kRobotTopArm] addChild: bb];
}



/**
 * By populating this method, you can add add additional scene content dynamically and
 * asynchronously after the scene is open.
 *
 * This method is invoked from a code block defined in the onOpen method, that is run on a
 * background thread by the CC3GLBackgrounder available through the backgrounder property of
 * the viewSurfaceManager. It adds content dynamically and asynchronously while rendering is
 * running on the main rendering thread.
 *
 * You can add content on the background thread at any time while your scene is running, by
 * defining a code block and running it on the backgrounder of the viewSurfaceManager. The
 * example provided in the onOpen method is a template for how to do this, but it does not
 * need to be invoked only from the onOpen method.
 *
 * Certain assets, notably shader programs, will cause short, but unavoidable, delays in the
 * rendering of the scene, because certain finalization steps from shader compilation occur on
 * the main thread. Shaders and certain other critical assets should be pre-loaded in the
 * initializeScene method prior to the opening of this scene.
 */
-(void) addSceneContentAsynchronously {}


/**
 * Invoked by the customized initializeScene to set up any initial state for
 * this customized scene. This is broken into a separate method so that the
 * initializeScene method can focus on loading the artifacts of the 3D scene.
 */
-(void) initCustomState {
	
	_isManagingShadows = NO;
	_playerDirectionControl = CGPointZero;
	_playerLocationControl = CGPointZero;
	
	// The order in which meshes are drawn to the GL engine can be tailored to your needs.
	// The default is to draw opaque objects first, then alpha-blended objects in reverse
	// Z-order. Since this example has lots of similar teapots and robots to draw in this
	// example, we choose to also group objects by meshes here, while also drawing opaque
	// objects first, and translucent objects in reverse Z-order.
	//
	// To experiment with an alternate drawing order, set a different node sequence sorter
	// by uncommenting one of the lines here and commenting out the others. The third option
	// performs no grouping and draws the objects in the order they are added to the scene below.
	// The fourth option does not use a drawing sequencer, and draws the objects hierarchically
	// instead. With this, notice that the transparent beach ball now appears opaque, because
	// it  was added first, and is traversed ahead of other objects in the hierarchical assembly,
	// resulting it in being drawn first, and so it cannot blend with the background.
	//
	// You can of course write your own node sequencers to customize to your specific
	// app needs. Best to change the node sequencer before any model objects are added.
	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
	//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupMeshes];
	//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupTextures];
	//	self.drawingSequencer = nil;
}


/**
 * Pre-loads certain assets, such as shader programs, and certain textures, prior to the
 * scene being displayed.
 *
 * Much of the scene is loaded on a background thread, while the scene is visible. However,
 * the handling of some assets on the background thread can interrupt the main rendering thread.
 *
 * The GL drivers often leave the final stages of shader compilation and configuration until
 * the first time the shader program is used to render an object. This can often introduce a
 * short, unwanted pause if the shader program is loaded while the scene is running.
 *
 * Unfortunately, although resources such as models, textures, and shader programs can be loaded
 * on a background thread, the final stages of shader programs compilation must be performed on
 * the primary rendering thread. Because of this, the only way to avoid an unwanted pause while
 * a shader program compilation is finalized is to therefore perform all shader program loading
 * prior to the scene being displayed, including shader programs that may not be required until
 * additional content is loaded later in the scene on a background thread.
 *
 * In order to ensure that the shader programs will be available when the models are loaded
 * at a later point in the scene (usually via background loading), the cache must be configured
 * to retain the loaded shader programs even though they will not immediately be used to display
 * any models. This is done by turning on the value of the class-side isPreloading property.
 *
 * In addition, the automatic creation of mipmaps on larger textures, particularly cube-map
 * textures (which require a set of six mipmaps), can cause excessive work for the GPU in
 * the background, which can spill over into a delay on the primary rendering thread.
 *
 * As a result, a large cube-map texture is loaded here and cached, for later access once
 * the model that uses it is loaded in the background.
 */
-(void) preloadAssets {
#if CC3_GLSL
    
	// Strongly cache the shader programs loaded here, so they'll be availble
	// when models are loaded on the background loading thread.
	CC3ShaderProgram.isPreloading = YES;
    
    
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3BumpMapObjectSpace.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3MultiTextureConfigurable.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3SingleTextureAlphaTest.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3SingleTexture.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"BumpMap.vsh" andFragmentShaderFile: @"BumpMap.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3PureColor.vsh" andFragmentShaderFile: @"CC3PureColor.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3SingleTextureReflect.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3NoTexture.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3PointSprites.vsh" andFragmentShaderFile: @"CC3PointSprites.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh" andFragmentShaderFile: @"CC3ClipSpaceNoTexture.fsh"];
//	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3BumpMapTangentSpace.fsh"];
    
	// Now pre-load shader programs that originate in PFX resources
	CC3Resource.isPreloading = YES;
    
//	[CC3PFXResource resourceFromFile: kPostProcPFXFile];
//	[CC3PFXResource resourceFromFile: kMasksPFXFile];
	
	// All done with shader pre-loading...let me know if any further shader programs are loaded
	// during the scene operation.
	CC3Resource.isPreloading = NO;
	CC3ShaderProgram.isPreloading = NO;
    
#endif	// CC3_GLSL
	
	// The automatic generation of mipmap in the environment map texture on the background
	// thread causes a short delay in rendering on the main thread. The text glyph texture
	// also requires substantial time for mipmap generation. For such textures, by loading
	// the texture, creating the mipmap, and caching the texture here, we can avoid the delay.
	// All other textures are loaded on the background thread.
//	CC3Texture.isPreloading = YES;
//	[CC3Texture textureFromFile: @"Arial32BMGlyph.png"];
#if !CC3_OGLES_1
//	[CC3Texture textureCubeFromFilePattern: @"EnvMap%@.jpg"];
#endif	// !CC3_OGLES_1
//	CC3Texture.isPreloading = NO;
}



/** Configure the lighting. */
-(void) configureLighting {
	
      // Create a light, place it back and to the left at a specific
    // position (not just directional lighting), and add it to the world
    CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
    lamp.location = cc3v( 0.0, 0.0, 5.0 );
    lamp.isDirectionalOnly = NO;
    [self addChild: lamp];
    
    
	// Start out with a sunny day
	_lightingType = kLightingSun;
    
	// Set the ambient scene lighting.
	self.ambientLight = ccc4f(0.3, 0.3, 0.3, 1.0);
    
	// Adjust the relative ambient and diffuse lighting of the main light to
	// improve realisim, particularly on shadow effects.
//	_robotLamp.diffuseColor = ccc4f(0.8, 0.8, 0.8, 1.0);
	
	// Another mechansim for adjusting shadow intensities is shadowIntensityFactor.
	// For better effect, set here to a value less than one to lighten the shadows
	// cast by the main light.
//	_robotLamp.shadowIntensityFactor = 0.75f;
	
	// The light from the robot POD file is animated to move back and forth, changing
	// the lighting of the scene as it moves. To turn this animation off, comment out
	// the following line. This can be useful when reviewing shadowing.
    //	[_robotLamp disableAnimation];
	
}

/** Various options for configuring interesting camera behaviours. */
-(void) configureCamera {
    // Create the camera
//    CC3Camera* cam = self.activeCamera;
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
    [self addChild: cam];
//    [self setActiveCamera:cam];
    
	// Camera starts out embedded in the scene.
	_cameraZoomType = kCameraZoomNone;
	
	// The camera comes from the POD file and is actually animated.
	// Stop the camera from being animated so the user can control it via the user interface.
	[cam disableAnimation];
	
	// Keep track of which object the camera is pointing at
	_origCamTarget = cam.target;
	_camTarget = _origCamTarget;
    
	// For cameras, the scale property determines camera zooming, and the effective field-of-view.
	// You can adjust this value to play with camera zooming. Conversely, if you find that objects
	// in the periphery of your view appear elongated, you can adjust the fieldOfView and/or
	// uniformScale properties to reduce this "fish-eye" effect. See the notes of the CC3Camera
	// fieldOfView property for more on this.
	cam.uniformScale = 1.0;
    cam.fieldOfView = 45.0;
//    cam.nearClippingDistance = 20.0;
//    [cam moveToShowAllOf:earth withPadding:1.0];
	
	// You can configure the camera to use orthographic projection instead of the default
	// perspective projection by setting the isUsingParallelProjection property to YES.
	// You will also need to adjust the scale to match the different projection.
    //    cam.isUsingParallelProjection = YES;
    //    cam.uniformScale = 0.015;
	
	// To see the effect of mounting a camera on a moving object, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball.
	// Since the beach ball rotates as it bounces, you might also want to comment out the
	// CC3RotateBy action that is run on the beachBall in the addBeachBall method!
    //	[beachBall addChild: cam];				// Mount the camera on the beach ball
    //	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
    //	cam.rotation = cc3v(0.0, 90.0, 0.0);	// Point camera out over the beach ball
    
    
	// To see the effect of mounting a camera on a moving object AND having the camera track a
	// location or object, even as the moving object bounces and rotates, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball, but stay pointed at
	// the moving rainbow teapot, even as the beach ball that the camera is mounted on bounces and
	// rotates. In this case, you do not need to comment out the CC3RotateBy action that is run on
	// the beachBall in the addBeachBall method
    //	[beachBall addChild: cam];				// Mount the camera on the beach ball
    //	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
    //	cam.target = teapotSatellite;			// Look toward the rainbow teapot...
    //	cam.shouldTrackTarget = YES;			// ...and track it as it moves
   
//    [testGround addChild:cam];
    cam.location = cc3v( 0.0, 1.0, 1.0 );
//    cam.rotation = cc3v(90.0, 0.0, 0.0);
    cam.target = earth;
    cam.shouldTrackTarget = YES; //move relative to the target
    [self setActiveCamera:cam];
    
    cam.viewport = CC3ViewportMake(0, 0, 1, 1);
    [self.activeCamera moveToShowAllOf:ground];

}

/**
 * Configures the specified node and all its descendants for use in the scene, and then fades
 * them in over the specified duration, in seconds. Specifying zero for the duration will
 * instantly materialize the node without employing any fading.
 *
 * This scene is highly complex, and it helps to configure the nodes within it in a standardized
 * manner, including whether we use VBO's to manage the vertices, whether the vertices need to
 * also be retained in main memory, whether bounding volumes are required, and to force early
 * selection of shaders for use with the nodes.
 *
 * The specified node can be the root of an arbitrarily complex node tree, and the behaviour
 * applied in this method is propagated to all descendant nodes of the specified node, and the
 * materialization fading will be applied to the entire node tree. The specified node can even
 * be the entire scene itself.
 */
-(void) configureForScene: (CC3Node*) aNode andMaterializeWithDuration: (ccTime) duration {
	
	// Create OpenGL buffers for the vertex arrays to keep things fast and efficient, and
	// to save memory, release the vertex data in main memory because it is now redundant.
	// However, because we can add shadow volumes dynamically to any node, we need to keep the
	// vertex location, index and skinning data of all meshes around to build shadow volumes.
	// If we had added the shadow volumes before here, we wouldn't have to retain this data.
	[aNode retainVertexLocations];
	[aNode retainVertexIndices];
	[aNode retainVertexWeights];
	[aNode retainVertexMatrixIndices];
    
    // Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[aNode createGLBuffers];
	[aNode releaseRedundantContent];
	
	// This scene is quite complex, containing many objects. As the user moves the camera
	// around the scene, objects move in and out of the camera's field of view. At any time,
	// there may be a number of objects that are out of view of the camera. With such a scene
	// layout, we can save significant GPU processing by not drawing those objects. To make
	// that happen, we assign a bounding volume to each mesh node. Once that is done, only
	// those objects whose bounding volumes intersect the camera frustum will be drawn.
	// Bounding volumes can also be used for collision detection between nodes. You can see
	// the effect of not using bounding volumes on drawing perfomance by commenting out the
	// following line and taking note of the drop in performance for this scene. However,
	// testing bounding volumes against the camera's frustum does take some CPU processing,
	// and in scenes where all or most of the objects are in front of the camera at all times,
	// using bounding volumes may actually result in slightly lower performance. By including
	// or not including the line below, you can test both scenarios and decide which approach
	// is best for your particular scene. Bounding volumes are not automatically created for
	// skinned meshes, such as the runners and mallet. See the addSkinnedRunners and
	// addSkinnedMallet methods to see how those bounding volumes are added manually.
	[aNode createBoundingVolumes];
	
	// The following line displays the bounding volumes of each node. The bounding volume of
	// all mesh nodes, except the globe, contains both a spherical and bounding-box bounding
	// volume, to optimize testing. For something extra cool, touch the robot arm to see the
	// bounding volume of the particle emitter grow and shrink dynamically. Use the joystick
	// controls or gestures to back the camera away to get the full effect. You can also turn
	// on this property on individual nodes or node structures. See the notes for this property
	// and the shouldDrawBoundingVolume property in the CC3Node class notes.
    //	aNode.shouldDrawAllBoundingVolumes = YES;
	
	// Select an appropriate shader program for each mesh node in this scene now. If this step
	// is omitted, a shader program will be selected for each mesh node the first time that mesh
	// node is drawn. Doing it now adds some additional time up front, but avoids potential pauses
	// as each shader program is loaded as needed the first time it is needed during drawing.
	[aNode selectShaderPrograms];
	
	// For an interesting effect, to draw text descriptors and/or bounding boxes on every node
	// during debugging, uncomment one or more of the following lines. The first line displays
	// short descriptive text for each node (including class, node name & tag). The second line
	// displays bounding boxes of only those nodes with local content (eg- meshes). The third
	// line shows the bounding boxes of all nodes, including those with local content AND
	// structural nodes. You can also turn on any of these properties at a more granular level
	// by using these and similar methods on individual nodes or node structures. See the CC3Node
	// class notes. This family of properties can be particularly useful during development to
	// track down display issues.
    //	aNode.shouldDrawAllDescriptors = YES;
    //	aNode.shouldDrawAllLocalContentWireframeBoxes = YES;
    //	aNode.shouldDrawAllWireframeBoxes = YES;
	
	// Use a standard CCFadeIn to fade the node in over the specified duration
	if (duration > 0.0f) {
		aNode.opacity = 0;	// Needed for cocos2d 1.x, which doesn't start fade-in from zero opacity
		[aNode runAction: [CCFadeIn actionWithDuration: duration]];
	}
}

- (void)setWorld
{
    ////Box 2D
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(10.0f, 10.0f);
    
    CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
    spriteTexture_ = [parent texture];
    
    // Do we want to let bodies sleep?
    // This will speed up the physics simulation
    // note * bodies seem to sleep when at rest for too long and will only wake up again on collision?
    bool doSleep = true;
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    _world = new b2World(gravity, doSleep);
    _world->SetContinuousPhysics(true);
    
    b2ContactListener *myListener = new b2ContactListener();
    _world->SetContactListener(myListener);
}

#pragma mark Create objects
/**
 * If we're not overlaying the device camera, creates the clear-blue-sky backdrop.
 * Or install a textured backdrop by uncommenting the last line of this method.
 * See the notes for the backdrop property for more info.
 */
-(void) addBackdrop {
#define kSkyColor						ccc4f(0.4, 0.5, 0.9, 1.0)
#define kBrickTextureFile				@"Bricks-Red.jpg"

//	if (self.cc3Layer.isOverlayingDeviceCamera) return;
	self.backdrop = [CC3ClipSpaceNode nodeWithColor: kSkyColor];
//    self.backdrop = [CC3ClipSpaceNode nodeWithTexture: [CC3Texture textureFromFile: kBrickTextureFile]];
}

/**
 * Add a large circular grass-covered ground to give everything perspective.
 * The ground is tessellated into many smaller faces to improve realism of spotlight.
 */

- (void)addGround
{
#define kGroundName						@"Ground"
#define kGroundTextureFile				@"grass2.jpg"
    double width = 20;
    double length = 100;
    ground = [CC3PlaneNode nodeWithName:@"Ground"];
    [ground populateAsRectangleWithSize:CGSizeMake(width, length) andRelativeOrigin:CGPointMake(0.0, 0.0)];

//    ground.color = ccBLUE;
    [ground setTexture:[CC3Texture textureFromFile: kGroundTextureFile]];
    [ground repeatTexture: (ccTex2F){10, 10}];	// Grass

    ground.location = cc3v(0.0, -14.0, -50.0);
    ground.rotation = cc3v(-90.0, 180.0, 0.0);
    ground.shouldCullBackFaces = YES;
    [ground retainVertexLocations];
    
    [self addChild:ground];
    
//    CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
//    cam.location = cc3v( 0.5, 1.0, 3.0 );
//    [ground addChild: cam];
    
    CC3Light* lamp = [CC3Light node];
	lamp.location = cc3v( 0.0, 0.0, 50.0 ); //add lamp for the ground
	lamp.isDirectionalOnly = NO;
	[ground addChild: lamp];
    
    /*
    //create earth body
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_dynamicBody;
    //    earthBodyDef.position.Set(0.0, 0.0);
    groundBodyDef.position.Set(100/PTM_RATIO, 400/PTM_RATIO);
    groundBodyDef.userData = ground;
    groundBodyDef.linearVelocity = b2Vec2(0.0f, 0.0f);
    groundBody = _world->CreateBody(&groundBodyDef);
    
    // Create plane shape
    b2Vec2 vertices[4];
    vertices[0].Set(0.0f, 0.0f);
    vertices[1].Set(20.0f, 0.0f);
    vertices[2].Set(2.0f, 20.0f);
    vertices[3].Set(0.0f, 20.0f);
    int32 count = 4;
    b2PolygonShape polygon;
    polygon.Set(vertices, count);
    
    
    // Create shape definition and add to body
    b2FixtureDef groundShapeDef;
    groundShapeDef.shape = &polygon;
    groundShapeDef.density = 0.0f;
    groundShapeDef.restitution = 0.35f;
    groundShapeDef.isSensor = FALSE;
    b2Fixture *groundFixture = groundBody->CreateFixture(&groundShapeDef);
     */
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);
    
    // The body is also added to the world.
    groundBody = _world->CreateBody(&groundBodyDef);
    groundBody->SetType(b2_staticBody);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;

    
    // bottom
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(width,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
//    groundBox.SetAsEdge(b2Vec2(width,0), b2Vec2(width,length));
//    groundBody->CreateFixture(&groundBox,0);
//    
//    // top
//    groundBox.SetAsEdge(b2Vec2(width,length), b2Vec2(-width,length));
//    groundBody->CreateFixture(&groundBox,0);
//    
//    // left
//    groundBox.SetAsEdge(b2Vec2(-width,length), b2Vec2(-width,0));
//    groundBody->CreateFixture(&groundBox,0);
    

}


/** Loads a POD file containing an animated robot arm, a camera, and an animated light. */
-(void) addRobot {
#define kPODRobotRezNodeName			@"RobotPODRez"
#define kRobotPODFile					@"IntroducingPOD_float.pod"
#define kRobotCameraName				@"Camera01"
#define kPODLightName					@"FDirect01"
	// We introduce a specialized resource subclass, not because it is needed in general,
	// but because the original PVR demo app ignores some data in the POD file. To replicate
	// the PVR demo faithfully, we must do the same, by tweaking the loader to act accordingly
	// by creating a specialized subclass.
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODRobotRezNodeName];
	podRezNode.resource = [IntroducingPODResource resourceFromFile: kRobotPODFile];
	
	// If you want to stop the robot arm from being animated, uncomment the following line.
    //	[podRezNode disableAllAnimation];
	
	podRezNode.touchEnabled = YES;
	[self addChild: podRezNode];
	
	// Retrieve the camera in the POD and cache it for later access.
	_robotCam = (CC3Camera*)[podRezNode getNodeNamed: kRobotCameraName];
	
	// Retrieve the light from the POD resource so we can track its location as it moves via animation
	_robotLamp = (CC3Light*)[podRezNode getNodeNamed: kPODLightName];
	
	// Start the animation of the robot arm and bouncing lamp from the PVR POD file contents.
	// But we'll have a bit of fun with the animation, as follows.
	// The basic animation in the POD pirouettes the robot arm in a complex movement...
	CCActionInterval* pirouette = [CC3Animate actionWithDuration: 5.0];
	
	// Extract only the initial bending-down motion from the animation, reverse it to create
	// a stand-up motion, and paste the two actions together to create a bowing motion.
	CCActionInterval* bendDown = [CC3Animate actionWithDuration: 1.8 limitFrom: 0.0 to: 0.15];
	CCActionInterval* standUp = [bendDown reverse];
	CCActionInterval* takeABow = [CCSequence actionOne: bendDown two: standUp];
	
	// Now...put it all together. The robot arm performs its pirouette, and then takes a bow,
	// over and over again.
	[podRezNode runAction: [CCRepeatForever actionWithAction: [CCSequence actionOne: pirouette
																				two: takeABow]]];
}





- (void)addBall
{
    // This is the simplest way to load a POD resource file and add the
	// nodes to the CC3World, if no customized resource subclass is needed.
    //    [self addContentFromPODFile:@"Balls.pod" withName:@"BeachBall"];
	[self addContentFromPODFile: @"Balls.pod"];
    
    CC3MeshNode* globe = (CC3MeshNode*)[self getNodeNamed: @"Globe"];
    [self removeChild:globe];
    
	CC3MeshNode* bBall = (CC3MeshNode*)[self getNodeNamed: @"BeachBall"];

    // BALL
    // Create ball body
    b2BodyDef ballBodyDef2;
    ballBodyDef2.type = b2_dynamicBody;
    ballBodyDef2.position.Set(600/PTM_RATIO, 400/PTM_RATIO);
    ballBodyDef2.userData = bBall;
    ballBodyDef2.linearVelocity = b2Vec2(-10.0f, 0.0f);
    b2Body * ballBody2 = _world->CreateBody(&ballBodyDef2);
    
    // Create circle shape
    b2CircleShape circle2;
    //    circle2.m_radius = 10;
    circle2.m_radius = screenSize.width/5/PTM_RATIO;
    
    // Create shape definition and add to body
    b2FixtureDef ballShapeDef2;
    ballShapeDef2.shape = &circle2;
    ballShapeDef2.density = 2.0f;
    //    ballShapeDef2.friction = 0.2f;
    ballShapeDef2.restitution = 0.35f;
    ballShapeDef2.isSensor = FALSE;
    _ballFixture = ballBody2->CreateFixture(&ballShapeDef2);
    
    
    
    //White Ball
    // Create ball body
    b2BodyDef whiteBallBodyDef;
    whiteBallBodyDef.type = b2_dynamicBody;
    whiteBallBodyDef.position.Set(400/PTM_RATIO, 1000/PTM_RATIO);
    whiteBallBodyDef.userData = globe;
    whiteBallBodyDef.linearVelocity = b2Vec2(0.0f, 0.0f);
    b2Body * whiteBallBody = _world->CreateBody(&whiteBallBodyDef);
    
    // Create circle shape
    b2CircleShape whiteBallCircle;
    whiteBallCircle.m_radius = screenSize.width/5/PTM_RATIO;
    
    // Create shape definition and add to body
    b2FixtureDef whiteBallShapeDef;
    whiteBallShapeDef.shape = &whiteBallCircle;
    whiteBallShapeDef.density = 2.0f;
    whiteBallShapeDef.friction = 0.2f;
    whiteBallShapeDef.restitution = 0.35f;
    whiteBallShapeDef.isSensor = FALSE;
    _ballFixture = whiteBallBody->CreateFixture(&whiteBallShapeDef);
}

- (void)addEarth
{
    double initX = 5.0;
    double initY = 50.0;
    double initZ = 100.0;
    
    [self addContentFromPODFile:@"earth.pod" withName:@"earth"];
    
    earth = (CC3MeshNode*)[self getNodeNamed: @"earth"];
    [earth setLocation:cc3v(initX, initY, initZ)];
//    [earth setRotation:cc3v(-20.0, 0.0, 0.0)];
//    [earth translateBy:cc3v(100.0, 0.0, 0.0)];
    
    //animation
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                          rotateBy: cc3v(0.0, 30.0, 0.0)];
    [earth runAction: [CCRepeatForever actionWithAction: partialRot]];
    [self addChild:earth];
    
   // Create the camera, place it back a bit, and add it to the world
//	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
//	cam.location = cc3v( 0.0, 0.0, 3.0 );
//	[earth addChild:cam];
    

   // Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the world
//	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
//	lamp.location = cc3v( -2.0, 0.0, 3.0 );
//	lamp.isDirectionalOnly = NO;
//	[earth addChild: lamp];

    
    //create earth body
    b2BodyDef earthBodyDef;
    earthBodyDef.type = b2_dynamicBody;
    earthBodyDef.position.Set(initX, initY);
    earthBodyDef.userData = earth;
    earthBodyDef.linearVelocity = b2Vec2(0.0f, 0.0f);
    earthBody = _world->CreateBody(&earthBodyDef);
    
    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = 14; //not sure what the earth raidus is
    
    // Create shape definition and add to body
    b2FixtureDef earthShapeDef;
    earthShapeDef.shape = &circle;
    earthShapeDef.density = 0.0f;
    earthShapeDef.friction = 0.2f;
    earthShapeDef.restitution = 0.35f;
    earthShapeDef.isSensor = FALSE;
    _earthFixture = earthBody->CreateFixture(&earthShapeDef);
}

- (void)addTestPOD
{
    [self addContentFromPODFile: @"Untitled.pod" withName:@"test"];
    
    test = (CC3MeshNode*)[self getNodeNamed: @"test"];
    test.shaderProgram = [CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3BumpMapObjectSpace.fsh"];
    [test setLocation:cc3v(0.0, 0.0, 0.0)];
    [test setRotation:cc3v(-20.0, 0.0, 0.0)];
    //    [earth translateBy:cc3v(100.0, 0.0, 0.0)];
//    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0 rotateBy: cc3v(5.0, 0.0, 0.0)];
//    [test runAction: [CCRepeatForever actionWithAction: partialRot]];
    [self addChild:test];

    
}



- (void)drawLine
{
    CC3Vector arr_location[] = {0,0,0, 5,5, 5 };
    CC3LineNode* lineNode = [CC3LineNode nodeWithName: @"Line test"];
    [lineNode populateAsLineStripWith: 2
                             vertices: arr_location
                            andRetain: YES];
    lineNode.color = ccGREEN;
    
    [self addChild:lineNode];
}

- (void)drawCube
{
    CC3Vector a = CC3VectorMake(0.0, 0.0, 0.0);
    CC3Vector b = CC3VectorMake(2.0, 2.0, 2.0);
    CC3Box box = CC3BoxFromMinMax(a, b);
    
    cube = [[CC3BoxNode alloc] init];
//    CC3VertexShader *vertexShader = [[CC3VertexShader alloc] initWithName:@"spotlight.vsh"];
//    CC3FragmentShader *fragmentShader = [[CC3FragmentShader alloc] initWithName:@"spotlight.fsh"];
//    cube.shaderProgram = [CC3ShaderProgram programWithVertexShader:vertexShader andFragmentShader:fragmentShader];
    
    cube.shaderProgram = [CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh" andFragmentShaderFile: @"CC3BumpMapObjectSpace.fsh"];
//    cube.touchEnabled = YES;
    [cube setColor:ccc3(255.0, 0.0, 0.0)];
    [cube populateAsSolidBox:box];
    [cube setLocation:cc3v(-5.0, 0.0, 0.0)];
    
//    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
//                                                          rotateBy: cc3v(0.0, 10.0, 5.0)];
//    [cube runAction: [CCRepeatForever actionWithAction: partialRot]];
    
    
    [self addChild:cube];
    
    
    //create body
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(-5, 0);
    bodyDef.userData = cube;
    cubeBody = _world->CreateBody(&bodyDef);
    
    // Create circle shape
    b2PolygonShape shape;
    shape.SetAsBox(2, 2);
    
    // Create shape definition and add to body
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 0.0f;
    fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.35f;
    fixtureDef.isSensor = FALSE;
    cubeBody->CreateFixture(&fixtureDef);
    
}

- (void)drawSphere
{
    //    CC3Vector center = CC3VectorMake(5.0, 5.0, 5.0);
    //    CC3Sphere box = CC3SphereMake(center, 2.0);
    
    CC3SphereNode *sphere = [[CC3SphereNode alloc] init];
    [sphere setColor:ccc3(0.0, 100.0, 0.0)];
    [sphere populateAsSphereWithRadius:3.0 andTessellation:CC3TessellationMake(1, 2)];
    //    [sphere a]
    
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                          rotateBy: cc3v(0.0, 10.0, 5.0)];
    [sphere runAction: [CCRepeatForever actionWithAction: partialRot]];
    
    [self addChild:sphere];
    
}

//- (void)drawMeshNode
//{
//    CC3MeshNode *meshNode = [[CC3MeshNode alloc] initWithName:@"myMeshNode"];
//}


#pragma mark Updating custom activity

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the 3D nodes in the scene.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
    [self updateCameraFromControls: visitor.deltaTime];

//    Cocos3dAppDelegate* mainDelegate = (Cocos3dAppDelegate *)[[UIApplication sharedApplication]delegate];
    b2Vec2 gravity = b2Vec2(0.0f, -9.8f);
    _world->SetGravity(gravity);
    
    [self printLog];
    [self checkGameLogic];

}

- (void)printLog
{
    CC3Vector activeCamLoc = self.activeCamera.globalLocation;
    NSLog(@"Active camera: x:%f y:%f z:%f", activeCamLoc.x, activeCamLoc.y, activeCamLoc.z);
    
    //TODO set active camera z hardcode
//    self.activeCamera.globalLocation.z = 0;
    
    NSLog(@"Ground x:%f y:%f z:%f", ground.globalLocation.x, ground.globalLocation.y, ground.globalLocation.z);
    NSLog(@"GroundBody x:%f y:%f", groundBody->GetPosition().x, groundBody->GetPosition().y);
    
    NSLog(@"Earth x:%f y:%f z:%f", earth.globalLocation.x, earth.globalLocation.y, earth.globalLocation.z);
    NSLog(@"EarthBody x:%f y:%f", earthBody->GetPosition().x, earthBody->GetPosition().y);
    
//    NSLog(@"Cube x:%f y:%f z:%f", cube.globalLocation.x, cube.globalLocation.y, cube.globalLocation.z);
//    NSLog(@"CubeBody x:%f y:%f", cubeBody->GetPosition().x, cubeBody->GetPosition().y);

}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities after
 * the transformMatrix of the 3D nodes in the scen have been recalculated.
 *
 * For more info, read the notes of this method on CC3Node.
 */

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
    
    int32 velocityIterations = 8;
    int32 positionIterations = 3;
    
    if (!previousTime) {
        deltaTime = 0.1;
    }else{
        deltaTime = CACurrentMediaTime()-previousTime;
    }
    
    _world->Step(deltaTime, velocityIterations, positionIterations);

    
    //Iterate over the bodies in the physics world
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
    {
//        NSLog(@"body position x:%f y:%f", b->GetPosition().x, b->GetPosition().y);
        
        
        if (b->GetType() == b2_dynamicBody && b->GetUserData() != NULL) {
            
            CGSize winSz = [[CCDirector sharedDirector] winSizeInPixels];
            GLfloat aspect = winSz.width / winSz.height;
            
            // Express touchPoint X & Y as fractions of the window size
            GLfloat xtp = ((2.0 * b->GetPosition().x*PTM_RATIO) / winSz.width) - 1;
            GLfloat ytp = ((2.0 * b->GetPosition().y*PTM_RATIO) / winSz.height) - 1;
            
            // Get the tangent of half of the camera's field of view angle
            GLfloat effectiveFOV = self.activeCamera.fieldOfView / self.uniformScale;
            GLfloat halfFOV = effectiveFOV / 2.0;
            GLfloat tanHalfFOV = tanf(DegreesToRadians(halfFOV));
            
            // Get the distance from the camera to the projection plane
            GLfloat zCam = self.activeCamera.globalLocation.z;
            
            // Calc the X & Y coordinates on the Z = z plane using trig and similar triangles
            // Change location for cocos3d according to box2d
            CC3Vector tp3D = cc3v(tanHalfFOV * xtp * aspect * zCam,
                                  tanHalfFOV * ytp * zCam,
                                  z);
            
            //Synchronize the mesh position with the corresponding body
            CC3MeshNode *myActor = (CC3MeshNode*)b->GetUserData();
            myActor.location = cc3v(tp3D.x,tp3D.y,tp3D.z);
        }
    }
    
    for (b2Contact* contact = _world->GetContactList(); contact; contact = contact->GetNext()){
//        NSLog(@"Contact!");
        
        b2Body *a = contact->GetFixtureA()->GetBody();
        b2Body *b = contact->GetFixtureB()->GetBody();
        
        [self handleContactByReverseForce:a andB:b];
//        [self handleContactByReverseVelocity:a andB:b];
    }
    
    previousTime = CACurrentMediaTime();
}

- (void)handleContactByReverseForce:(b2Body*)a andB:(b2Body*)b
{
    double ax = a->GetPosition().x;
    double ay = a->GetPosition().y;
    double bx = b->GetPosition().x;
    double by = b->GetPosition().y;
    double distance = sqrt((ax-bx)*(ax-bx)+(ay-by)*(ay-by));
    //        NSLog(@"dis: %f", distance);
    
    double originLength = 10;
    double fx = ax-bx;
    double fy = bx-by;
    
    if (distance < originLength) {
        a->ApplyForce(b2Vec2(fx*10, fy*10), a->GetLocalCenter());
        b->ApplyForce(b2Vec2(-fx*10, -fy*10), b->GetLocalCenter());
    }
}

- (void)handleContactByReverseVelocity:(b2Body*)a andB:(b2Body*)b
{
    double damperFactor = -0.6;
    
    if (a->GetType() == b2_dynamicBody) {
        double vx = a->GetLinearVelocity().x;
        double vy = a->GetLinearVelocity().y;
        
        a->SetLinearVelocity(b2Vec2(damperFactor*vx, damperFactor*vy));
        
    }
    if (b->GetType() == b2_dynamicBody) {
        double vx = b->GetLinearVelocity().x;
        double vy = b->GetLinearVelocity().y;
        
        b->SetLinearVelocity(b2Vec2(damperFactor*vx, damperFactor*vy));
        
    }

}

#pragma mark camera

/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (ccTime) dt {
	CC3Camera* cam = self.activeCamera;
	
#define LOCATION_CONTROL_SPEED 5
#define DIRECTION_CONTROL_SPEED 10
	// Update the location of the player (the camera)
    // Right buttom
	if ( _playerLocationControl.x || _playerLocationControl.y ) {
//		NSLog(@"Player Location Control");
        
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(_playerLocationControl, dt * LOCATION_CONTROL_SPEED);
        double factor = 10;
//        NSLog(@"Delta x:%f y:%f", delta.x, delta.y);
        
		// We want to move the camera forward and backward, and side-to-side,
		// from the camera's (the user's) point of view.
		// Forward and backward will be along the globalForwardDirection of the camera,
		// and side-to-side will be along the globalRightDirection of the camera.
		// These two directions are scaled by Y and X delta components respectively, which
		// in turn are set by the joystick, and combined into a single directional vector.
		// This represents the movement of the camera. The new location is simply the old
		// camera location plus the movement.
        // globalRightDirection - x, globalForwardDirection - y, globalUpDirection - z
        
		CC3Vector moveVector = CC3VectorAdd(CC3VectorScaleUniform(cam.globalRightDirection, delta.x*factor),CC3VectorScaleUniform(cam.globalForwardDirection, delta.y*factor));
        
        
		cam.location = CC3VectorAdd(cam.location, moveVector); //change camera location
	}
    
	// Update the direction the camera is pointing by panning and inclining using rotation.
	if ( _playerDirectionControl.x || _playerDirectionControl.y ) {
        NSLog(@"Player Direction Control");
        
		CGPoint delta = ccpMult(_playerDirectionControl, dt * DIRECTION_CONTROL_SPEED);		// Factor to set speed of rotation.
        
        //Camera rotation
		CC3Vector camRot = cam.rotation;
		camRot.y -= delta.x;
		camRot.x += delta.y;
		cam.rotation = camRot;
        
        
	}
}


/**
 * When the user hits the switch-camera-target button, cycle through a series of four
 * different camera targets. The actual movement of the camera to home in on a new target
 * is handled by a CCActionInterval, so that the movement appears smooth and animated.
 */
-(void) switchCameraTarget {
    if (_cameraTarget == ground) {
        _cameraTarget = earth;
    }else{
        _cameraTarget = ground;
	}
    
	CC3Camera* cam = self.activeCamera;
	cam.target = nil;			// Ensure the camera is not locked to the original target
	[cam stopAllActions];
	[cam runAction: [CC3RotateToLookAt actionWithDuration: 2.0 targetLocation: _cameraTarget.globalLocation]];
    NSLog(@"Cam x:%f y:%f z:%f \nTarget: x:%f y:%f z:%f", cam.globalLocation.x, cam.globalLocation.y, cam.globalLocation.z, _camTarget.globalLocation.x, _camTarget.globalLocation.y, _camTarget.globalLocation.z);
	LogInfo(@"Camera target toggled to %@", _cameraTarget);
}


/**
 * Cycle between current camera view and two views showing the complete scene.
 * When the full scene is showing, a wireframe is drawn so we can easily see its extent.
 */
-(void) cycleZoom {
#define kCameraMoveDuration				3.0

	CC3Camera* cam = self.activeCamera;
	[cam stopAllActions];						// Stop any current camera motion
	switch (_cameraZoomType) {
            
            // Currently in normal view. Remember orientation of camera, turn on wireframe
            // and move away from the scene along the line between the center of the scene
            // and the camera until everything in the scene is visible.
		case kCameraZoomNone:
			_lastCameraOrientation = CC3RayFromLocDir(cam.globalLocation, cam.globalForwardDirection);
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration toShowAllOf: self];
			_cameraZoomType = kCameraZoomStraightBack;	// Mark new state
			break;
            
            // Currently looking at the full scene.
            // Move to view the scene from a different direction.
		case kCameraZoomStraightBack:
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration
					  toShowAllOf: self
					fromDirection: cc3v(-1.0, 1.0, 1.0)];
			_cameraZoomType = kCameraZoomBackTopRight;	// Mark new state
			break;
            
            // Currently in second full-scene view.
            // Turn off wireframe and move back to the original location and orientation.
		case kCameraZoomBackTopRight:
		default:
			self.shouldDrawDescriptor = NO;
			self.shouldDrawWireframeBox = NO;
			[cam runAction: [CC3MoveTo actionWithDuration: kCameraMoveDuration
												   moveTo: _lastCameraOrientation.startLocation]];
			[cam runAction: [CC3RotateToLookTowards actionWithDuration: kCameraMoveDuration
													  forwardDirection: _lastCameraOrientation.direction]];
			_cameraZoomType = kCameraZoomNone;	// Mark new state
			break;
	}
}


#pragma mark Scene opening and closing

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene is first displayed.
 *
 * This method is a good place to invoke one of CC3Camera moveToShowAllOf:... family
 * of methods, used to cause the camera to automatically focus on and frame a particular
 * node, or the entire scene.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onOpen {
	
	// Add additional scene content dynamically and asynchronously on a background thread
	// after the scene is open and rendering has begun on the rendering thread. We use the
	// GL backgrounder provided by the viewSurfaceManager to accomplish this. Asynchronous
	// loading must be initiated after the scene has been attached to the view. It cannot
	// be started in the initializeScene method. However, you do not need to start it only
	// in this onOpen method. You can use the code here as a template for use whenever your
	// app requires background content loading.
	[self.viewSurfaceManager.backgrounder runBlock: ^{
		[self addSceneContentAsynchronously];
	}];

	// Move the camera to frame the scene. The resulting configuration of the camera is output as
	// a [debug] log message, so you know where the camera needs to be in order to view your scene.
	[self.activeCamera moveWithDuration: 3.0 toShowAllOf: self withPadding: 0.5f];

	// Uncomment this line to draw the bounding box of the scene.
//	self.shouldDrawWireframeBox = YES;
}

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene has been removed from display.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onClose {}


#pragma mark Drawing

/**
 * Template method that draws the content of the scene.
 *
 * This method is invoked automatically by the drawScene method, once the 3D environment has
 * been established. Once this method is complete, the 2D rendering environment will be
 * re-established automatically, and any 2D billboard overlays will be rendered. This method
 * does not need to take care of any of this set-up and tear-down.
 *
 * This implementation turns on the lighting contained within the scene, and performs a single
 * rendering pass of the nodes in the scene by invoking the visit: method on the specified
 * visitor, with this scene as the argument.
 *
 * You can override this method to customize the scene rendering flow, such as performing
 * multiple rendering passes on different surfaces, or adding post-processing effects, using
 * the template methods mentioned above.
 *
 * Rendering output is directed to the render surface held in the renderSurface property of
 * the visitor. By default, that is set to the render surface held in the viewSurface property
 * of this scene. If you override this method, you can set the renderSurface property of the
 * visitor to another surface, and then invoke this superclass implementation, to render this
 * scene to a texture for later processing.
 *
 * When overriding the drawSceneContentWithVisitor: method with your own specialized rendering,
 * steps, be careful to avoid recursive loops when rendering to textures and environment maps.
 * For example, you might typically override drawSceneContentWithVisitor: to include steps to
 * render environment maps for reflections, etc. In that case, you should also override the
 * drawSceneContentForEnvironmentMapWithVisitor: to render the scene without those additional
 * steps, to avoid the inadvertenly invoking an infinite recursive rendering of a scene to a
 * texture while the scene is already being rendered to that texture.
 *
 * To maintain performance, by default, the depth buffer of the surface is not specifically
 * cleared when 3D drawing begins. If this scene is drawing to a surface that already has
 * depth information rendered, you can override this method and clear the depth buffer before
 * continuing with 3D drawing, by invoking clearDepthContent on the renderSurface of the visitor,
 * and then invoking this superclass implementation, or continuing with your own drawing logic.
 *
 * Examples of when the depth buffer should be cleared are when this scene is being drawn
 * on top of other 3D content (as in a sub-window), or when any 2D content that is rendered
 * behind the scene makes use of depth drawing. See also the closeDepthTestWithVisitor:
 * method for more info about managing the depth buffer.
 */
-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self illuminateWithVisitor: visitor];		// Light up your world!
	[visitor visit: self.backdrop];				// Draw the backdrop if it exists
	[visitor visit: self];						// Draw the scene components
	[self drawShadows];							// Shadows are drawn with a different visitor
}

#pragma mark Handling touch events 

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer
 * has indicated that it is interested in receiving touch events, and is handling them.
 *
 * Override this method to handle touch events, or remove this method to make use of
 * the superclass behaviour of selecting 3D nodes on each touch-down event.
 *
 * This method is not invoked when gestures are used for user interaction. Your custom
 * CC3Layer processes gestures and invokes higher-level application-defined behaviour
 * on this customized CC3Scene subclass.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {

	//Add a new body/atlas sprite at the touched location
	NSLog(@"Touch %u %f %f", touchType, touchPoint.x, touchPoint.y);
    
    //touch to make racecar jump in +y direction
    earthBody->ApplyForce(b2Vec2(0, 200), earthBody->GetLocalCenter());
    
    [self pickNodeFromTapAt:touchPoint];
    
}

/*
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Override this method to perform activities on 3D nodes that have been picked by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
//    NSLog(@"touch!");
    NSLog(@"Node Selected: %@", aNode.name);
}

- (void)gyroscope : (double)roll andPitch:(double)pitch andYaw:(double)yaw
{
    //roll left-right(- +), pitch up-down(- +)
    //roll in x-direction, pitch in z-direction
//    NSLog(@"Roll:%f Pitch:%f Yaw:%f", roll, pitch, yaw);
//    NSLog(@"z: %f", z);
    
    z += pitch/10;
    earthBody->ApplyForce(b2Vec2(roll*10, 0), earthBody->GetLocalCenter());

//    [self moveCameraAlongZ];
}

- (void)moveCameraAlongZ
{
    CC3Camera* activeCam = self.activeCamera;
    CC3Vector moveVector = cc3v(0, 0, earth.globalLocation.z/100);
    activeCam.location = CC3VectorAdd(activeCam.location, moveVector);
}

#pragma mark Game Logic
- (void)checkGameLogic
{
    //earth fall out of the ground
    if(earth.globalLocation.y < -20){
        [self loseLife];
        
        //remove earth
        [self removeChild:earth];
        _world->DestroyBody(earthBody);
        //recreate earth
        [self addEarth];
        self.activeCamera.target = earth;
    }
}

- (void)resumeGame
{
    [self resumeAllActions];
}

- (void)loseLife
{
    [(Cocos3dLayer*)self.cc3Layer updateLabel];
}

@end

