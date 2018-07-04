//
//  postscript.m
//  DoomEd
//
//  Created by Thomas Foster on 7/1/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "postscript.h"
#import "idfunctions.h"

NSColor 		*color;

BOOL			newpath = YES;
NSBezierPath 	*path;

void	AddLineToPath(NSBezierPath *path, int x1, int y1, int x2, int y2)
{
	[path moveToPoint:NSMakePoint(x1, y1)];
	[path lineToPoint:NSMakePoint(x2, y2)];
}

void InitPath(void)
{
	if (!path)
		path = [[NSBezierPath alloc] init];
}

void FinishPath(void)
{
	[path stroke];
	newpath = YES;
	path = nil;
}


void NXFrameRectWithWidth(const NXRect *aRect, NXCoord frameWidth)
{
	box_t box;
	NSRect r;
	
	InitPath();
	r = *aRect;
	BoxFromRect(&box, &r);
	[path setLineWidth:frameWidth];
	
	[path moveToPoint: NSMakePoint(box.left, box.bottom)];
	[path lineToPoint:NSMakePoint(box.right, box.bottom)];
	[path lineToPoint:NSMakePoint(box.right, box.top)];
	[path lineToPoint:NSMakePoint(box.left, box.top)];
	[path closePath];
	FinishPath();
}






#pragma mark - PS

void PSsetrgbcolor(float red, float green, float blue)
{
	color = [NSColor colorWithRed:red green:green blue:blue alpha:1.0];
	[color set];
}


void PSmoveto(float x, float y)
{
	InitPath();

	NSPoint pt;
	
	pt = NSMakePoint(x, y);
	[path moveToPoint:pt];
}

void PSsetlinewidth(float width)
{
	InitPath();
	[path setLineWidth:width];
}

void PSlineto(float x, float y)
{
	InitPath();
	
	NSPoint pt;
	
	pt = NSMakePoint(x, y);
	[path lineToPoint:pt];
}


void	PSstroke(void)
{
	InitPath();
	[path stroke];
}
