
#import <appkit/appkit.h>
#import "NXConvert.h"

@interface ThermoView:View
{
	float		thermoWidth;
}

- setThermoWidth:(int)current max:(int)maximum;

@end
