#import "MapViewResp.h"
#import "MapView.h"
#import "MapWindow.h"
#import "PreferencePanel.h"
#import "Timing.h"
#import "ToolPanel.h"
#import <ctype.h>
#import "EditWorld.h"
#import "idfunctions.h"
#import "pathops.h"
#import "LinePanel.h"
#import "SectorEditor.h"
#import "SettingsPanel.h"
#import "BlockWorld.h"
#import "ThingPanel.h"

#import "postscript.h"
#import <QuartzCore/QuartzCore.h>

#define FRAMEWIDTH		4
#define SELECTIONGRAY	0.5

@implementation MapView (MapViewResp)

/*
===============================================================================

						WORLD UTILITY METHODS

===============================================================================
*/

/*
===================
=
= addLineFrom: to:
=
= Adds a new line of the type specified in the various panels and selects it and its points
= Called by lineDrag and polyDrag
=
====================
*/

- addLineFrom: (NXPoint *)fixedpoint  to: (NXPoint *)dragpoint
{
	worldline_t	newline;
	int			line;

	[linepanel_i baseLine: &newline];

	line = [editworld_i newLine: &newline from: fixedpoint to: dragpoint];
	
	[editworld_i selectLine: line];
	[editworld_i selectPoint: lines[line].p1];
	[editworld_i selectPoint: lines[line].p2];
	
	return self;
}

/*
===============================================================================

						RESPONDER METHODS

===============================================================================
*/

/*
===============
=
= slideView:
=
= Scroll the view in response to dragging
=
===============
*/

- slideView:(NXEvent *)event
{
	//int 		oldMask;
	NXPoint	oldpt, pt, origin;
	float		dx, dy;

	oldpt = [self convertPoint:[event locationInWindow] fromView:nil];
	//oldpt = event->location;
	//[self convertPoint: &oldpt fromView: NULL];
	
	//oldMask = [window addToEventMask:NX_MOUSEDRAGGEDMASK | NX_RMOUSEDRAGGEDMASK];
	
	do 
	{
		//event = [NXApp getNextEvent: NX_MOUSEUPMASK | NX_RMOUSEUPMASK | NX_MOUSEDRAGGEDMASK | NX_RMOUSEDRAGGEDMASK];
		event = [[self window] nextEventMatchingMask:
				 NSEventMaskLeftMouseUp |
				 NSEventMaskRightMouseUp |
				 NSEventMaskLeftMouseDragged |
				 NSEventMaskRightMouseDragged];
		if ([event type] == NSEventTypeLeftMouseUp || [event type] == NSEventTypeRightMouseUp)
		//if (event->type == NX_MOUSEUP || event->type == NX_RMOUSEUP)
			break;
		
		pt = [self convertPoint:[event locationInWindow] fromView:nil];
		//pt = event->location;
		//[self convertPoint: &pt fromView: NULL];
		dx = oldpt.x - pt.x;
		dy = oldpt.y - pt.y;
		
		if (dx != 0 || dy != 0)
		{
			[self getCurrentOrigin: &origin];
			origin.x += dx;
			origin.y += dy;
			[[self window] disableFlushWindow];
			//[[self window] disableDisplay];
			[self setOrigin: &origin];
			[[self window] enableFlushWindow];
			//[[self window] reenableDisplay];
			[[[self superview] superview] display];	// redraw everything just once
			
			oldpt = [self convertPoint:[event locationInWindow] fromView:nil];
			//oldpt = event->location;
			//[self convertPoint: &oldpt fromView: NULL];
			[doomproject_i	setDirtyMap:TRUE];
		}
	} while (1);
	
	//[window setEventMask:oldMask];
	
	return self;
}


/*
================
=
= zoomIn:
=
================
*/

