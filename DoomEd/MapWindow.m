#import "MapWindow.h"
#import "MapView.h"
#import "PopScrollView.h"
#import "EditWorld.h"

NXSize	minsize = {256, 256};
NXSize	newsize = {400, 400};

static	int	cornerx = 128, cornery = 64;

@implementation MapWindow

- free
{
	[super release];
	return self;
}


- initFromEditWorld
{
	id		oldobj_i;
	NXSize	screensize;
	NXRect	wframe;
	NXPoint	origin;
	NXRect	mapbounds;

//
// set up the window
//
	screensize = [[self screen] frame].size;
	
	//[NXApp getScreenSize: &screensize];
	if (cornerx + newsize.width > screensize.width - 70)
		cornerx = 128;
	if (cornery + newsize.height > screensize.height - 70)
		cornery = 64;
	wframe.origin.x = cornerx;
	wframe.origin.y = screensize.height - newsize.height - cornery;
	wframe.size = newsize;

#if 0
	cornerx += 32;
	cornery += 32;
#endif
	self = [super initWithContentRect:wframe
					styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable
					  backing:NSBackingStoreBuffered
						defer:NO];
//	[self
//		initContent:		&wframe
//		style:			NX_RESIZEBARSTYLE
//		backing:			NX_BUFFERED
//		buttonMask:		NX_CLOSEBUTTONMASK | NX_MINIATURIZEBUTTONMASK
//		defer:			NO
//	];
	
	[self	setMinSize:	minsize];

// initialize the map view 
	mapview_i = [[MapView alloc] initFromEditWorld];
	
//		
// initialize the pop up menus
//
//	scalemenu_i = [[PopUpList alloc] init]; //TODO ui
	scalemenu_i = [[NSMenu alloc] init];
	//[scalemenu_i setTarget: mapview_i];
	
//	[scalemenu_i setAction: @selector(scaleMenuTarget:)];

//	[scalemenu_i addItem: "3.125%"];
//	[scalemenu_i addItem: "6.25%"];
//	[scalemenu_i addItem: "12.5%"];
//	[scalemenu_i addItem: "25%"];
//	[scalemenu_i addItem: "50%"];
//	[scalemenu_i addItem: "100%"];
//	[scalemenu_i addItem: "200%"];
//	[scalemenu_i addItem: "400%"];
//	[[scalemenu_i itemList] selectCellAt: 5 : 0];

	
	//scalebutton_i = NXCreatePopUpListButton(scalemenu_i);
	scalebutton_i = [[NSPopUpButton alloc] init];
	[scalebutton_i addItemWithTitle:@"3.125%"];
	[scalebutton_i addItemWithTitle:@"6.25%"];
	[scalebutton_i addItemWithTitle:@"12.5%"];
	[scalebutton_i addItemWithTitle:@"25%"];
	[scalebutton_i addItemWithTitle:@"50%"];
	[scalebutton_i addItemWithTitle:@"100%"];
	[scalebutton_i addItemWithTitle:@"200%"];
	[scalebutton_i addItemWithTitle:@"400%"];
	[scalebutton_i selectItemAtIndex:5];
	
//	gridmenu_i = [[PopUpList alloc] init];
//	[gridmenu_i setTarget: mapview_i];
//	[gridmenu_i setAction: @selector(gridMenuTarget:)];
//
//	[gridmenu_i addItem: "grid 1"];
//	[gridmenu_i addItem: "grid 2"];
//	[gridmenu_i addItem: "grid 4"];
//	[gridmenu_i addItem: "grid 8"];
//	[gridmenu_i addItem: "grid 16"];
//	[gridmenu_i addItem: "grid 32"];
//	[gridmenu_i addItem: "grid 64"];
	
//	[[gridmenu_i itemList] selectCellAt: 3 : 0];
	
	//gridbutton_i = NXCreatePopUpListButton(gridmenu_i);
	gridbutton_i = [[NSPopUpButton alloc] init];
	[gridbutton_i addItemWithTitle:@"grid 1"];
	[gridbutton_i addItemWithTitle:@"grid 2"];
	[gridbutton_i addItemWithTitle:@"grid 4"];
	[gridbutton_i addItemWithTitle:@"grid 8"];
	[gridbutton_i addItemWithTitle:@"grid 16"];
	[gridbutton_i addItemWithTitle:@"grid 32"];
	[gridbutton_i addItemWithTitle:@"grid 64"];
	[gridbutton_i selectItemAtIndex:3];
	
// initialize the scroll view
	wframe.origin.x = wframe.origin.y = 0;
	//scrollview_i = [[NSScrollView alloc] initWithFrame:wframe];
	scrollview_i = [[PopScrollView alloc]
		initFrame: 	&wframe
		button1: 		scalebutton_i
		button2:		gridbutton_i
	];
	//[scrollview_i setAutosizing: NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];

// link objects together
	
	[self setDelegate: self];

	[scrollview_i setDocumentView:mapview_i];
	[self setContentView:scrollview_i];

//	oldobj_i = [scrollview_i setDocView: mapview_i];
//	if (oldobj_i)
//		[oldobj_i free];
//	oldobj_i = [self  setContentView: scrollview_i];
//	if (oldobj_i)
//		[oldobj_i free];
	
// scroll to the middle
	[editworld_i getBounds: &mapbounds];
	//[mapview_i setFrame:mapbounds];
	origin.x = mapbounds.origin.x + mapbounds.size.width / 2 - newsize.width /2;
	origin.y = mapbounds.origin.y + mapbounds.size.height / 2 - newsize.width /2;
	[mapview_i setOrigin: &origin scale:1];

	//[mapview_i release];
	[scrollview_i release];

	return self;
}

