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
#define NXEvent				NSEvent

typedef NSObject Object;
typedef NSView View;
typedef NSWindow Window;
typedef NSPanel Panel;
typedef NSRect NXRect;
typedef NSSound Sound;
typedef NSOpenPanel OpenPanel;
typedef NSColor NXColor;

const NSInteger NX_ALERTDEFAULT = NSModalResponseOK;



NSInteger NXRunAlertPanel (const char *title, const char *msgFormat, const char *defaultButton, const char *alternateButton, const char *otherButton, ...);
void NXFreeAlertPanel(id panel);

NSString 	*CastNSString(const char *cstring);
const char 	*CastCString(NSString *string);

void 	NXBeep(void);
void	NXSetColor(NSColor *color);

void	NXSetRect(NXRect *aRect, NXCoord x, NXCoord y, NXCoord width, NXCoord height);
NSRect  *NXUnionRect(const NSRect *aRect, const NSRect *bRect);
NSRect  *NXIntersectionRect(const NSRect *aRect, NSRect *bRect);
BOOL 	NXIntersectsRect(const NXRect *aRect, const NXRect *bRect);
BOOL 	NXPointInRect(const NXPoint *aPoint, const NXRect *aRect);
void 	NXIntegralRect(NXRect *aRect);
void 	NXRectFill(const NXRect *aRect);
void 	NXRectFillList(const NXRect *rects, int count);

#endif /* NXConvert_h */