- zoomIn:(NXEvent *)event
{
	char	const	*item;
	float			nscale;
	NSArray			*itemlist;
	int			selected, numrows, numcollumns;
	NXPoint		origin;
	NSPopUpButton *scalemenu;
	
	//itemlist = [[[self window] scalemenu] itemList];  // TODO
	scalemenu = [[self window] scalemenu];
	itemlist = [scalemenu itemTitles];

	//[itemlist getNumRows: &numrows numCols:&numcollumns];
	numrows = [itemlist count];
	
	//selected = [itemlist selectedRow] + 1;
	selected = [scalemenu indexOfSelectedItem] + 1;
	if (selected >= numrows)
		return NULL;
		
	//[itemlist selectCellAt: selected : 0];
	[scalemenu selectItemAtIndex:selected];
	//[[window scalebutton] setTitle: [[itemlist selectedCell] title]];   ???
	
// parse the scale from the title
	//item = [[itemlist selectedCell] title];
	item = CastCString([itemlist objectAtIndex:selected]);
	sscanf (item,"%f",&nscale);
	nscale /= 100;
	
// keep the cursor point of the view constant

	origin = [self convertPoint:[event locationInWindow] fromView:nil];
	//origin = event->location;
//	[self convertPoint:&origin  fromView:NULL];
//printf ("origin: %f,%f\n",origin.x,origin.y);	   (original was commented out) (TF)
	[self zoomFrom: &origin toScale: nscale];
	
//
// allow a drag while the mouse is still down
//
	[self slideView: event];
	
	return self;
}

/*
================
=
= zoomOut:
=
================
*/

- zoomOut:(NXEvent *)event
{
	char	const	*item;
	float			nscale;
	id			itemlist;
	int			selected;
	NXPoint		origin;
	NSPopUpButton *scalemenu;

	scalemenu = [(MapWindow *)[self window] scalemenu];
	itemlist = [scalemenu itemTitles];
	selected = [scalemenu indexOfSelectedItem] - 1;
	//itemlist = [[window scalemenu] itemList];
	//selected = [itemlist selectedRow] - 1;
	
	if (selected < 0)
		return NULL;
		
	//[itemlist selectCellAt: selected : 0];
	[scalemenu selectItemAtIndex:selected];
	//[[window scalebutton] setTitle: [[itemlist selectedCell] title]];
	
// parse the scale from the title
	item = CastCString([scalemenu titleOfSelectedItem]);
	//item = [[itemlist selectedCell] title];
	sscanf (item,"%f",&nscale);
	nscale /= 100;
	
// keep the cursor point of the view constant

	origin = [self convertPoint:[event locationInWindow] fromView:nil];
//	origin = event->location;
//	[self convertPoint:&origin  fromView:NULL];
//printf ("origin: %f,%f\n",origin.x,origin.y);
	
	[self zoomFrom: &origin toScale: nscale];
	
//
// allow a drag while the mouse is still down
//
	[self slideView: event];

	return self;
}


//=============================================================================


/*
================
=
= lineDrag:
=
= Rubber band a new line from the starting position
=
================
*/

- lineDrag:(NXEvent *)event
{
	//int 		oldMask;
	NXPoint	fixedpoint, dragpoint;	// endpoints of the line
		
	//oldMask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	NSBezierPath *path = [[NSBezierPath alloc] init];
	[path setLineWidth:0.15];
	NSColor *currentcolor = [prefpanel_i colorFor:[settingspanel_i segmentType]];
	[currentcolor set];
	
	[self lockFocus];
	//PSsetinstance (YES);	// TODO what is that?
	//PSsetlinewidth (0.15);
	NXSetColor ([prefpanel_i colorFor: [settingspanel_i segmentType]]);

	[self getGridPoint: &fixedpoint from: event];		// handle grid and sutch
	
	do 
	{
		[self getGridPoint: &dragpoint  from: event];  // handle grid and sutch
		
		[path moveToPoint:fixedpoint];
		[path lineToPoint:dragpoint];
		[path stroke];
//		PSnewinstance ();
//
//		PSmoveto (fixedpoint.x, fixedpoint.y);
//		PSlineto (dragpoint.x, dragpoint.y);
//		PSstroke ();
//		NXPing ();
		
		//event = [NXApp getNextEvent: NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK];
		event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
	} while ([event type] != NSEventTypeLeftMouseUp); //(event->type != NX_LMOUSEUP);
	
//
// add to the world
//
	//[window setEventMask:oldMask];

//	PSnewinstance ();
//	PSsetinstance (NO);
	[self unlockFocus];
	
	if ( dragpoint.x == fixedpoint.x && dragpoint.y == fixedpoint.y )
		return NULL;			// outside world or same point
	
	[editworld_i deselectAll];
	[self addLineFrom: &fixedpoint  to: &dragpoint];
	[editworld_i updateWindows];	
	[doomproject_i	setDirtyMap:TRUE];	

	return self;
}

