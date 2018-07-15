
#import "PreferencePanel.h"
#import "MapWindow.h"
#import "DoomProject.h"

#import <Foundation/Foundation.h>

id	prefpanel_i;

NSString		*ucolornames[NUMCOLORS] =
{
	@"back_c",
	@"grid_c",
	@"tile_c",
	@"selected_c",
	@"point_c",
	@"onesided_c",
	@"twosided_c",
	@"area_c",
	@"thing_c",
	@"special_c"
};

//char		launchTypeName[] = "launchType";
//char		projectPathName[] = "projectPath";
NSString	*launchTypeName = @"launchType";
NSString	*projectPathName = @"projectPath";

NSString		*openupNames[NUMOPENUP] =
{
	@"texturePaletteOpen",
	@"lineInspectorOpen",
	@"lineSpecialsOpen",
	@"errorLogOpen",
	@"sectorEditorOpen",
	@"thingPanelOpen",
	@"sectorSpecialsOpen",
	@"textureEditorOpen"
};
int			openupValues[NUMOPENUP];
	
@implementation PreferencePanel

+(void) initialize
{
	NSDictionary *defaults =
	@{
		@"back_c":@"1:1:1",
		@"grid_c":@"0.8:0.8:0.8",
		@"tile_c":@"0.5:0.5:0.5",
		@"selected_c":@"1:0:0",

		@"point_c":@"0:0:0",
		@"onesided_c":@"0:0:0",
		@"twosided_c":@"0.5:1:0.5",
		@"area_c":@"1:0:0",
		@"thing_c":@"1:1:0",
		@"special_c":@"0.5:1:0.5",
		
//		{"launchType","1"},
		launchTypeName:@"1",
#if 1
//		{"projectPath","/aardwolf/DoomMaps/project.dpr"},
		projectPathName:@"/aardwolf/DoomMaps/project.dpr",
#else
		@"projectPath":@"/RavenDev/maps/project.dpr",
#endif
		@"texturePaletteOpen":	@"1",
		@"lineInspectorOpen":	@"1",
		@"lineSpecialsOpen":	@"1",
		@"errorLogOpen":		@"0",
		@"sectorEditorOpen":	@"1",
		@"thingPanelOpen":		@"0",
		@"sectorSpecialsOpen":	@"0",
		@"textureEditorOpen":	@"0",
		//{NULL}
	};

	//NXRegisterDefaults(APPDEFAULTS, defaults);
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

//- getColor: (NSColor *)clr fromString: (char const *)string
- (NSColor *)getColorfromString: (char const *)string
{
	float	r,g,b;
	
	sscanf (string,"%f:%f:%f",&r,&g,&b);
	NSColor *new = [[NSColor alloc] init];
	new = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
	//*clr = NXConvertRGBToColor(r,g,b);
	return new;
}

- (NSString *)getStringfromColor: (NXColor *)clr
{
	//char		temp[40];
	NSString	*temp;
	float	r,g,b;
	
//	r = NXRedComponent(*clr);
//	g = NXGreenComponent(*clr);
//	b = NXBlueComponent(*clr);
	r = [clr redComponent];
	g = [clr greenComponent];
	b = [clr blueComponent];
	
//	sprintf (temp,"%1.2f:%1.2f:%1.2f",r,g,b);
//	strcpy (string, temp);
	temp = [NSString new];
	temp = [NSString stringWithFormat:@"%1.2f:%1.2f:%1.2f",r,g,b];
	
	return temp;
}

- getLaunchThingTypeFrom:(const char *)string
{
	sscanf(string,"%d",&launchThingType);
	return self;
}

//- getProjectPathFrom:(const char *)string
//{
//	sscanf(string,"%s",projectPath);
//	return self;
//}


/*
=====================
=
= init
=
=====================
*/

- init
{
	int		i;
	int		val;
	
	prefpanel_i = self;
	window_i = NULL;		// until nib is loaded

//	for (i=0 ; i<NUMCOLORS ; i++)
//		[self getColor: &color[i]
//			fromString: NXGetDefaultValue(APPDEFAULTS, ucolornames[i])];
	
	color = [[NSMutableArray alloc] init];
	for (i=0 ; i<NUMCOLORS ; i++)
	{
		NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:ucolornames[i]];
		[color addObject:[self getColorfromString:[name UTF8String]]];
	}
	
	NSString *ltype = [[NSUserDefaults standardUserDefaults] stringForKey:launchTypeName];
	[self		getLaunchThingTypeFrom: [ltype UTF8String]];
				//NXGetDefaultValue(APPDEFAULTS,launchTypeName)];

	projectPath = [NSString new];
	projectPath = [[NSUserDefaults standardUserDefaults] stringForKey:projectPathName];
				//NXGetDefaultValue(APPDEFAULTS,projectPathName)];
	  
	//
	// openup defaults
	//
	for (i = 0;i < NUMOPENUP;i++)
	{
		NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:openupNames[i]];
		//sscanf(NXGetDefaultValue(APPDEFAULTS,openupNames[i]),"%d",&val);
		sscanf([name UTF8String],"%d",&val);
//		[[openupDefaults_i findCellWithTag:i] setIntValue:val];		original commented out
		openupValues[i] = val;
	}


	return self;
}


