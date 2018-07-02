
#import <appkit/appkit.h>
#import "NXConvert.h"

#if 0
typedef struct
{
	int		x,y;
	char		string[32];
} divider_t;
#endif

@interface TexturePalView:View
{
	id	dividers_i;
}

- addDividerX:(int)x Y:(int)y String:(char *)string;
- dumpDividers;

@end
