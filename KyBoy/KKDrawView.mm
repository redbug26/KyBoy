#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#include <mach/mach.h>
#include <mach/mach_time.h>

#include "ArduBoy2.h"

#import "KKDrawView.h"

#import "ToneGenerator.h"


#ifndef DISTRIBUTION

#define CHECK_GL_ERRORS() \
do {                                                                                            	\
GLenum error = glGetError();                                                                	\
if(error != GL_NO_ERROR) {                                                                   	\
NSLog(@"OpenGL: %s [error %d]", __FUNCTION__, (int)error);					\
assert(0); \
} \
} while(false)

#else

#define CHECK_GL_ERRORS()

#endif

unsigned char screen8[128*8];
unsigned char kkButtonState=0;

unsigned int kkFreq=440;
uint64_t kkUntil=0;

static ToneGenerator *gen;


@implementation KKDrawSurface

@end


@interface KKDrawView () {
    
@private
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    GLuint depthRenderbuffer;
    
    BOOL displayLinkSupported;
    id displayLink;
    
    
    float rx, ry;
    int width0, height0;
    
    
    GLuint m_tex;
    
    CADisplayLink* m_displayLink;
}

- (void)blit:(UInt16*)m_pixelData width:(int)m_width height:(int)m_height;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end

@implementation KKDrawView;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame width:(int)width height:(int)height fps:(int)fps {
    
    
    if ((self = [super initWithFrame:frame])) {
        
        gen = [[ToneGenerator alloc] initWithChannels:1];
        [gen playFrequency:200 withAmplitude:0];
        [gen play];
        
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        //        EAGLContext *testContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
        
#if !TARGET_OS_TV
        self.multipleTouchEnabled = YES;
#endif
        
        // ---
        
        displayLinkSupported = FALSE;
        displayLink = nil;
        
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
            displayLinkSupported = TRUE;
        }
        
        //---
        
        glBindTexture(GL_TEXTURE_2D, m_tex);
        
#if TARGET_OS_TV
        // Effect pixel
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
#else
        // Effet blur
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#endif
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        CHECK_GL_ERRORS();
        
        //---
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
        [self layoutSubviews];
        
        m_backbuffer=[[KKDrawSurface alloc] init];
        
        width0=width;
        height0=height;
        
        rx=1.0;
        ry=1.0;
        
        m_backbuffer->dwWidth = width;
        m_backbuffer->dwHeight = height;
        m_backbuffer->dwSize =  m_backbuffer->dwWidth * m_backbuffer->dwHeight * sizeof(WORD);
        m_backbuffer->xPitch = 2;
        m_backbuffer->yPitch = 2 * m_backbuffer->dwWidth;
        m_backbuffer->pSurface = (WORD*)malloc(m_backbuffer->dwSize);
        
        
        
        
        // Dans le viewWillAppear (de préférence)
        
        
        m_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doFrame)];
        m_displayLink.frameInterval = (60/fps); // 60/frameInterval fps
        [m_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        
        setup();
        
        
    }
    
    return self;
}

- (void)setIsPaused:(bool)isPaused0 {
    m_displayLink.paused=isPaused0;
}

- (bool)isPaused {
    return m_displayLink.isPaused;
}

#define gd565RGBToNative(R,G,B) ((((R) & 0xF8) << 8) | (((G) & 0xFC) << 3) | (((B) & 0xF8) >> 3))
#define PutPixel(x,xp,y,yp,buf,r,g,b) buf[(x)*(xp)+(y)*(yp)] = (WORD)gd565RGBToNative((r),(g),(b))

