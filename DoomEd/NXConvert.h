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



NSInteger NXRunAlertPanel (const char *title, const char *msgFormat, const char *defaultButton, const char *alternateButton, const char *otherButton, ...);
void NXFreeAlertPanel(id panel);

NSString 	*CastNSString(const char *cstring);
const char 	*CastCString(NSString *string);

void 	NXBeep(void);
void	NXSetRect(NXRect *aRect, NXCoord x, NXCoord y, NXCoord width, NXCoord height);
NSRect  *NXUnionRect(const NSRect *aRect, const NSRect *bRect);

#endif /* NXConvert_h */