/*
=====================
=
= appWillTerminate:
=
=====================
*/

- appWillTerminate:sender
{
	int		i;
	char	string[40];
	NSString *str = [NSString new];

	for (i=0 ; i<NUMCOLORS ; i++)
	{
		str = [self getStringfromColor:color[i]];
		//NXWriteDefault(APPDEFAULTS, ucolornames[i], string);
		[[NSUserDefaults standardUserDefaults] setObject:str forKey:ucolornames[i]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// ---- store launch type
	//sprintf(string,"%d",launchThingType);
	//NXWriteDefault(APPDEFAULTS,launchTypeName,string);
	str = [NSString stringWithFormat:@"%i",launchThingType];
	[[NSUserDefaults standardUserDefaults] setObject:str forKey:launchTypeName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// ---- store project path
	//NXWriteDefault(APPDEFAULTS,projectPathName,projectPath);
	//str = [NSString stringWithCString:projectPath encoding:NSUTF8StringEncoding];
	[[NSUserDefaults standardUserDefaults] setObject:projectPath forKey:projectPathName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	for (i = 0;i < NUMOPENUP;i++)
	{
//		sprintf(string,"%d",(int)
//			[[openupDefaults_i findCellWithTag:i] intValue]);	original commented out
		sprintf(string,"%d",openupValues[i]);
		//NXWriteDefault(APPDEFAULTS,openupNames[i],string);
		[[NSUserDefaults standardUserDefaults] setObject:CastNSString(string) forKey:openupNames[i]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if (window_i)
		[window_i	saveFrameUsingName:PREFNAME];
	return self;	
}


/*
==============
=
= menuTarget:
=
==============
*/

- menuTarget:sender
{
	int		i;
	
	if (!window_i)
	{
		[NSBundle loadNibNamed:@"preferences" owner:self];
//		[NXApp
//			loadNibSection:	"preferences.nib"
//			owner:			self
//			withNames:		NO
//		];
		
		[window_i	setFrameUsingName:PREFNAME];
		
//		colorwell[0] = backcolor_i;
//		colorwell[1] = gridcolor_i;
//		colorwell[2] = tilecolor_i;
//		colorwell[3] = selectedcolor_i;
//		colorwell[4] = pointcolor_i;
//		colorwell[5] = onesidedcolor_i;
//		colorwell[6] = twosidedcolor_i;
//		colorwell[7] = areacolor_i;
//		colorwell[8] = thingcolor_i;
//		colorwell[9] = specialcolor_i;
		if (!colorwell)
		{
			colorwell = [NSMutableArray new];
			[colorwell addObject:backcolor_i];
			[colorwell addObject:gridcolor_i];
			[colorwell addObject:tilecolor_i];
			[colorwell addObject:selectedcolor_i];
			[colorwell addObject:pointcolor_i];
			[colorwell addObject:onesidedcolor_i];
			[colorwell addObject:twosidedcolor_i];
			[colorwell addObject:areacolor_i];
			[colorwell addObject:thingcolor_i];
			[colorwell addObject:specialcolor_i];
		}
		for (i=0 ; i<NUMCOLORS ; i++)
		{
			[[colorwell objectAtIndex:i] setColor: [color objectAtIndex:i]];
		}
		
		//[backcolor_i setColor:color[0]];
		//[gridcolor_i setColor:[NSColor blueColor]];

		for (i = 0;i < NUMOPENUP;i++)
			[[openupDefaults_i cellWithTag:i] setState:openupValues[i]];
//			[[openupDefaults_i	findCellWithTag:i]
//				setIntValue:openupValues[i]];
	}

	[launchThingType_i  	setIntValue:launchThingType];
	[projectDefaultPath_i	setStringValue:projectPath];

	//[window_i orderFront:self];
	[window_i makeKeyAndOrderFront:self];
	return self;
}

/*
==============
=
= colorChanged:
=
==============
*/

- colorChanged:sender
{
	int	i;
	id	list, win;
	
// get current colors

	for (i=0 ; i<NUMCOLORS ; i++)
		//color[i] = [colorwell[i] color];
		[color setObject:[colorwell[i] color] atIndexedSubscript:i];

// update all windows
//	list = [NXApp windowList];
	list = [NSApp windows];
	i = [list count];
	while (--i >= 0)
	{
		//win = [list objectAt: i];
		win = [list objectAtIndex:i];
		if ([win class] == [MapWindow class])
			[[win mapView] display];
	}
	
	return self;
}

- (NXColor *)colorFor: (int)ucolor
{
	return color[ucolor];
}

- launchThingTypeChanged:sender
{
	launchThingType = [sender	intValue];
	return self;
}

- (int)getLaunchThingType
{
	return	launchThingType;
}

- projectPathChanged:sender
{
//	strcpy(projectPath, [[sender	stringValue] UTF8String] );
	projectPath = [sender stringValue];
	return self;
}
// TODO check this
- openupChanged:sender
{
	id	cell = [sender selectedCell];
	openupValues[[cell tag]] = [cell intValue];
	return self;
}

- (NSString *)getProjectPath
{
	return	projectPath;
}

- (BOOL)openUponLaunch:(openup_e)type
{
	if (!openupValues[type])
		return FALSE;
	return TRUE;
}

@end
