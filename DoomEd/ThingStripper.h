
#import <appkit/appkit.h>
#import "NXConvert.h"

#import "Storage.h"
typedef struct
{
	int		value;
	char		desc[32];
} thingstrip_t;

#define	THINGSTRIPNAME	@"ThingStripper"

@interface ThingStripper:Object <NSWindowDelegate, NSBrowserDelegate>
{
	id	thingBrowser_i;		// nib outlets
	id	thingStripPanel_i;

	Storage	*thingList_i;
}

- displayPanel:sender;
- addThing:sender;
- deleteThing:sender;
- doStrippingAllMaps:sender;
- doStrippingOneMap:sender;

@end
