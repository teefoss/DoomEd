#import	"Remapper.h"
#import <appkit/appkit.h>
#import "NXConvert.h"

extern	id	thingRemapper_i;

@interface ThingRemapper:Object <Remapper>
{
	id	remapper_i;
}

- menuTarget:sender;
- addToList:(char *)orgname to:(char *)newname;

@end