//=============================================================================

/*
================
=
= polyDrag:
=
================
*/

- polyDrag:(NXEvent *)event
{
	int 		oldMask;
	NXPoint	fixedpoint, dragpoint;	// endpoints of the line

	NSBezierPath *path = [[NSBezierPath alloc] init];
	[path setLineWidth:0.15];
	NSColor *curcol = [[NSColor alloc] init];
	curcol = [prefpanel_i colorFor: [settingspanel_i segmentType]];
	[curcol set];
//
// set up
//	
	[self lockFocus];
//	PSsetlinewidth (0.15);
//	NXSetColor ([prefpanel_i colorFor: [settingspanel_i segmentType]]);

//
// wait for a mouse up to specify first point
//
	do
	{
		//event = [NXApp getNextEvent: NX_LMOUSEUPMASK];
		event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp];
	} while ([event type] != NSEventTypeLeftMouseUp);  //(event->type != NX_LMOUSEUP);

//
// drag lines until a click on same point
//
	do
	{
		[self getGridPoint: &fixedpoint from: event];	// handle grid and sutch
		//oldMask = [window addToEventMask:NX_MOUSEMOVEDMASK];
		//PSsetinstance (YES);
	
		do 
		{
			event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp | NSEventMaskMouseMoved | NSEventMaskLeftMouseDragged];
			//event = [NXApp getNextEvent: NX_LMOUSEDOWNMASK | NX_LMOUSEUPMASK | NX_MOUSEMOVEDMASK | NX_LMOUSEDRAGGEDMASK];
			[self getGridPoint: &dragpoint  from: event];  // handle grid and sutch
			//if (event->type == NX_LMOUSEUP)
			if ([event type] == NSEventTypeLeftMouseUp)
				break;

			[path moveToPoint:fixedpoint];
			[path lineToPoint:dragpoint];
			[path stroke];
//			PSnewinstance ();
//			PSmoveto (fixedpoint.x, fixedpoint.y);
//			PSlineto (dragpoint.x, dragpoint.y);
//			PSstroke ();
//			NXPing ();
		} while (1);
	
//
// add to the world
//
		//[window setEventMask:oldMask];
	
//		PSnewinstance ();
//		PSsetinstance (NO);

		if ( dragpoint.x == fixedpoint.x && dragpoint.y == fixedpoint.y )
			break;			// outside world or same point

		[self addLineFrom: &fixedpoint  to: &dragpoint];
		[editworld_i updateWindows];		
		[doomproject_i	setDirtyMap:TRUE];
	} while (1);
	
	[self unlockFocus];
		
	return self;
}

//=============================================================================

/*
================
=
= dragSelectedPoints:
=
 the fixedrect is the rect enclosing any points connected by lines to the selected points
 
 the dragrect is the rect that encloses all the selected points, with the
 initial click being the origin
 
 currentdragrect is dragrect+cursor
 
 the updaterect is the (currentdragrect union olddragrect union fixedrect)
 
 if only one point is selected, it is snapped to grid
 
================
*/

