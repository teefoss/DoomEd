#import <appkit/appkit.h>
#import "MapView.h"

#import "NXConvert.h"

@interface MapWindow: Window <NSWindowDelegate>
{
	NSScrollView		*scrollview_i;
	MapView				*mapview_i;
	
//	id		scalemenu_i, scalebutton_i;
//	NSMenu 				*scalemenu_i;
	NSPopUpButton		*scalebutton_i;
	
	NSPopUpButton		*gridbutton_i;
//	id		gridmenu_i, gridbutton_i;
	
	NXPoint	oldscreenorg;			// taken when resizing to keep view constant
	NXPoint	presizeorigin;			// map view origin before resize
}

- initFromEditWorld;
- mapView;

- scalemenu;
- scalebutton;
- gridmenu;
- gridbutton;

- reDisplay: (NXRect *)dirty;

@end
