
#import "Remapper.h"
#import	"DoomProject.h"
#import	"EditWorld.h"
#import	"TextureEdit.h"

#import "Storage.h"

@implementation Remapper
//===================================================================
//
//	REMAPPER
//
//	Delegate methods required for Remapper to work:
//
//	- (char *)getOriginalName;
//	- (char *)getNewName;
//	- (int)doRemap:(char *)oldname to:(char *)newname;
//
//===================================================================

//- init
//{
//}

- setFrameName:(char *)fname
  setPanelTitle:(char *)ptitle
  setBrowserTitle:(char *)btitle
  setRemapString:(char *)rstring
  setDelegate:(id)delegate
{
	strcpy(frameName,fname);
	
	if (! remapPanel_i )
	{
		[NSBundle loadNibNamed:@"Remapper.nib" owner:self];
//		[NXApp
//			loadNibSection:	"Remapper.nib"
//			owner:			self
//			withNames:		NO
//		];
		
		storage_i = [[	Storage		alloc]
					initCount:		0
					elementSize:	sizeof(type_t)
					description:	NULL];
		
		[remapPanel_i	setFrameUsingName:CastNSString(fname)];
		[status_i		setStringValue:@" "];
	}
	
	[remapString_i	setStringValue:CastNSString(rstring)];
	[browser_i		setTitle:CastNSString(btitle) ofColumn:0]; // TODO ui
	[remapPanel_i	setTitle:CastNSString(ptitle)];
	delegate_i = delegate;
	
	return self;
}

//===================================================================
//
//	Bring up panel
//
//===================================================================
- showPanel
{
	[remapPanel_i	makeKeyAndOrderFront:NULL];
	return self;
}

//===================================================================
//
//	Make delegate return string from source depending on which Get button was used
//
//===================================================================
- remapGetButtons:sender
{
	switch([sender	tag])
	{
		case 0:
			[original_i  setStringValue:CastNSString([delegate_i getOriginalName])];
			break;
		case 1:
			[new_i  setStringValue:CastNSString([delegate_i  getNewName])];
			break;
	}
	return self;
}

//===================================================================
//
//	Add old & new texture names to list
//
//===================================================================
- addToList:(char *)orgname to:(char *)newname
{
	if (!storage_i)
		return self;

	[original_i	setStringValue:CastNSString(orgname)];
	[new_i		setStringValue:CastNSString(newname)];
	[self			addToList:NULL];

	return self;
}

- addToList:sender
{
	type_t	r,	*r2;
	int		i, max;
		
	strcpy ( r.orgname, CastCString([original_i	stringValue]) );
	strcpy ( r.newname, CastCString([new_i		stringValue]) );
	
	strupr( r.orgname );
	strupr( r.newname );
	
	[original_i	setStringValue:CastNSString(r.orgname)];
	[new_i		setStringValue:CastNSString(r.newname)];
	
	//
	//	Check for duplicates
	//
	max = [storage_i	count];
	for (i = 0;i < max; i++)
	{
		r2 = [storage_i		elementAt:i];
		if (	(!strcmp(r2->orgname,r.orgname)) &&
			(!strcmp(r2->newname,r.newname))  )
			{
				NXBeep ();
				return self;
			}
	}
	
	[storage_i	addElement:&r];
	[browser_i	reloadColumn:0];
	
	return self;
}

//===================================================================
//
//	Delete list entry
//
//===================================================================
- deleteFromList:sender
{
	int	selRow;
	
	matrix_i = [browser_i	matrixInColumn:0];
	selRow = [matrix_i		selectedRow];
	if (selRow < 0)
		return self;
	//[matrix_i		removeRowAt:selRow andFree:YES ];
	[matrix_i 		removeRow:selRow];
	[matrix_i		sizeToCells];
	//[matrix_i		selectCellAt:-1 :-1];
	[matrix_i		selectCellAtRow:-1 column:-1];
	[storage_i	removeElementAt:selRow];
	[browser_i	reloadColumn:0];
	
	return self;
}

