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

#import "Cocos3dScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"

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
}
@end

@implementation Cocos3dScene

-(void) dealloc {
	[super dealloc];
}

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
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
	// Create the camera, place it back a bit, and add it to the world
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 10.0 );
	[self addChild: cam];
    
	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the world
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
    
  	CC3Light* lamp2 = [CC3Light nodeWithName: @"Lamp"];
	lamp2.location = cc3v( 0.0, 1.0, -5.0 );
	lamp2.isDirectionalOnly = NO;
	[cam addChild: lamp2];
    
	// This is the simplest way to load a POD resource file and add the
	// nodes to the CC3World, if no customized resource subclass is needed.
//    [self addContentFromPODFile:@"Balls.pod" withName:@"BeachBall"];
	[self addContentFromPODFile: @"Balls.pod"];
    [self addContentFromPODFile: @"earth.pod"];

    
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantContent];
	
    [self selectShaderPrograms];
    
	[self createBoundingVolumes];

    
    
    CC3MeshNode* globe = (CC3MeshNode*)[self getNodeNamed: @"Globe"];
    [self removeChild:globe];
    
	CC3MeshNode* bBall = (CC3MeshNode*)[self getNodeNamed: @"BeachBall"];

//    CC3MeshNode* bBall = (CC3MeshNode*)[self getNodeNamed: @"Sphere"];
    CC3MeshNode* earth = (CC3MeshNode*)[self getNodeNamed: @"Sphere"];

    
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
    
    
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // The body is also added to the world.
    b2Body* groundBody = _world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;
    
    // bottom
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    ///
    
    
    
    
    Cocos3dAppDelegate* mainDelegate = (Cocos3dAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // Create sprite and add it to the layer
//    CC3Texture* bgTex = [CC3Texture textureFromFile:@"Default.png"];
//    
//    CGSize rectSize = CGSizeMake(6, 10);
//    CC3PlaneNode* spritePlane = [CC3PlaneNode node];
//    [spritePlane populateAsRectangleWithSize: rectSize
//                                    andPivot: ccp(rectSize.width / 2.0, rectSize.height / 2.0)
//                                 withTexture: bgTex
//                               invertTexture: TRUE];
//    spritePlane.location = cc3v( 0.0, 0.0, -1 );
//	[self addChild: spritePlane];
    
    
    
    
// EARTH
    //create earth body
    b2BodyDef earthBodyDef;
    earthBodyDef.type = b2_dynamicBody;
    earthBodyDef.position.Set(100/PTM_RATIO, 400/PTM_RATIO);
    earthBodyDef.userData = earth;
    earthBodyDef.linearVelocity = b2Vec2(10.0f, 0.0f);
    b2Body * earthBody = _world->CreateBody(&earthBodyDef);
    

    // Create circle shape
    b2CircleShape circle;
    circle.m_radius = screenSize.width/5/PTM_RATIO;

    // Create shape definition and add to body
    b2FixtureDef earthShapeDef;
    earthShapeDef.shape = &circle;
    earthShapeDef.density = 0.0f;
//    earthShapeDef.friction = 0.2f;
    earthShapeDef.restitution = 0.35f;
    earthShapeDef.isSensor = FALSE;
    _earthFixture = earthBody->CreateFixture(&earthShapeDef);

    
    
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


    previousTime = nil;

/*
    CGSize screenSize = [CCDirector sharedDirector].winSize;

	// Create the camera, place it back a bit, and add it to the scene
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 6.0 );
	[self addChild: cam];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];

	// This is the simplest way to load a POD resource file and add the
	// nodes to the CC3Scene, if no customized resource subclass is needed.
//	[self addContentFromPODFile: @"hello-world.pod"];
    [self addContentFromPODResourceFile: @"earth.pod"];
	
	// Create OpenGL buffers for the vertex arrays to keep things fast and efficient, and to
	// save memory, release the vertex content in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantContent];
	
	// Select an appropriate shader program for each mesh node in this scene now. If this step
	// is omitted, a shader program will be selected for each mesh node the first time that mesh
	// node is drawn. Doing it now adds some additional time up front, but avoids potential pauses
	// as each shader program is loaded as needed the first time it is needed during drawing.
	[self selectShaderPrograms];

	// With complex scenes, the drawing of objects that are not within view of the camera will
	// consume GPU resources unnecessarily, and potentially degrading app performance. We can
	// avoid drawing objects that are not within view of the camera by assigning a bounding
	// volume to each mesh node. Once assigned, the bounding volume is automatically checked
	// to see if it intersects the camera's frustum before the mesh node is drawn. If the node's
	// bounding volume intersects the camera frustum, the node will be drawn. If the bounding
	// volume does not intersect the camera's frustum, the node will not be visible to the camera,
	// and the node will not be drawn. Bounding volumes can also be used for collision detection
	// between nodes. You can create bounding volumes automatically for most rigid (non-skinned)
	// objects by using the createBoundingVolumes on a node. This will create bounding volumes
	// for all decendant rigid mesh nodes of that node. Invoking the method on your scene will
	// create bounding volumes for all rigid mesh nodes in the scene. Bounding volumes are not
	// automatically created for skinned meshes that modify vertices using bones. Because the
	// vertices can be moved arbitrarily by the bones, you must create and assign bounding
	// volumes to skinned mesh nodes yourself, by determining the extent of the bounding
	// volume you need, and creating a bounding volume that matches it. Finally, checking
	// bounding volumes involves a small computation cost. For objects that you know will be
	// in front of the camera at all times, you can skip creating a bounding volume for that
	// node, letting it be drawn on each frame.
	[self createBoundingVolumes];

	
	// ------------------------------------------
	
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
    
    
    y = 10;
//    [self drawLine];
//    [self drawCube];
//    [self drawSphere];
    
    
    CC3MeshNode* earth = (CC3MeshNode*)[self getNodeNamed: @"Sphere"];
    [earth setRotation:cc3v(-20.0, 0.0, 0.0)];
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                          rotateBy: cc3v(0.0, 30.0, 0.0)];
    [earth runAction: [CCRepeatForever actionWithAction: partialRot]];
    
    
    ////Box 2D
    // Define the gravity vector.
    b2Vec2 gravity;
    gravity.Set(0.0f, -1.0f);
    
    // Do we want to let bodies sleep?
    // This will speed up the physics simulation
    // note * bodies seem to sleep when at rest for too long and will only wake up again on collision?
    bool doSleep = false;
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    _world = new b2World(gravity, doSleep);
    _world->SetContinuousPhysics(false);
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // The body is also added to the world.
    b2Body* groundBody = _world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;
    
    // bottom
    groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
    groundBody->CreateFixture(&groundBox,0);
    ///
    
//
//	// And to add some dynamism, we'll animate the 'hello, world' message
//	// using a couple of actions...
//	
//	// Fetch the 'hello, world' object that was loaded from the POD file and start it rotating
//	CC3MeshNode* helloTxt = (CC3MeshNode*)[self getNodeNamed: @"Hello"];
//	CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
//														  rotateBy: cc3v(0.0, 30.0, 0.0)];
//	[helloTxt runAction: [CCRepeatForever actionWithAction: partialRot]];
//	
//	// To make things a bit more appealing, set up a repeating up/down cycle to
//	// change the color of the text from the original red to blue, and back again.
//	GLfloat tintTime = 8.0f;
//	ccColor3B startColor = helloTxt.color;
//	ccColor3B endColor = { 50, 0, 200 };
//	CCActionInterval* tintDown = [CCTintTo actionWithDuration: tintTime
//														  red: endColor.r
//														green: endColor.g
//														 blue: endColor.b];
//	CCActionInterval* tintUp = [CCTintTo actionWithDuration: tintTime
//														red: startColor.r
//													  green: startColor.g
//													   blue: startColor.b];
//	 CCActionInterval* tintCycle = [CCSequence actionOne: tintDown two: tintUp];
//	[helloTxt runAction: [CCRepeatForever actionWithAction: tintCycle]];
*/
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
    Cocos3dAppDelegate* mainDelegate = (Cocos3dAppDelegate *)[[UIApplication sharedApplication]delegate];
//    b2Vec2 gravity = b2Vec2(mainDelegate.wGx,mainDelegate.wGy);
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    _world->SetGravity(gravity);
//    NSLog(@"update! before");

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
//    NSLog(@"update! after");

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
        if (b->GetUserData() != NULL) {
            
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
            
            // Calc the X & Y coordinates on the Z = 0 plane using trig and similar triangles
            CC3Vector tp3D = cc3v(tanHalfFOV * xtp * aspect * zCam,
                                  tanHalfFOV * ytp * zCam,
                                  0.0f);
            
            //Synchronize the mesh position with the corresponding body
            CC3MeshNode *myActor = (CC3MeshNode*)b->GetUserData();
            myActor.location = cc3v(tp3D.x,tp3D.y,0);
        }
    }
    
    for (b2Contact* contact = _world->GetContactList(); contact; contact = contact->GetNext()){

        b2Body *a = contact->GetFixtureA()->GetBody();
        b2Body *b = contact->GetFixtureB()->GetBody();

        double ax = a->GetPosition().x;
        double ay = a->GetPosition().y;
        double bx = b->GetPosition().x;
        double by = b->GetPosition().y;
        double distance = sqrt((ax-bx)*(ax-bx)+(ay-by)*(ay-by));
        NSLog(@"dis: %f", distance);
        
        double originLength = 10;
        double fx = ax-bx;
        double fy = bx-by;
        
        if (distance < originLength) {
            a->ApplyForce(b2Vec2(fx*100, fy*100), a->GetLocalCenter());
            b->ApplyForce(b2Vec2(-fx*100, -fy*100), b->GetLocalCenter());
        }
    }
    
    previousTime = CACurrentMediaTime();
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
	NSLog(@"Touch %@ %d %d", touchType, touchPoint.x, touchPoint.y);
}

