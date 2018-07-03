#import "MapView.h"
#import "MapWindow.h"
#import "PreferencePanel.h"
#import "Timing.h"
#import "ToolPanel.h"
#import "SettingsPanel.h"
#import "Coordinator.h"
#import "pathops.h"
#include <ctype.h>

// some arrays are shared by all mapview for temporary drawing data

BOOL	linecross[9][9];

#define MAXPOINTS	200

@implementation MapView

+ initialize
{
	int	x1,y1,x2,y2;
	
	for (x1=0 ; x1<3 ; x1++)
		for (y1=0 ; y1<3 ; y1++)
			for (x2=0 ; x2<3 ; x2++)
				for (y2=0 ; y2<3 ; y2++)
				{
					if  ( ( (x1<=1 && x2>=1) || (x1>=1 && x2<=1) ) 
					&& ( (y1<=1 && y2>=1) || (y1>=1 && y2<=1) ) )
						linecross[y1*3+x1][y2*3+x2] = YES;
					else
						linecross[y1*3+x1][y2*3+x2] = NO;
				}
		
	return self;
}


/*
==================
=
= initFromEditWorld
=
==================
*/

-initFromEditWorld
{
	NXRect	aRect;

	 if (![editworld_i loaded])
	 {
		NXRunAlertPanel ("Error","MapView inited with NULL world",NULL,NULL,NULL);
		return NULL;
	}
	
	gridsize = 8;		// these are changed by the pop up menus
	scale = 1;
	
	NXSetRect (&aRect, 0,0, 100,100);	// call -setOrigin after installing in clip view
	[super initWithFrame: aRect];			// to set the proper rectangle
	//[self setOpaque: YES];
		
	return self;
}

- (BOOL)isOpaque
{
	return YES;
}

#define TESTOPS	1000

// probably not needed
- testSpeed: sender
{
#if 0

        id 		t4;
	NXStream	*stream;
	int		i;
	
        t4 = [Timing newWithTag:4];
		
	stream = NXOpenMemory (NULL, 0, NX_WRITEONLY);
	
printf ("Display\n");	
	[t4 reset];
	for (i=0 ; i<10 ; i++)
	{
		[t4 enter: WALLTIME];
		[self display];
		[t4 leave];
	}
	[t4 summary: stream];
printf ("No flush\n");	
	[t4 reset];
	[window disableFlushWindow];
	for (i=0 ; i<10 ; i++)
	{
		[t4 enter: WALLTIME];
		[self display];
		[t4 leave];
	}
	[window reenableFlushWindow];
	[t4 summary: stream];
	
	NXSaveToFile (stream, "/aardwolf/Users/johnc/timing.txt");
	NXClose (stream);
printf ("Done\n");	
#endif
	return self;
}


/*
=====================
=
= worldBoundsChanged
=
= adjust the frame rect and redraw scalers
=
=====================
*/

- worldBoundsChanged
{
	return self;
}



/*
====================
=
= scaleMenuTarget:
=
= Called when the scaler popup on the window is used
=
====================
*/

- scaleMenuTarget: sender
{
	char	const	*item;
	float			nscale;
	NXRect		visrect;
	
	item = CastCString([[sender selectedCell] title]);
	sscanf (item,"%f",&nscale);
	nscale /= 100;
	
	if (nscale == scale)
		return NULL;
		
// try to keep the center of the view constant
	visrect = [[self superview] visibleRect];
	visrect = [self convertRect:visrect fromView:[self superview]];
	//[superview getVisibleRect: &visrect];
	//[self convertRectFromSuperview: &visrect];
	visrect.origin.x += visrect.size.width/2;
	visrect.origin.y += visrect.size.height/2;
	
	[self zoomFrom: &visrect.origin toScale: nscale];

	return self;
}


/*
====================
=
= gridMenuTarget:
=
= Called when the scaler popup on the window is used
=
====================
*/

