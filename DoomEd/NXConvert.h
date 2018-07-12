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
#define NX_COPY				NSCompositingOperationCopy
#define NX_RGBColorSpace	NSCalibratedRGBColorSpace
#define NXEvent				NSEvent
#define NXSize				NSSize

#define	NX_WHITE	(1.0)
#define	NX_LTGRAY	(2.0/3.0)
#define	NX_DKGRAY	(1.0/3.0)
#define	NX_BLACK	(0.0)

typedef NSObject 		Object;
typedef NSView 			View;
typedef NSWindow 		Window;
typedef NSPanel 		Panel;
typedef NSRect 			NXRect;
typedef NSSound 		Sound;
typedef NSOpenPanel 	OpenPanel;
typedef NSColor 		NXColor;
typedef NSScrollView 	ScrollView;

const NSInteger NX_ALERTDEFAULT = NSModalResponseOK;
const NSInteger NX_ALERTALTERNATE = NSModalResponseCancel;

// Panels
NSInteger NXRunAlertPanel (const char *title, const char *msgFormat, const char *defaultButton, const char *alternateButton, const char *otherButton, ...);
void NXFreeAlertPanel(id panel);

// Converting Strings
NSString 	*CastNSString(const char *cstring);
const char 	*CastCString(NSString *string);

// 		Color
void	NXSetColor(NSColor *color);
NXColor *NXConvertRGBToColor(float red, float green, float blue);
void 	NXConvertColorToRGB(NXColor *color, float *red, float *green, float *blue);

//		Misc
void	NXPing(void);
void 	NXBeep(void);

//		Geometry
void	NXSetRect(NXRect *aRect, NXCoord x, NXCoord y, NXCoord width, NXCoord height);
NSRect  *NXUnionRect(const NSRect *aRect, const NSRect *bRect);
NSRect  *NXIntersectionRect(const NSRect *aRect, NSRect *bRect);
BOOL 	NXIntersectsRect(const NXRect *aRect, const NXRect *bRect);
BOOL 	NXPointInRect(const NXPoint *aPoint, const NXRect *aRect);
void 	NXIntegralRect(NXRect *aRect);
void 	NXRectFill(const NXRect *aRect);
void 	NXRectFillList(const NXRect *rects, int count);


#endif /* NXConvert_h */
