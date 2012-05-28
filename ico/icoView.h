//
//  icoView.h
//  ico
//
//  Created by James Yuzawa on 9/25/11.
//  Copyright 2012 James Yuzawa. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@interface icoView : ScreenSaverView {
	IBOutlet id configSheet;
	IBOutlet id objsel;
@private
	NSOpenGLView *glView;
	GLfloat rotation;
	float posx,posy,vx,vy,icosize,clr;
	int	selobj;
	
}


- (void)setUpOpenGL;
void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );
- (IBAction)cancelClick:(id)sender;

- (IBAction)okClick:(id)sender;

@end