- dragSelectedPoints: (NXEvent *)event
{
	int 		oldMask;
	int		l;
	int			linecount, *linelist, *linelist_p;
	worldline_t	*line_p;
	BOOL		side1, side2;
	NXPoint		cursor, moved,totalmoved;
	NXRect		fixedrect;
	NXRect		dragrect;
	NXRect		currentdragrect, olddragrect;
	NXRect		updaterect;
	int			p, lastp;
	worldpoint_t	*point_p, newpoint;
	int			pointcount;
	float		offset;
		
	[self getGridPoint: &cursor  from: event];  // handle grid and sutch
	
// set up negative rects
	fixedrect.origin.x = MAXFLOAT/4;
	fixedrect.origin.y = MAXFLOAT/4;
	fixedrect.size.width = -MAXFLOAT/2;
	fixedrect.size.height = -MAXFLOAT/2;
	dragrect = fixedrect;
	
// if only one endpoint of a line is selected, the other end will contribute to the fixedrect
// Any lines that touch the points need to have their normals updated during dragging

	linelist = linelist_p = alloca(numlines*sizeof(*linelist));
	
	for (l=0, line_p = lines ; l<numlines ; l++, line_p++)
	{
		if (line_p->selected == -1)
			continue;
			
		side1 = points[line_p->p1].selected == 1;
		side2 = points[line_p->p2].selected == 1;
		
		if (side1 || side2)
			*linelist_p++ = l;
		
		if (side1 && !side2)
			IDEnclosePoint (&fixedrect, &points[line_p->p2].pt); // p2 is fixed
		else if (side2 && !side1)
			IDEnclosePoint (&fixedrect, &points[line_p->p1].pt); // p1 is fixed
	}
	linecount = linelist_p - linelist;
	
//
// the dragrect encloses all selected points
//
	offset = THINGDRAWSIZE/2/scale + 2;
	
	pointcount = 0;
	for (p=0 , point_p = points ; p<numpoints ; p++, point_p++)
	{
		if (point_p->selected == 1)
		{
			pointcount++;
			lastp = p;
			IDEnclosePoint (&dragrect, &point_p->pt);
		}
	}
	
	for (p=0; p<numthings;p++)
		if (things[p].selected == 1)
		{
			NXPoint	pt;
			
			pt = things[p].origin;
			pt.x -= offset;
			pt.y -= offset;
			IDEnclosePoint(&dragrect,&pt);
			pt.x = things[p].origin.x + offset;
			pt.y = things[p].origin.y + offset;
			IDEnclosePoint(&dragrect,&pt);
		}

	olddragrect = dragrect;		// absolute coordinates
	
	dragrect.origin.x -= cursor.x;	// relative to cursor
	dragrect.origin.y -= cursor.y;
	
//
// modal dragging loop
//
	//oldMask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
	moved = totalmoved = cursor;
	
	do 
	{
		event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
		//event = [NXApp getNextEvent: NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK];
		//if ( event->type == NX_LMOUSEUP)
		if ([event type] == NSEventTypeLeftMouseUp)
			break;
		//
		// calculate new rectangle
		//
		[self getGridPoint: &cursor  from: event];  // handle grid and such

		//
		// move all selected points
		//
		if (pointcount == 1)
		{
			if (points[lastp].pt.x == cursor.x && points[lastp].pt.y == cursor.y)
				continue;
			points[lastp].pt = cursor;
		}
		else
		{
			if (cursor.x == moved.x && cursor.y == moved.y)
				continue;
				
			moved.x = cursor.x - moved.x;
			moved.y = cursor.y - moved.y;	
		
			for (p=0 , point_p = points ; p<numpoints ; p++, point_p++)
			{
				if (point_p->selected == 1)
				{
					point_p->pt.x += moved.x;
					point_p->pt.y += moved.y;
				}
			}
			
			for (p=0; p < numthings;p++)
				if (things[p].selected == 1)
				{
					things[p].origin.x += moved.x;
					things[p].origin.y += moved.y;
				}

			if (moved.x || moved.y)
				[doomproject_i	setDirtyMap:TRUE];
				
			moved = cursor;
		}
		
		//
		// update line normals
		//
		for (l = 0 ; l < linecount ; l++)
			[editworld_i updateLineNormal: linelist[l]];
		
		//
		// redraw new frame
		//
		currentdragrect = dragrect;
		currentdragrect.origin.x += cursor.x;
		currentdragrect.origin.y += cursor.y;
		updaterect = currentdragrect;
		NXUnionRect (&olddragrect, &updaterect);
		NXUnionRect (&fixedrect, &updaterect);
		olddragrect = currentdragrect;
		[self displayDirty: &updaterect];
		
	} while (1);

	//[window setEventMask:oldMask];

	//
	// tell the world about the changes
	// the points have to be set back to their original positions before sending
	// the new point to the server so the dirty rect will contain everything touched
	// by the old and new positions
	//
	totalmoved.x = cursor.x - totalmoved.x;
	totalmoved.y = cursor.y - totalmoved.y;	
	
	for (p=0 ; p<numpoints ; p++)
		if (points[p].selected == 1)
		{
			newpoint = points[p];
			points[p].pt.x -= totalmoved.x;
			points[p].pt.y -= totalmoved.y;
			[editworld_i changePoint: p to: &newpoint];
			if (totalmoved.x || totalmoved.y)
				[doomproject_i	setDirtyMap:TRUE];
		}

	return self;
}


