#import <appkit/appkit.h>
#import "NXConvert.h"

@interface PopScrollView : ScrollView
{
	NSPopUpButton	*button1, *button2;
}

- initFrame:(const NXRect *)frameRect button1: b1 button2: b2;
//- tile;

@end
