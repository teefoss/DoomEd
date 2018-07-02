
#import <appkit/appkit.h>
#import "NXConvert.h"

typedef struct
{
	int	xoff,yoff;
	texpatch_t *p;
} delta_t;

@interface TextureView:View
{
	id	deltaTable;
}


@end