/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Override this method to perform activities on 3D nodes that have been picked by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {}

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
    CC3Vector a = CC3VectorMake(10.0, 10.0, 10.0);
    CC3Vector b = CC3VectorMake(20.0, 20.0, 20.0);
    CC3Box box = CC3BoxFromMinMax(a, b);
    
    CC3BoxNode *cube = [[CC3BoxNode alloc] init];
    [cube setColor:ccc3(255.0, 0.0, 0.0)];
    [cube populateAsSolidBox:box];
    [cube setLocation:CC3VectorMake(10, y, 10)];
    
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
    														  rotateBy: cc3v(0.0, 10.0, 5.0)];
    [cube runAction: [CCRepeatForever actionWithAction: partialRot]];
    
    [self addChild:cube];

}

- (void)drawSphere
{
    CC3Vector center = CC3VectorMake(5.0, 5.0, 5.0);
    CC3Sphere box = CC3SphereMake(center, 2.0);
    
    CC3SphereNode *sphere = [[CC3SphereNode alloc] init];
    [sphere setColor:ccc3(0.0, 100.0, 0.0)];
    [sphere populateAsSphereWithRadius:3.0 andTessellation:CC3TessellationMake(1, 2)];
//    [sphere a]
    
    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                          rotateBy: cc3v(0.0, 10.0, 5.0)];
    [sphere runAction: [CCRepeatForever actionWithAction: partialRot]];
    
    [self addChild:sphere];
    
}

