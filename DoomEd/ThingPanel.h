
#import <appkit/appkit.h>
#import 	"DoomProject.h"
#import		"EditWorld.h"
#import "NXConvert.h"

extern	id	thingpanel_i;

//typedef struct
//{
//	char		name[32];
//	char		iconname[9];
//	NSColor		*color;
//	int		value, option,angle;
//} thinglist_t;

typedef struct	// TODO revert
{
	char		name[32];
	char		iconname[9];
	float		color[3];
	int			value, option, angle;
} thinglist_t;

#define	THINGNAME	@"ThingInspector"

#define	DIFF_EASY	0
#define DIFF_NORMAL	1
#define DIFF_HARD	2
#define DIFF_ALL	3

@interface ThingPanel:Object <NSWindowDelegate, NSBrowserDelegate>
{
	IBOutlet id	fields_i;		// NSForm: Angle, Type, Name (TF)
 	IBOutlet id	window_i;
	IBOutlet id	addButton_i;
	IBOutlet id	updateButton_i;
	IBOutlet id	nameField_i;
	IBOutlet id	thingBrowser_i;
	IBOutlet id	thingColor_i;
	IBOutlet id	thingAngle_i;
	id	masterList_i;
	IBOutlet id	iconField_i;
	IBOutlet id	ambush_i;		// switch
	IBOutlet id	network_i;		// switch
	IBOutlet id	difficulty_i;	// switch matrix	// NSMatrix of checkboxes (TF)
	IBOutlet id	diffDisplay_i;	// radio matrix		// NSMatrix (TF)
	IBOutlet id	count_i;		// display count
	
	int	diffDisplay;
	
	worldthing_t	basething, oldthing;
	
	id suggestButton_i;	// added to programmatically set title with line wrap
}

- (IBAction)changeDifficultyDisplay:sender;
- (int)getDifficultyDisplay;
- emptyThingList;
- pgmTarget;
- menuTarget:sender;
- saveFrame;
- (IBAction)formTarget: sender;
- updateInspector: (BOOL)force;
- updateThingInspector;
- (IBAction)updateThingData:sender;
- sortThings;
- (IBAction)setAngle:sender;
- (NXColor *)getThingColor:(int)type;
- fillThingData:(thinglist_t *)thing;
- fillDataFromThing:(thinglist_t *)thing;
- fillAllDataFromThing:(thinglist_t *)thing;
- (IBAction)addThing:sender;
- (int)findThing:(char *)string;
- (thinglist_t *)getThingData:(int)index;
- (IBAction)chooseThing:sender;
- (IBAction)confirmCorrectNameEntry:sender;
- getThing:(worldthing_t	*)thing;
- setThing:(worldthing_t *)thing;
- (int)searchForThingType:(int)type;
- (IBAction)suggestNewType:sender;
- scrollToItem:(int)which;
- getThingList;

- (IBAction)verifyIconName:sender;
- (IBAction)assignIcon:sender;
- (IBAction)unlinkIcon:sender;
- selectThingWithIcon:(char *)name;

- (thinglist_t *)getCurrentThingData;
- currentThingCount;

- (BOOL) readThing:(thinglist_t *)thing	from:(FILE *)stream;
- writeThing:(thinglist_t *)thing	from:(FILE *)stream;
- updateThingsDSP:(FILE *)stream;

@end
