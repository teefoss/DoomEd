#import "FloatingPanel.h"

@implementation FloatingPanel

- initContent:(NXRect)contentRect
style:(int)aStyle
buttonMask:(int)mask
defer:(BOOL)flag
{
	[super initWithContentRect:contentRect styleMask:aStyle backing:mask defer:flag];
//	[super
//		initContent:	contentRect
//		style:		aStyle
//		backing:		bufferingType
//		buttonMask:	mask
//		defer:		flag
//	];
	
	[self setFloatingPanel: YES];
	
	return self;
}

#if 0
- (BOOL)canBecomeKeyWindow
{
	return NO;
}
#endif

- (BOOL)canBecomeMainWindow
{
	return NO;
}

@end