- mapView
{
	return mapview_i;
}

- scalemenu
{
	return scalemenu_i;
}

- scalebutton
{
	return scalebutton_i;
}


- gridmenu
{
	return gridmenu_i;
}

- gridbutton
{
	return gridbutton_i;
}


- reDisplay: (NXRect *)dirty
{
	[mapview_i displayDirty: dirty];
	return self;
}

/*
=============================================================================

					DELEGATE METHODS

=============================================================================
*/

/*
=================
=
= windowWillResize: toSize:
=
= note the origin of the window on the screen so that windowDidResize can change the
= MapView origin if the origin corner of the window is moved.
=
= This will be called continuosly during resizing, even though it only needs to be called once.
=
==================
*/

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
//- windowWillResize:sender toSize:(NXSize *)frameSize
{
	oldscreenorg.x = oldscreenorg.y = 0;
	oldscreenorg = [self convertBaseToScreen: oldscreenorg];
	[mapview_i getCurrentOrigin: &presizeorigin];
	//return self;
	return frameSize;
}

/*
======================
=
= windowDidResize:
=
= expand / shrink bounds
= When this is called all the views have allready been resized and possible scrolled (sigh)
=
======================
*/
- (void)windowDidResize:(NSNotification *)notification
//- windowDidResize:sender
{
	printf("windowdidresize\n");
	NXRect	wincont, scrollcont;
	float		scale;
	NXPoint	newscreenorg;

//
// change frame if needed
//	
	newscreenorg.x = newscreenorg.y = 0;
	newscreenorg = [self convertBaseToScreen: newscreenorg];  // TODO this needs to be updated

	scale = [mapview_i currentScale];
	presizeorigin.x += (newscreenorg.x - oldscreenorg.x)/scale;
	presizeorigin.y += (newscreenorg.y - oldscreenorg.y)/scale;
	[mapview_i setOrigin: &presizeorigin];

//
// resize drag image
//
//	[Window
//		getContentRect:	&wincont
//		forFrameRect:		&frame
//		style:			NX_RESIZEBARSTYLE
//	];
	wincont = [NSWindow contentRectForFrameRect:[self frame]
									  styleMask:NSWindowStyleMaskResizable];

//	[ScrollView
//		getContentSize:	&scrollcont.size
//		forFrameSize:		&wincont.size
//		horizScroller:		YES
//		vertScroller:		YES
//		borderType:		NX_NOBORDER
//	];
	scrollcont.size = [NSScrollView contentSizeForFrameSize:wincont.size
									  hasHorizontalScroller:YES
										hasVerticalScroller:YES
												 borderType:NSNoBorder];
	//return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[editworld_i windowWillClose:self];
}


@end