//=============================================================================

/*
================
=
= dragSelectionBox:
=
================
*/

- dragSelectionBox: (NXEvent *)event
{
	int 		oldMask;
	NXRect	newframe;
	NXPoint	dragcorner, fixedcorner, *p1, *p2;
	int		i,p;
	worldpoint_t	*point_p;
	worldthing_t	*thing_p;
	box_t		box1, box2;
	
//
// peg down the first corner
//
	fixedcorner = [self convertPoint:[event locationInWindow] fromView:nil];
//	fixedcorner = event->location;
//	[self convertPoint:&fixedcorner  fromView:NULL];
	
//
// move drag
//	
	//oldMask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];

	
	
	[self lockFocus];
//	PSsetinstance (YES);
//	PSsetgray (SELECTIONGRAY);
	NSBezierPath *framepath = [[NSBezierPath alloc] init];
	[framepath setLineWidth:FRAMEWIDTH];
	NSColor *gray = [NSColor colorWithWhite:SELECTIONGRAY alpha:1.0];
	[gray set];
	
	do 
	{
		//
		// calculate new rectangle
		//
		dragcorner = [self convertPoint:[event locationInWindow] fromView:nil];
//		dragcorner = event->location;
//		[self convertPoint:&dragcorner  fromView:NULL];
		IDRectFromPoints (&newframe, &fixedcorner, &dragcorner);
				
		//
		// redraw new frame
		//
		[framepath moveToPoint:newframe.origin];
		[framepath lineToPoint:NSMakePoint(newframe.origin.x+newframe.size.width, newframe.origin.y)];
		[framepath lineToPoint:NSMakePoint(newframe.origin.x+newframe.size.width, newframe.origin.y+newframe.size.height)];
		[framepath lineToPoint:NSMakePoint(newframe.origin.x, newframe.origin.y+newframe.size.height)];
		[framepath closePath];
		[framepath stroke];
//		PSnewinstance ();
//		NXFrameRectWithWidth(&newframe, FRAMEWIDTH);
//		NXPing ();
		
		event = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
		//event = [NXApp getNextEvent: NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK];
		
	} while ([event type] != NSEventTypeLeftMouseUp);   //(event->type != NX_LMOUSEUP);

	//[window setEventMask:oldMask];
//	PSnewinstance ();
//	PSsetinstance (NO);
	[self unlockFocus];
	
//
// grab points inside newframe
//
	for (p=0 , point_p = points ; p<numpoints ; p++, point_p++)
	{
		if (point_p->selected == -1)
			continue;
		if ( NXPointInRect (&point_p->pt, &newframe) )
			[editworld_i selectPoint: p];
	}

//
// grab lines inside newframe
//
	[self lockFocus];
	PSsetlinewidth (1);
	BoxFromRect (&box1, &newframe);	
	for (i=0 ; i<numlines ; i++)
	{
		if (lines[i].selected == -1)
			continue;				// deleted line
		
		p1 = &points[lines[i].p1].pt;
		p2 = &points[lines[i].p2].pt;
		
		BoxFromPoints (&box2, p1, p2);	

		if ( box1.right < box2.left || box1.left > box2.right
		|| box1.top < box2. bottom || box1.bottom > box2.top)
			continue;

		//if (LineInRect (p1, p2, &newframe))
		if (LineInRect(p1->x, p1->y, p2->x, p2->y, newframe))
		{
		// hit a line
			[editworld_i selectLine: i];
			// select points at ends
			[editworld_i selectPoint: lines[i].p1];
			[editworld_i selectPoint: lines[i].p2];
		}
	}
		
	[self unlockFocus];

//
// grab things inside newframe
//
	for (p=0 , thing_p = things ; p<numthings ; p++, thing_p++)
	{
		if (thing_p->selected == -1)
			continue;
		if ( NXPointInRect (&thing_p->origin, &newframe) )
			[editworld_i selectThing: p];
	}

		
	return self;
}

