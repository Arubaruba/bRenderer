
#import <QuartzCore/QuartzCore.h>

#import "BView.h"
#include "../../bRenderer.h"
//#import "BViewLink.h"

class BViewLink
{
public:
    /* Functions */
    
    /**	@brief Draw the scene using the renderer of this instance
     */
    static void draw(Renderer *r, double currentTime)       { r->draw(currentTime); }
    
};

@interface BView (PrivateMethods)
/* Private methods */
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation BView

/* Set layer class to CAEAGLLayer */
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

/* This function is used to initialize the view when using a XIB */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return [self bInit];
}

/* This function is used to initialize the view when setting the frame manually within code */
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    return [self bInit];
}

/* Initialize OpenGL */
- (id)bInit
{
    if (!self) {
        return nil;
    }
    
    _eaglLayer = (CAEAGLLayer *)self.layer;
    
    // set the surface to not be transparent
    _eaglLayer.opaque = TRUE;
    
    // configure the properties of the canvas
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                     nil];
    
    // create an OpenGL ES 3.0 context
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
	// If Es 3.0 is not supported create an OpenGL ES 2.0 context
	if (_context == nil) {
	  _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	}
    
    // quit if context creation failed
    if (!_context || ![self setContextCurrent]) {
        bRenderer::log("Could not create context!", bRenderer::LM_SYS);
        return nil;
    }
    
    // set view size to fullscreen
    [self setFullscreen];
    
    // default values for our OpenGL buffers
    _defaultFramebuffer = 0;
    _colorRenderbuffer = 0;
    _depthRenderbuffer = 0;
    
    // initial time is not set at this point because the renderer hasn't fully started yet
    _initialTime = -1.0;
    _wasStopped = false;
    
    // handle touches and taps
    _doubleTapRecognized = false;
    _singleTapRecognized = false;
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:YES];
    
    // create buffers
    [self createFramebuffer];

    return self;
}

