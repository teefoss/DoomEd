
#import "ThingPalView.h"
#import	"ThingPalette.h"
#import	"DoomProject.h"
#import	"ThingPanel.h"

#import "postscript.h"

@implementation ThingPalView

- (void)drawRect:(NSRect)dirtyRect
//- drawSelf:(const NXRect *)rects :(int)rectCount
{
	icon_t	*icon;
	int		max;
	int		i;
	int		ci;
	NXRect	r;
	NXPoint	p;
	
	ci = [thingPalette_i	getCurrentIcon];
	if (ci >= 0)
	{
		icon = [thingPalette_i	getIcon:ci];
		r = icon->r;
		r.origin.x -= 5;
		r.origin.y -= 5;
		r.size.width += 10;
		r.size.height += 10;
		DE_DrawOutline(&r);
	}
	
	max = [thingPalette_i	getNumIcons];
	for (i = 0; i < max; i++)
	{
		icon = [thingPalette_i	getIcon:i];
//		if (NXIntersectsRect(&rects[0],&icon->r) == YES)
		if (NXIntersectsRect(&dirtyRect,&icon->r) == YES)
		{
			p = icon->r.origin;
			p.x += (ICONSIZE - icon->imagesize.width)/2;
			p.y += (ICONSIZE - icon->imagesize.height)/2;
			[icon->image	compositeToPoint:p operation:NX_SOVER];
			//[icon->image	composite:NX_SOVER	toPoint:&p];
		}
	}

	//
	//	Draw icon divider text
	//
	//PSselectfont("Helvetica-Bold",12);
	//PSrotate ( 0 );
	for (i = 0; i < max; i++)
	{
		icon = [thingPalette_i	getIcon:i ];
		if (icon->image != NULL)
			continue;
	
		// Draw icon name (TF) TODO
		//PSsetgray ( 0 );
		//PSmoveto( icon->r.origin.x,icon->r.origin.y + ICONSIZE/2);
		//PSshow ( icon->name );  TODO
		//PSstroke ();

		PSsetrgbcolor ( 148,0,0 );
		PSsetlinewidth( 1.0 );
		PSmoveto ( icon->r.origin.x, icon->r.origin.y + ICONSIZE/2 + 12 );
		PSlineto ( [self bounds].size.width - SPACING,
				icon->r.origin.y + ICONSIZE/2 + 12 );

		PSmoveto ( icon->r.origin.x, icon->r.origin.y + ICONSIZE/2 - 2 );
		PSlineto ( [self bounds].size.width - SPACING,
				icon->r.origin.y + ICONSIZE/2 - 2 );
		PSstroke ();
	}
	
	//return self;
}

- (void)mouseDown:(NSEvent *)event
//- mouseDown:(NXEvent *)theEvent
{
	NXPoint	loc;
	int		i;
	int		max;
	//int		oldwindowmask;
	icon_t	*icon;

//	oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK]; TODO ?
	
//	loc = theEvent->location;
//	[self convertPoint:&loc	fromView:NULL];
	loc = [self convertPoint:[event locationInWindow] fromView:nil];
	
	max = [thingPalette_i	getNumIcons];
	for (i = 0;i < max; i++)
	{
		icon = [thingPalette_i		getIcon:i];
		if (NXPointInRect(&loc,&icon->r) == YES)
		{
			[thingPalette_i	setCurrentIcon:i];
			[thingpanel_i	selectThingWithIcon:icon->name];
			break;
		}
	}
	
	//[window	setEventMask:oldwindowmask];
	//return self;
}

@end