- (void)doFrame {
    
    // Check sound
    
    static BOOL lastState = 0;
    
    if (kkUntil<mach_absolute_time()) {
        if (lastState !=0) {
            lastState = 0;
            printf("stop sound %lld\n", mach_absolute_time());
            [gen playFrequency:200 withAmplitude:0];        // Mute channel
        }
    } else {
        if (lastState == 0) {
            lastState = 1;
            printf("play sound\n");
        }
        
        [gen playFrequency:kkFreq withAmplitude:TG_AMPLITUDE_FULL];
    }
    
    loop(); // In arduboy source code
    
    unsigned char *pix = screen8;
    
    
    WORD *buf=(WORD*)(m_backbuffer->pSurface);
    
    int xPitch = (int)(m_backbuffer->xPitch/2);
    int yPitch = (int)(m_backbuffer->yPitch/2);
    
    for(int y=0;y<64/8;y++) {
        for(int x=0;x<128;x++) {
            unsigned char pixel = *pix;
            pix++;
            
            for(int i=0;i<8;i++) {
                unsigned char col = (pixel & 1);
                
                //                    printf("%d", col);
                
                if (col==1) {
                    PutPixel(x,xPitch,y*8+i,yPitch, buf, 255,255,255);
                } else {
                    PutPixel(x,xPitch,y*8+i,yPitch, buf, 0,0,0);
                }
                
                pixel=pixel/2;
            }
        }
        //            printf("\n");
    }
    
    [self blit:m_backbuffer->pSurface width:m_backbuffer->dwWidth height:m_backbuffer->dwHeight];
    
    
    //        printf("END");
    
    
}


# pragma mark Init



# pragma mark Draw


- (void)blit:(UInt16*)m_pixelData width:(int)m_width height:(int)m_height {
    
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(m_backbuffer->dwWidth, 0.0f, 0.0f, m_backbuffer->dwHeight, 10.0f, -10.0f);
    glMatrixMode(GL_MODELVIEW);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    //    glEnable(GL_BLEND);
    //  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    
    const GLfloat quadVertices[] = {
        0,0,0,
        0,static_cast<GLfloat>(m_backbuffer->dwHeight),0,
        static_cast<GLfloat>(m_backbuffer->dwWidth),0,0,
        static_cast<GLfloat>(m_backbuffer->dwWidth), static_cast<GLfloat>(m_backbuffer->dwHeight),0
    };
    
    
    const GLfloat quadTexCoords[] = {
        rx, ry, rx, 0,  0, ry,  0, 0
    };
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, quadTexCoords);
    
    
    
    // draw text INSTR
    // glBindTexture(GL_TEXTURE_2D, texture[3]);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGB,
                 width0, height0,0,
                 GL_RGB  ,
                 GL_UNSIGNED_SHORT_5_6_5,
                 m_pixelData);
    
    CHECK_GL_ERRORS();
    
    
    glPushMatrix();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glPopMatrix();
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
}

- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    glViewport(0, 0, backingWidth, backingHeight);
    
    CHECK_GL_ERRORS();
    
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)Shutdown {
    NSLog(@"shutdown");
    
    [m_displayLink invalidate]; // Arrete l'affichage et provoque un retaincounte en moins de self
}

- (void)dealloc {
    
    [self destroyFramebuffer];
    
    if ([self respondsToSelector:@selector(ExitInstance:)]) {
        [self ExitInstance:self];
    }
    
    // release textures
    glDeleteTextures(1, &m_tex);
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
}



#pragma mark TouchEvents

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self respondsToSelector:@selector(StylusDown:)]) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInView:self];
        
        POINT p;
        p.x=(location.x*m_backbuffer->dwWidth)/(self.frame.size.width);
        p.y=(location.y*m_backbuffer->dwHeight)/(self.frame.size.height);
        
        [self StylusDown:p];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self respondsToSelector:@selector(StylusMove:)]) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInView:self];
        
        
        POINT p;
        p.x=(location.x*m_backbuffer->dwWidth)/(self.frame.size.width);
        p.y=(location.y*m_backbuffer->dwHeight)/(self.frame.size.height);
        
        [self StylusMove:p];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesCancelled");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self respondsToSelector:@selector(StylusUp:)]) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInView:self];
        
        POINT p;
        p.x=(location.x*m_backbuffer->dwWidth)/(self.frame.size.width);
        p.y=(location.y*m_backbuffer->dwHeight)/(self.frame.size.height);
        
        [self StylusUp:p];
    }
}


@end