//===================================================================
//
//	Clear out the entire list
//
//===================================================================
- clearList:sender
{
	if (NXRunAlertPanel("Warning!",
		"Are you sure you want\n"
		"to clear the remapping list?",
		"OK","Cancel",NULL) == NX_ALERTALTERNATE)
		return self;
		
	[remapPanel_i	saveFrameUsingName:CastNSString(frameName)];
	[storage_i		empty];
	[original_i		setStringValue:@" "];
	[new_i			setStringValue:@" "];
	[browser_i	reloadColumn:0];
	
	return self;
}

//===================================================================
//
//	Actually do the remapping for current map
//
//===================================================================
- doRemappingOneMap:sender
{
	type_t	*r;
	int		index, max;
	unsigned int		linenum;
	char		*oldname, *newname, string[64];
	
	max = [storage_i	count];
	if (!max)
	{
		NXBeep ();
		return self;
	}

	linenum = 0;
	for (index = 0; index < max; index++)
	{
		r = [storage_i	elementAt:index];
		oldname = r->orgname;
		newname = r->newname;
		
		linenum += [delegate_i	doRemap:oldname to:newname];
	}
		
	sprintf ( string, "%u total remappings performed.", linenum );
	[ status_i	setStringValue: CastNSString(string) ];
	[ delegate_i	finishUp ];
	[ doomproject_i	setDirtyMap:TRUE];
	
	return self;
}

//===================================================================
//
//	Actually do the remapping for ALL MAPS
//
//===================================================================
- doRemappingAllMaps:sender
{
	type_t	*r;
	int		index, max;
	unsigned int		linenum, total;
	char		*oldname, *newname, string[64];
	
	[editworld_i	closeWorld];
	[doomproject_i	beginOpenAllMaps];
	max = [storage_i	count];
	if (!max)
	{
		NXBeep ();
		return self;
	}
	total = 0;
	
	while ([doomproject_i	openNextMap] == YES)
	{
		linenum = 0;
		for (index = 0; index < max; index++)
		{
			r = [storage_i	elementAt:index];
			oldname = r->orgname;
			newname = r->newname;
			
			linenum += [delegate_i	doRemap:oldname to:newname];
		}
			
		sprintf ( string, "%u remappings.", linenum );
		total += linenum;
		[ status_i	setStringValue:CastNSString(string) ];
		[ remapPanel_i	makeKeyAndOrderFront:NULL];
		NXPing ();
		if (linenum)
			[ editworld_i	saveDoomEdMapBSP:NULL ];
	}
	
	sprintf ( string, "%u total remappings performed.", total );
	[ status_i	setStringValue: CastNSString(string) ];
	[ delegate_i	finishUp ];
	
	return self;
}

//===================================================================
//
//	Delegate methods
//
//===================================================================
- (void)windowDidMiniaturize:(NSNotification *)notification
//- windowDidMiniaturize:sender
{
	NSWindow *win = [notification object];
	NSImage *img = [NSImage imageNamed:@"DoomEd"];
//	[sender	setMiniwindowIcon:"DoomEd"];
//	[sender	setMiniwindowTitle:frameName];
	[win setMiniwindowImage:img];
	[win setMiniwindowTitle:CastNSString(frameName)];
	
	//return self;
}

- (void)applicationWillTerminate:(NSNotification *)notification
//- appWillTerminate:sender
{
	[self windowWillClose:notification];
	//[self	windowWillClose:NULL];
	//return self;
}

- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
//- (int)browser:sender  fillMatrix:matrix  inColumn:(int)column
{
	int	max, i;
	id	cell;
	char		string[128];
	type_t	*r;
	
	max = [storage_i	count];
	for (i = 0; i < max; i++)
	{
		r = [storage_i	elementAt:i];
		[matrix	addRow];
		//cell = [matrix	cellAt:i	:0];
		cell = [matrix cellAtRow:i column:0];
		
		strcpy ( string, r->orgname );
		strcat ( string, " remaps to " );
		strcat ( string, r->newname );
		
		[cell	setStringValue:CastNSString(string)];
		[cell setLeaf: YES];
		[cell setLoaded: YES];
		[cell setEnabled: YES];
	}
	//return max;
}

@end
