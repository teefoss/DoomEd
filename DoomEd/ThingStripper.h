
#import <appkit/appkit.h>
#import "NXConvert.h"

typedef struct
{
	int		value;
	char		desc[32];
} thingstrip_t;

#define	THINGSTRIPNAME	"ThingStripper"

@interface ThingStripper:Object
{
	id	thingBrowser_i;		// nib outlets
	id	thingStripPanel_i;

	id	thingList_i;
}

- displayPanel:sender;
- addThing:sender;
- deleteThing:sender;
- doStrippingAllMaps:sender;
- doStrippingOneMap:sender;

@end