- gridMenuTarget: sender
{
	char	const	*item;
	int			grid;
	
	item = CastCString([[sender selectedCell] title]);
	sscanf (item,"grid %d",&grid);

	if (grid == gridsize)
		return NULL;
		
	gridsize = grid;
	[self display];

	return self;
}

/*
===============================================================================

						FIRST RESPONDER METHODS

===============================================================================
*/

- cut: sender
{
	[editworld_i cut:sender];
	return self;
}

- copy: sender
{
	[editworld_i copy:sender];
	return self;
}

- paste: sender
{
	[editworld_i paste:sender];
	return self;
}

- delete: sender
{
	[editworld_i delete:sender];
	return self;
}

/*
===============================================================================

							RETURN INFO

===============================================================================
*/

- (BOOL)acceptsFirstMouse:(NSEvent *)event
//- (BOOL)acceptsFirstMouse
{
	return YES;
}

- (float)currentScale
{
	return scale;
}


/*
================
=
= getCurrentOrigin
=
= Returns the global map coordinates (unscaled) of the lower left corner
=
================
*/

- getCurrentOrigin: (NXPoint *)worldorigin
{
	NXRect	global;
	
	global = [[self superview] bounds];
	global.origin = [self convertPoint:global.origin fromView:[self superview]];
//	[superview getBounds: &global];
//	[self convertPointFromSuperview: &global.origin];
	*worldorigin = global.origin;
	
	return self;
}

- printInfo: sender
{
	NXPoint	wrld;
	
	[self getCurrentOrigin: &wrld];
	printf ("getCurrentOrigin: %f, %f\n",wrld.x,wrld.y);
	
	return self;
}


/*
====================
=
= displayDirty:
=
= Adjust for the scale and size of control points and line tics
=
====================
*/

- displayDirty: (NXRect const *)dirty
{
	NXRect	rect;
	float		adjust;
	
	adjust = CPOINTDRAW*scale;
	if (adjust <= LINENORMALLENGTH)
		adjust = LINENORMALLENGTH+1;
		
	rect.origin.x = dirty->origin.x - adjust;
	rect.origin.y = dirty->origin.y - adjust;
	rect.size.width = dirty->size.width + adjust*2;
	rect.size.height = dirty->size.height + adjust*2;
	
	NXIntegralRect (&rect);
	
	[self displayRect:rect];
	//return [self display: &rect : 1];
	return self;
}


/*
===============================================================================

						UTILITY METHODS

===============================================================================
*/

/*
=======================
=
= getPoint: from:
=
= Returns the global (unscaled) world coordinates of an event location
=
=======================
*/

- 	getGridPoint:	(NSPoint *)point
	from: 	(NXEvent const *)event
{
// convert to view coordinates
	*point = [event locationInWindow];
	*point = [self convertPoint:*point fromView:nil];
	//*point = event->location;
	//[self convertPoint:point  fromView:NULL];

// adjust for grid
	point->x = (int)(((point->x)/gridsize)+0.5*(point->x<0?-1:1));
	point->y = (int)(((point->y)/gridsize)+0.5*(point->y<0?-1:1));
	point->x *= gridsize;
	point->y *= gridsize;
//	printf("X:%f\tY:%f\tgridsize:%d\n",point->x,point->y,gridsize);
	return self;
}

- 	getPoint:	(NXPoint *)point 
	from: 	(NXEvent const *)event
{
// convert to view coordinates
//	*point = event->location;
//	[self convertPoint:point  fromView:NULL];
	*point = [event locationInWindow];
	*point = [self convertPoint:*point fromView:nil];
	return self;
}

/*
=================
=
= adjustFrameForOrigin:scale:
=
= Increases or decreases the frame size to accomodate a new origin and/or scale
= Org is in global map coordinates (unscaled)
= Does not redrawing, change the origin position, or scale
= Call this every time the window is scrolled, zoomed, resized, or the map bounds changes
=
==================
*/

