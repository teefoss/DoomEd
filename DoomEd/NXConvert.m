//
//  NXConvert.m
//  DoomEd
//
//  Created by Thomas Foster on 7/1/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

#import "NXConvert.h"

NSInteger
NSIntegerNXRunAlertPanel
(const char *title,
 const char *msgFormat,
 const char *defaultButton,
 const char *alternateButton,
 const char *otherButton, ...)
{
	NSAlert *alert;
	alert = [[NSAlert alloc] init];
	
	[alert setMessageText:[NSString stringWithCString:title encoding:NSUTF8StringEncoding]];
	[alert setInformativeText:[NSString stringWithCString:msgFormat encoding:NSUTF8StringEncoding]];
	[alert addButtonWithTitle:[NSString stringWithCString:defaultButton encoding:NSUTF8StringEncoding]];
	[alert addButtonWithTitle:[NSString stringWithCString:alternateButton encoding:NSUTF8StringEncoding]];
	
	return [alert runModal];
}

void NXFreeAlertPanel(id panel)
{
	NSReleaseAlertPanel(panel);
}

NSString *CastNSString(const char *cstring)
{
	NSString *newstring = [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding];
	return newstring;
}

const char *CastCString(NSString *string)
{
	return [string cStringUsingEncoding:NSUTF8StringEncoding];
}

void NXBeep(void)
{
	NSBeep();
}

void NXSetRect(NSRect *aRect, float x, float y, float width, float height)
{
	aRect->origin.x = x;
	aRect->origin.y = y;
	aRect->size.width = width;
	aRect->size.height = height;
}

/**
NXUnionRect() figures the graphic union of two rectangles--that is, the smallest rectangle that completely encloses both. It takes pointers to the two rectangles as arguments and replaces the second rectangle with their union.  If one rectangle has zero (or negative) width or height, bRect is replaced with the other rectangle.  If both of the rectangles have 0 (or negative) width or height, bRect is set to a rectangle with its origin at (0.0, 0.0) and with 0 width and height.
 */
NSRect *NXUnionRect(const NSRect *aRect, const NSRect *bRect)
{
	NSRect rect, *rect_p;
	
	rect = NSUnionRect(*aRect, *bRect);
	rect_p = &rect;
	
	bRect = rect_p;
	return rect_p;
}
