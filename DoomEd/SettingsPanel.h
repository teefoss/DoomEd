
#import <appkit/appkit.h>
#import "NXConvert.h"

extern	id	settingspanel_i;

@interface SettingsPanel:Object
{
	int	segmenttype;
}

- menuTarget:sender;
- (int) segmentType;

@end