- adjustFrameForOrigin: (NXPoint const *)org
{
	return [self adjustFrameForOrigin: org scale:scale];
}

- adjustFrameForOrigin: (NXPoint const *)org scale: (float)scl
{
	NXRect	map;
	NXRect	newbounds;
	
// the frame rect of the MapView is the union of the map rect and the visible rect
// if this is different from the current frame, resize it
	if (scl != scale)
	{
//printf ("changed scale\n");
		NSRect frame = [self frame];
		//[self setDrawSize: frame.size.width/scl : frame.size.height/scl];
		[self setBoundsSize:NSMakeSize(frame.size.width/scl, frame.size.height/scl)]; // TODO is this right?
		scale = scl;
	}
	
	
//
// get the rects that is displayed in the superview
//
	newbounds = [[self superview] visibleRect];
	[self convertRect:newbounds fromView:[self superview]];
	//[superview getVisibleRect: &newbounds];
	//[self convertRectFromSuperview: &newbounds];
	newbounds.origin = *org;
	
	[editworld_i getBounds: &map];
	
	NXUnionRect (&map, &newbounds);
	
	NSRect bounds = [self bounds];
	if (
	newbounds.size.width != bounds.size.width ||
	newbounds.size.height != bounds.size.height 
	)
	{
//printf ("changed size\n");
		//[self sizeTo: newbounds.size.width*scale : newbounds.size.height*scale];
		[self setFrameSize:NSMakeSize(newbounds.size.width*scale, newbounds.size.height*scale)];
	}

	if (
	newbounds.origin.x != bounds.origin.x ||
	newbounds.origin.y != bounds.origin.y
	)
	{
//printf ("changed origin\n");
		//[self setDrawOrigin: newbounds.origin.x : newbounds.origin.y];
		[self setFrameOrigin:NSMakePoint(newbounds.origin.x, newbounds.origin.y)];
	}
		
	return self;
}


/*
=======================
=
= setOrigin: scale:
=
= Scrolls and/or scales the view to a new position and displays
= Org is in global map coordinates (unscaled)
= Do not call before the view is installed in a scroll view!
=
=======================
*/

- setOrigin: (NXPoint const *)org
{
	return [self setOrigin: org scale: scale];
}

- setOrigin: (NXPoint const *)org scale: (float)scl
{
	[self adjustFrameForOrigin: org scale:scl];
	[self scrollPoint: *org];
	return self;
}

/*
====================
=
= zoomFrom:(NXPoint *)origin scale:(float)newscale
=
= The origin is in screen pixels from the lower left corner of the clip view
=
====================
*/

- zoomFrom:(NXPoint *)origin toScale:(float)newscale
{
	NXPoint		neworg, orgnow;
	
	[[self window] disableFlushWindow];
	//[window disableDisplay];		// don't redraw twice (scaling and translating)
//
// find where the point is now
//
	neworg = *origin;
	neworg = [self convertPoint:neworg toView:nil];
	//[self convertPoint: &neworg toView: NULL];
	
//
// change scale
//		
	//[self setDrawSize: frame.size.width/newscale : frame.size.height/newscale];
	NSRect frame = [self frame];
	[self setFrameSize:NSMakeSize(frame.size.width/newscale, frame.size.height/newscale)];
	scale = newscale;

//
// convert the point back
//
	//[self convertPoint: &neworg fromView: NULL];
	neworg = [self convertPoint:neworg fromView:nil];
	[self getCurrentOrigin: &orgnow];
	orgnow.x += origin->x - neworg.x;
	orgnow.y += origin->y - neworg.y;
	[self setOrigin: &orgnow];
	
//
// redraw
//
	[[self window] enableFlushWindow];
	[[[self superview] superview] display];
//	[window reenableDisplay];
//	[[superview superview] display];	// redraw everything just once
	
	return self;
}



@end