//============================================================================

/*
================
=
= pointSelect:
=
================
*/

- pointSelect:(NXEvent *)event
{
	int			i;
	worldthing_t	*thing_p;
	worldpoint_t	const *point_p;
	float			left, right, top, bottom;
	NXPoint		*p1, *p2;
	NXPoint		clickpoint;
	int			instroke;
	
	[self getPoint: &clickpoint from: event];
	

//
// see if the click hit a point
//
	left = clickpoint.x - CPOINTSIZE/scale/2;
	right = clickpoint.x + CPOINTSIZE/scale/2;
	bottom = clickpoint.y  - CPOINTSIZE/scale/2;
	top = clickpoint.y+ CPOINTSIZE/scale/2;


	for (i=0, point_p = points; i<numpoints ; i++,point_p++)
	{
		if (point_p->selected == -1)
			continue;
		if (point_p->pt.x > left && point_p->pt.x < right 
		&& point_p->pt.y < top && point_p->pt.y > bottom)
			break;
	}
	
	if (i<numpoints)
	{	// the click was on a point
		if (point_p->selected)
		{
			if ([event modifierFlags] & NSEventModifierFlagShift)
			//if  ( event->flags & NX_SHIFTMASK )
			{	// shift click a selected point deselects it
				[editworld_i deselectPoint: i];
				return self;
			}
		}
		else
		{
// if not clicking on a selection and not shift clicking, deselect all selected points
			if (!([event modifierFlags] & NSEventModifierFlagShift))
			//if ( !(event->flags & NX_SHIFTMASK) )
				[editworld_i deselectAll];
			[editworld_i selectPoint: i];
		}
		[editworld_i updateWindows];
		[self dragSelectedPoints: event];	// drag all points around
		return self;
	}
	
//
// didn't hit a point, so check lines
//
	[self lockFocus];
	//PSsetlinewidth (CPOINTSIZE*scale);	// line width same as contrtol points
	for (i=0 ; i<numlines ; i++)
	{
		if (lines[i].selected == -1)
			continue;				// deleted line
			
		p1 = &points[lines[i].p1].pt;
		p2 = &points[lines[i].p2].pt;
		
		if ( (p1->x < left && p2->x < left)
		|| (p1->x > right && p2->x > left)
		|| (p1->y > top && p2->y > top)
		|| (p1->y < bottom && p2->y < bottom) )
			continue;
		
		// original
//		PSnewpath ();
//		PSmoveto (p1->x,p1->y);
//		PSlineto (p2->x,p2->y);
//		PSinstroke (clickpoint.x, clickpoint.y, &instroke);
		
		// swift
//		let layer = CAShapeLayer()
//		layer.lineWidth = 32.0
//		let path = CGMutablePath()
//		path.move(to: p1)
//		path.addLine(to: p2)
//		layer.path = path
//		let newPath = path.copy(strokingWithWidth: 32.0, lineCap: .butt, lineJoin: .miter, miterLimit: 1.0)

		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSetLineWidth(context, CPOINTDRAW*scale);
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, p1->x, p1->y);
		CGPathAddLineToPoint(path, NULL, p2->x, p2->y);
		CGPathCloseSubpath(path);
		CGContextAddPath(context, path);
		CGContextStrokePath(context);
		CGPathContainsPoint(path, NULL, clickpoint, instroke);
		CGPathRelease(path);
		
		if (instroke)
		{
		// hit a line
			[self unlockFocus];
			// deselect any other points if shift not down
			if ( !([event modifierFlags] & NSEventModifierFlagShift) && lines[i].selected != 1 )
			//if ( !(event->flags & NX_SHIFTMASK) && lines[i].selected != 1)
				[editworld_i deselectAll];

			if ( [event modifierFlags] & NSEventModifierFlagShift && lines[i].selected == 1 )
			//if (event->flags & NX_SHIFTMASK && lines[i].selected == 1)
			{
				[editworld_i deselectLine: i];
				return self;
			}
			
			[editworld_i selectLine: i];
			
			// select points at ends
			[editworld_i selectPoint: lines[i].p1];
			[editworld_i selectPoint: lines[i].p2];
			
			[editworld_i updateWindows];
			[self dragSelectedPoints: event];	// drag all points around
			return self;
		}
	}
		
	
	[self unlockFocus];
	
