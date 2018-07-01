//
//  NXConvert.h
//  DoomEd
//
//  Created by Thomas Foster on 6/29/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

#ifndef NXConvert_h
#define NXConvert_h

#import <Cocoa/Cocoa.h>

#define NXApp 				NSApp
#define NXPoint 			NSPoint
#define NX_SOVER 			NSCompositingOperationSourceOver
#define NX_RGBColorSpace	NSCalibratedRGBColorSpace

typedef NSObject Object;
typedef NSView View;
typedef NSWindow Window;
typedef NSRect NXRect;
typedef NSSound Sound;
typedef NSOpenPanel OpenPanel;

const NSInteger NX_ALERTDEFAULT = NSModalResponseOK;



#pragma mark - Panels

NSInteger NXRunAlertPanel
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

void NXFreeAlertPanel(id panel) { NSReleaseAlertPanel(panel); }


#pragma mark - Strings

NSString *CastNSString(const char *cstring)
{
	NSString *newstring = [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding];
	return newstring;
}

const char *CastCString(NSString *string)
{
	return [string cStringUsingEncoding:NSUTF8StringEncoding];
}



void NXBeep(void) { NSBeep(); }





#endif /* NXConvert_h */
