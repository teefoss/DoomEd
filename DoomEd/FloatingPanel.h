#import <appkit/appkit.h>
#import "NXConvert.h"

@interface FloatingPanel: Panel

- initContent:(NXRect)contentRect
		style:(int)aStyle
   buttonMask:(int)mask
		defer:(BOOL)flag;

@end
