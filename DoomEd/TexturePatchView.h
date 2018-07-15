
#import <appkit/appkit.h>
#import "NXConvert.h"
#import "Storage.h"

#ifndef	H_DIVIDERT
#define	H_DIVIDERT
typedef struct
{
	int		x,y;
	char		string[32];
} divider_t;
#endif

@interface TexturePatchView:View
{
	Storage	*dividers_i;
}

- addDividerX:(int)x Y:(int)y String:(char *)string;
- dumpDividers;

@end