- (void)addPhysics
{
//    CC3Node a = [[CC3Node alloc] init];
//    a.
}


//-(void) addNewSpriteAtPosition:(CGPoint)p
//{
//	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
//	// Define the dynamic body.
//	//Set up a 1m squared box in the physics world
//	b2BodyDef bodyDef;
//	bodyDef.type = b2_dynamicBody;
//	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
//	b2Body *body = _world->CreateBody(&bodyDef);
//	
//	// Define another box shape for our dynamic body.
//	b2PolygonShape dynamicBox;
//	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
//	
//	// Define the dynamic body fixture.
//	b2FixtureDef fixtureDef;
//	fixtureDef.shape = &dynamicBox;
//	fixtureDef.density = 1.0f;
//	fixtureDef.friction = 0.3f;
//	body->CreateFixture(&fixtureDef);
//	
//    
////	CC3Node *parent = [[CC3Node alloc] init];
//	
//	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
//	//just randomly picking one of the images
//	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
//	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
//	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];
//	[parent addChild:sprite];
//	[self addChild:parent];
//    
//	[sprite setPTMRatio:PTM_RATIO];
//	[sprite setB2Body:body];
//	[sprite setPosition: ccp( p.x, p.y)];
//    
//    
//    
//}





//-(void) updateScene: (ccTime) dt
//{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/

//    NSLog(@"update!");
    
//	int32 velocityIterations = 8;
//	int32 positionIterations = 1;
//	
//	// Instruct the world to perform a single step of simulation. It is
//	// generally best to keep the time step and iterations fixed.
//	_world->Step(dt, velocityIterations, positionIterations);
//}

//- (void)updateScene:(ccTime)dt
//{
//    y -= 10;
//}


@end

