//
//  icoView.m
//  ico
//
//  Created by James Yuzawa on 9/25/11.
//  Copyright 2012 James Yuzawa. All rights reserved.
//

#import "icoView.h"
#import "polyinfo.h"

@implementation icoView


static NSString * const MyModuleName = @"com.jyuzawa.icosaver";


static Polyinfo polygons[] = {
#include "allobjs.h"
};

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
	
    if (self) 
	{
		ScreenSaverDefaults *defaults;
		
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
		
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:1], @"obj",
									nil]];
		
		NSOpenGLPixelFormatAttribute attributes[] = { 
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 16,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
			0 };  
		NSOpenGLPixelFormat *format;
		
		format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
		
		glView = [[NSOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		
		vx=vy=10;
		
		if (!glView)
		{             
			NSLog( @"Couldn't initialize OpenGL view." );
			[self autorelease];
			return nil;
		} 
		clr=0.0f;
		if(isPreview){
			posx=posy=10;
			icosize=50;
		}else{
			icosize=300;//frame.size.width/10;
			posx=((float)(rand() / (float)RAND_MAX) * (float)(frame.size.width-icosize-15))+15;
			posy=((float)(rand() / (float)RAND_MAX) * (float)(frame.size.height-icosize-15))+15;
		}
		
		[self addSubview:glView]; 
		[self setUpOpenGL]; 
		
		[self setAnimationTimeInterval:1/20.0];
	}
	
	return self;
}

- (void)dealloc
{
	[glView removeFromSuperview];
	[glView release];
	[super dealloc];
}

- (void)setUpOpenGL
{  
	[[glView openGLContext] makeCurrentContext];
	
	glShadeModel( GL_SMOOTH );
	glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	glClearDepth( 1.0f ); 
	glEnable( GL_DEPTH_TEST );
	glDepthFunc( GL_LEQUAL );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	rotation = 0.0f;
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	selobj=(int)[defaults integerForKey:@"obj"];
}

- (void)setFrameSize:(NSSize)siz
{
	NSSize newSize = NSMakeSize(icosize,icosize);
	[super setFrameSize:siz];
	[glView setFrameSize:newSize]; 
	
	[[glView openGLContext] makeCurrentContext];
	
	
	
	// Reshape
	glViewport( 0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluPerspective( 45.0f, (GLfloat)newSize.width / (GLfloat)newSize.height, 0.1f, 100.0f );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();              
	
	[[glView openGLContext] update];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	[[glView openGLContext] makeCurrentContext];
	Polyinfo pl=polygons[selobj];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
	
	glLoadIdentity(); 
	glEnableClientState(GL_VERTEX_ARRAY);
	glTranslatef(0.0f,0.0f,-2.6f);
	glRotatef(rotation,1.0f,1.0f,1.0f);
	
	glVertexPointer(3, GL_FLOAT, 0, pl.verts);
	float cred,cgrn,cblu;
	HSVtoRGB(&cred,&cgrn,&cblu,clr,1.0f,1.0f);
	glColor3f( cred,cgrn,cblu);
	int i=0;
	while(pl.f[i]!=255) 
	{	
		glDrawElements(GL_POLYGON, (GLsizei)(pl.f[i]), GL_UNSIGNED_BYTE, &(pl.f[i+1]));
		i+=(int)(pl.f[i])+1;
	}
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glFlush();
}

- (void)animateOneFrame
{
	// Adjust our state 
	rotation += 4.0f;
	clr+=1.0f;
	if(clr>350.0f) clr=0.0f;
	
	[glView setFrameOrigin:NSMakePoint(posx, posy)];
	posy+=vy;
	posx+=vx;
	NSSize sz=[self frame].size; 
	if(posx>(sz.width-icosize)||posx<0) vx *= -1;
	if(posy>(sz.height-icosize)||posy<0) vy *= -1;
	// Redraw
	[self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
	ScreenSaverDefaults *defaults;
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
    if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"PrefSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	[objsel selectItemAtIndex:[defaults integerForKey:@"obj"]];
	
	return configSheet;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

- (IBAction)cancelClick:(id)sender
{
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)okClick:(id)sender
{
	ScreenSaverDefaults *defaults;
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	
	// Update our defaults
	[defaults setInteger:[objsel indexOfSelectedItem] forKey:@"obj"];
	
	selobj=(int)[objsel indexOfSelectedItem];
	[defaults synchronize];
	[[NSApplication sharedApplication] endSheet:configSheet];
}

@end