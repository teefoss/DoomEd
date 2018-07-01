//
//  postscript.m
//  DoomEd
//
//  Created by Thomas Foster on 7/1/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "postscript.h"

NSColor 		*color;

BOOL			newpath = YES;
NSBezierPath 	*path;


void InitPath(void)
{
	if (!path)
		path = [[NSBezierPath alloc] init];
}

void finishPath(void)
{
	newpath = YES;
	path = nil;
}

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
