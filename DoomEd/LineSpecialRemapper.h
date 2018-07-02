#import	"Remapper.h"
#import <appkit/appkit.h>
#import "NXConvert.h"

extern	id	lineSpecialRemapper_i;

@interface LineSpecialRemapper:Object <Remapper>
{
	id	remapper_i;
}

- addToList:(char *)orgname to:(char *)newname;
- menuTarget:sender;

@end
