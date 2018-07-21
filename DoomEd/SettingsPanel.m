
#import "SettingsPanel.h"
#import "PreferencePanel.h"

id	settingspanel_i;

@implementation SettingsPanel

- init
{
	self = [super init];
	if (!self)
		printf("SettingsPanel init failed");
	settingspanel_i = self;
	segmenttype = ONESIDED_C;
	return self;
}


- menuTarget:sender
{
    return self;
}

- (int) segmentType
{
	return segmenttype;
}

@end