//
// see if the click hit a thing
//
	left = clickpoint.x - THINGDRAWSIZE/2;
	right = clickpoint.x + THINGDRAWSIZE/2;
	bottom = clickpoint.y  - THINGDRAWSIZE/2;
	top = clickpoint.y+ THINGDRAWSIZE/2;


	for (i=0, thing_p = things; i<numthings ; i++,thing_p++)
	{
		if (thing_p->selected == -1)
			continue;
		if (thing_p->origin.x > left && thing_p->origin.x < right 
		&& thing_p->origin.y < top && thing_p->origin.y > bottom)
			break;
	}
	
	if (i<numthings)
	{	// click was on a thing
		// if not clicking on a selection and
		// ...not shift clicking, deselect all selected points
		// deselect any other points if shift not down
		if ( !([event modifierFlags] & NSEventModifierFlagShift) && things[i].selected != 1 )
		//if ( !(event->flags & NX_SHIFTMASK) && things[i].selected != 1)
			[editworld_i deselectAll];
		[editworld_i selectThing: i];
		[self dragSelectedPoints: event];	// drag all points around
		return self;
	}
	

//
// the click was not on a point, so rubber band a selection box
//
	if ( !([event modifierFlags] & NSEventModifierFlagShift) )
	//if (! (event->flags & NX_SHIFTMASK) )
	{
	// if not shift clicking, deselect all selected points
		[editworld_i deselectAll];
		[editworld_i updateWindows];
	}

	[self dragSelectionBox: event];
	
	return self;
}

//=============================================================================

/*
================
=
= placeThing:
=
================
*/

- placeThing: (NXEvent *)event
{
	worldthing_t	thing;
	
	[editworld_i deselectAll];
	
	[self getGridPoint: &thing.origin from: event];
	
	[thingpanel_i	getThing:&thing];
	thing.selected = 0;
	[editworld_i newThing: &thing];
	[doomproject_i	setDirtyMap:TRUE];
	
	return self;
}


//=============================================================================

/*
================
=
= fillSector:
=
================
*/

- fillSector: (NXEvent *)event
{
	NXPoint	pt;
	int		i, side;
	worldline_t	*line;
	sectordef_t	*fillends;

	fillends = [sectorEdit_i getSector];
	
	[self getPoint: &pt from: event];
	[blockworld_i floodFillSector: &pt];
	
	for (i=0 ; i<numlines ; i++)
	{
		line = &lines[i];
		if (line->selected <1 )
			continue;
		side = line->selected-1;
		line->side[side].ends = *fillends;
	}
	[doomproject_i	setDirtyMap:TRUE];
	
	return self;
}

