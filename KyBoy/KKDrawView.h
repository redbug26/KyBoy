//
//  KKDrawSurface.h
//  KyBoy
//
//  Created by Miguel Vanhove on 2018/04/21.
//  Copyright (c) 2018 Miguel Vanhove. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef unsigned long       DWORD;
typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef float               FLOAT;
typedef long LONG;

typedef struct tagPOINT
{
    LONG  x;
    LONG  y;
} POINT;

@class KKDrawSurface;

@interface KKDrawSurface : NSObject
{
@public
    
    DWORD     dwWidth;
    DWORD     dwHeight;
    LONG      xPitch;
    LONG      yPitch;
    DWORD     dwSize;
    WORD*     pSurface;
}

@end

@protocol KKDRaw_Application

@optional
- (int)StylusDown:(POINT)p;
- (int)StylusUp:(POINT)p;
- (int)StylusMove:(POINT)p;
- (int)InitInstance:(id)i;
- (int)ExitInstance:(id)i;
- (int)ProcessNextFrame:(KKDrawSurface*)backbuffer;

@end


@interface KKDrawView : UIView <KKDRaw_Application> {
    
@public 
    bool isPaused;
    KKDrawSurface *m_backbuffer;
}

@property (nonatomic, assign) bool isPaused;

- (id)initWithFrame:(CGRect)frame width:(int)width height:(int)height fps:(int)fps;



- (void)Shutdown;

@end