/* Create frame and renderbuffer and to display in the view */
- (void)createFramebuffer
{
    // make sure the default framebuffer hasn't been declared yet
    assert(_defaultFramebuffer == 0);
    
    // create default framebuffer object and bind it
    glGenFramebuffers(1, &_defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    
    // create color render buffer
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    
    // get the storage from iOS so it can be displayed in the view
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    // get the frame's width and height
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    // attach the color buffer to the framebuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    
    // create a depth renderbuffer
    glGenRenderbuffers(1, &_depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
    // create the storage for the buffer, optimized for depth values, same size as the colorRenderbuffer
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
    // attach the depth buffer to the framebuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);

    // check that the configuration of the framebuffer is valid
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        bRenderer::log("Failed to make complete framebuffer object", bRenderer::LM_SYS);
}

/* Deletion of the framebuffer and all the buffers it contains */
- (void)deleteFramebuffer
{
    // to access any OpenGL methods a valid and current context is needed
    if (_context) {
        [self setContextCurrent];
        
        if (_defaultFramebuffer) {
            glDeleteFramebuffers(1, &_defaultFramebuffer);
            _defaultFramebuffer = 0;
        }

        if (_colorRenderbuffer) {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
        
        if (_depthRenderbuffer) {
            glDeleteRenderbuffers(1, &_depthRenderbuffer);
            _depthRenderbuffer = 0;
        }
    }
}

/* This methdod is called every time the view is redrawn (ideally 60 times a secod)*/
- (void)render
{
    if (_context != nil)
    {
        // handle time
        if(_initialTime < 0)
            _initialTime = (int)CACurrentMediaTime();
        else if (_wasStopped){
            _initialTime += [self getTime]-_stopTime;
            _wasStopped = false;
        }
        
        if (!_defaultFramebuffer)
            [self createFramebuffer];
    
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        
        BViewLink::draw(&Renderer::get(), [self getTime]);
    
        // set current context
        [self setContextCurrent];
        
        // display the color buffer to the screen
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
        
        _stopTime = [self getTime];
    }
    else
        bRenderer::log("Context not set!", bRenderer::LM_SYS);
}

- (void)runRenderer
{
    // check whether the loop is already running
    if(_displayLink == nil)
    {
        // specify render method
        _displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(render)];
        
        // add the display link to the run loop (will be called 60 times per second)
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopRenderer
{
    _wasStopped = true;
    
    if (_displayLink != nil) {
        // if the display link is present, it gets invalidated (loop stops)
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

-(bool)isRunning
{
    return _displayLink != nil;
}

- (int) getViewWidth
{
    return self.frame.size.width;
}

- (int) getViewHeight
{
    return self.frame.size.height;
}

- (int) getViewPositionX
{
    return self.center.x - [self getViewWidth]*0.5;
}

- (int) getViewPositionY
{
    return self.center.y - [self getViewHeight]*0.5;
}

-(double)getTime
{
    return (CACurrentMediaTime() - _initialTime);
}

/* Set view to fullscreen */
- (void) setFullscreen
{
    // set width and height to fullscreen
    _width = self.superview.frame.size.width;
    _height = self.superview.frame.size.height;
    
    if(_width == 0 || _height == 0){
            _width = [[UIScreen mainScreen] bounds].size.width;
            _height = [[UIScreen mainScreen] bounds].size.height;
    }
    
    [self setViewPositionX: 0 setViewPositionY: 0];
    
    CGRect newFrame = self.frame;
    newFrame.size.width = _width;
    newFrame.size.height = _height;
    [self setFrame:newFrame];
    
    // set viewport
    glViewport(0, 0, _width , _height);
}

/* Set width and height of the view */
- (void) setViewWidth:(GLint)w setViewHeight:(GLint)h
{
    _width = w;
    _height = h;
    CGRect newFrame = self.frame;
    newFrame.size.width = w;
    newFrame.size.height = h;
    [self setFrame:newFrame];
    
    // set viewport
    glViewport(0, 0, w , h);
}

/* Set x and y position of the view */
- (void) setViewPositionX:(GLint)x setViewPositionY:(GLint)y
{
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(bool)setContextCurrent
{
    return [EAGLContext setCurrentContext:_context];
}

/* As soon as the view is resized or new subviews are added, this method is called,
 * apparently the framebuffers are invalid in this case so they are deleted and recreated 
 * when entering the render loop again */
- (void)layoutSubviews
{
    [self deleteFramebuffer];
}

/* Receive touch events: Touch began */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    // Reset all taps
    _doubleTapRecognized = false;
    _singleTapRecognized = false;
    
//    bRenderer::log("Touch began");
    
    for (UITouch *touch in touches) {
        
        // get touch position at the beginning of the gesture
        CGPoint beginTouchPosition = [touch locationInView:self];
        
        // add touch
        _touches[(int)touch] = {beginTouchPosition.x, beginTouchPosition.y, beginTouchPosition.x, beginTouchPosition.y, beginTouchPosition.x, beginTouchPosition.y};
    }
}
/* Receive touch events: Touch moved */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
//    bRenderer::log("Touch moved");
    
    for (UITouch *touch in touches) {
        
        // get current touch position
        CGPoint currentTouchPosition = [touch locationInView:self];
        
        // update touch
        _touches[(int)touch].lastPositionX = _touches[(int)touch].currentPositionX;
        _touches[(int)touch].lastPositionY = _touches[(int)touch].currentPositionY;
        _touches[(int)touch].currentPositionX = currentTouchPosition.x;
        _touches[(int)touch].currentPositionY = currentTouchPosition.y;
    }
}
/* Receive touch events: Touch ended */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
//    bRenderer::log("Touch ended");
    
    for (UITouch *touch in touches) {
        
        // remove touch
        _touches.erase((int)touch);
        
        if (touch.tapCount >= 2) {
            // double Tap
            _lastDoubleTapLocation = [touch locationInView:self];
            _doubleTapRecognized = true;
            bRenderer::log("Double Tap");
        }
        else {
            // single Tap
            _lastSingleTapLocation = [touch locationInView:self];
            _singleTapRecognized = true;
            bRenderer::log("Single Tap");
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    bRenderer::log("Touch cancelled");
    
    for (UITouch *touch in touches) {
        
        // remove touch
        _touches.erase((int)touch);
    }
    
}

- (TouchMap)getTouches
{
    return _touches;
}

- (bool)singleTapRecognized
{
    bool x = _singleTapRecognized;
    // reset single tap
    _singleTapRecognized = false;
    return x;
}

- (bool)doubleTapRecognized
{
    bool x = _doubleTapRecognized;
    // reset double tap
    _doubleTapRecognized = false;
    return x;
}

- (Touch)getLastSingleTapLocation
{
    return {_lastSingleTapLocation.x, _lastSingleTapLocation.y, _lastSingleTapLocation.x, _lastSingleTapLocation.y, _lastSingleTapLocation.x, _lastSingleTapLocation.y};
}

- (Touch)getLastDoubleTapLocation
{
    return {_lastDoubleTapLocation.x, _lastDoubleTapLocation.y, _lastDoubleTapLocation.x, _lastDoubleTapLocation.y, _lastSingleTapLocation.x, _lastSingleTapLocation.y};
}

- (void)dealloc
{
    [self deleteFramebuffer];
}


@end