//=============================================================================

/*
================
=
= getSector:
=
================
*/

- getSector: (NXEvent *)event
{
	NXPoint	pt;
	int		line, side;
	sectordef_t	*def;

	[self getPoint: &pt from: event];	
	line = LineByPoint (&pt, &side);
	
	def = &lines[line].side[side].ends;
	
	[sectorEdit_i	setSector: def];
	
	return self;
}


//============================================================================

- (int)scanForErrors
{
	int	i;
	for (i=0;i<numthings;i++)
		if (things[i].selected == 1)
			return 1;
	for (i=0;i<numlines;i++)
		if (lines[i].selected == 1)
			return 1;
	return 0;	
}

- launchAndSave:(NXEvent *)event
{
	NXPoint	pt;
	int	i,player1Type;
	worldthing_t	oldthing,newthing;
	
	player1Type = [prefpanel_i	getLaunchThingType];
	[self getPoint: &pt from: event];
	for (i=0;i < numthings; i++)
		if (things[i].type == player1Type)
		{
			newthing = oldthing = things[i];
			newthing.origin = pt;
			[editworld_i	changeThing:i		to:&newthing];
			[editworld_i	redrawWindows];
			[editworld_i	saveDoomEdMapBSP:NULL];
			[editworld_i	changeThing:i		to:&oldthing];
			[editworld_i	redrawWindows];
			NXPing();
			[toolpanel_i	changeTool:SELECT_TOOL];
			if ([self	scanForErrors])
				NXRunAlertPanel("Errors!",
					"Don't run your project, you have some errors. ",
					"OK",NULL,NULL);
			[editworld_i	saveWorld:NULL];
			#if 0
			else
				NXRunAlertPanel("Important!",
					"Save again sometime soon, as Player 1's position was "
					"modified so you could launch your project.",
					"OK",NULL,NULL);
			#endif
			break;
		}
	
	return self;
}

//============================================================================

/*
================
=
= mouseDown:
=
================
*/

- (void)mouseDown:(NSEvent *)event
//- mouseDown:(NXEvent *)thisEvent
{
	int	tool;
		
	tool = [toolpanel_i currentTool];
	
	switch ( tool )
	{
	case SELECT_TOOL:
		[self pointSelect: event];
		break;
	case LINE_TOOL:
		[self lineDrag: event];
		break;
	case POLY_TOOL:
		[self polyDrag: event];
		break;
	case ZOOMIN_TOOL:
		[self zoomIn: event];
		break;
	case SLIDE_TOOL:
		[self slideView: event];
		break;
	case THING_TOOL:
		[self placeThing: event];
		break;
	case GET_TOOL:
		[self getSector: event];
		break;
	case LAUNCH_TOOL:
		[self	launchAndSave:event];
		break;
	default:
		break;
	}
			
	[editworld_i updateWindows];
	//return(self);
}

- (void)rightMouseDown:(NSEvent *)event
//- rightMouseDown:(NXEvent *)thisEvent
{
	switch ( [toolpanel_i currentTool] )
	{
	case ZOOMIN_TOOL:
		[self zoomOut: event];
		break;
	case GET_TOOL:
		[self fillSector:event];
		break;
	default:
		break;
	}

	[editworld_i updateWindows];
	//return self;
}

//=============================================================================

/*
===============
=
= keyDown:
=
===============
*/

- (void)keyDown:(NSEvent *)event
//- keyDown:(NXEvent *)theEvent
{
	if ([event keyCode] == 0x33) // delete key
	//if (theEvent->data.key.charCode == 127)
	{
		[editworld_i delete: self];
		//return self;
	}
		
	[editworld_i updateWindows];
	//return self;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

@end
