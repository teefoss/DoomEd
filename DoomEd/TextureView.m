//
// This belongs to TextureEdit (docView of TextureEdit's ScrollView)
//
#import "TextureEdit.h"
#import "EditWorld.h"
#import "TextureView.h"
//#import "wadfiles.h"

#import "Storage.h"
#import "postscript.h"

@implementation TextureView

- (BOOL) acceptsFirstResponder
{
	return YES;
}

//- initFrame:(const NXRect *)frameRect
- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	deltaTable = [[ Storage	alloc ]
					initCount:0
					elementSize:sizeof(delta_t)
					description:NULL];

	return self;
}

//- keyDown:(NXEvent *)theEvent	TODO look up nextstep key codes
- (void)keyDown:(NSEvent *)event
{
	//switch(theEvent->data.key.charCode)
	switch([event keyCode])
	{
		case 0x33: //0x7f:	// delete patch (TF: delete key)
			[textureEdit_i	deleteCurrentPatch:NULL];
			break;
		case 0x25: //0x6c:	// toggle lock (TF: l)
			[textureEdit_i	doLockToggle];
			break;
		case 0x7B: //0xac:
		case 0x7D: //0xaf:	// sort down (TF left or down)
			[textureEdit_i	sortDown:NULL];
			break;
		case 0x7C: // 0xad:
		case 0x7E: // 0xae:	// sort up   (TF right or up)
			[textureEdit_i	sortUp:NULL];
			break;
		case 0x24: //0xd:	// (TF) Return
			[textureEdit_i	finishTexture:NULL];
			break;
		#if 0
		default:
			printf("charCode:%x\n",theEvent->data.key.charCode);
			break;
		#endif
	}
	//return self;
}

- drawSelf:(const NXRect *)rects :(int)rectCount
{
	int		ct,i,outlineflag;
	int		patchCount;
	texpatch_t	*tpatch;
	
	ct = [textureEdit_i	getCurrentTexture];
	if (ct < 0)
		return self;
		
	NXSetColor(NXConvertRGBToColor(1,0,0));
	NXRectFill(&rects[0]);
	
	outlineflag = [textureEdit_i	getOutlineFlag];
	PSsetgray(NX_DKGRAY);

	//
	// draw all patches
	//
	patchCount = [texturePatches	count];
	for (i = 0;i < patchCount; i++)
	{
		tpatch = [texturePatches	elementAt:i];
//		if (NXIntersectsRect(&tpatch->r,&rects[0]) == YES)	(original commented out)
			//[tpatch->patch->image_x2	composite:NX_SOVER toPoint:&tpatch->r.origin];
			[tpatch->patch->image_x2 compositeToPoint:tpatch->r.origin operation:NX_SOVER];
	}

	//
	// overlay outlines
	//
	if (outlineflag)
		for (i = patchCount - 1;i >= 0;i--)
		{
			tpatch = [texturePatches	elementAt:i];
//			if (NXIntersectsRect(&tpatch->r,&rects[0]) == YES)
				NXFrameRectWithWidth(&tpatch->r,5);
		}

	//
	// if multiple selections, draw their outlines
	//
	if ([[textureEdit_i	getSTP]		count])
	{
		int	max;
		
		max = [[textureEdit_i	getSTP]	count];
		for (i = 0;i<max;i++)
		{
			tpatch = [texturePatches	elementAt:*(int *)[[textureEdit_i getSTP] elementAt:i]];
			PSsetgray(NX_WHITE);
			NXFrameRectWithWidth(&tpatch->r,5);
		}
	}
	
	return self;
}

//- rightMouseDown:(NXEvent *)theEvent
- (void)rightMouseDown:(NSEvent *)event
{
	[[textureEdit_i	getSTP]	empty];
	[self	display];
	//return self;
}

//- mouseDown:(NXEvent *)theEvent
- (void)mouseDown:(NSEvent *)event
{
	NXPoint	loc,newloc;
	int	i,patchcount,oldwindowmask,ct,max,j,warn,clicked;
	texpatch_t	*patch;
	//NXEvent	*event;
	NSEvent		*event2;

	//oldwindowmask = [window addToEventMask:NX_LMOUSEDRAGGEDMASK];
//	loc = theEvent->location;
//	[self convertPoint:&loc	fromView:NULL];
	loc = [self convertPoint:[event locationInWindow] fromView:nil];
	ct = [textureEdit_i	getCurrentTexture];

	//
	// see if a patch was clicked on...
	//
	patchcount = [texturePatches	count];
	clicked = 0;		// no patch clicked on yet...
	for (i = patchcount - 1;i >= 0;i--)
	{
		patch = [texturePatches	elementAt:i];
		if (NXPointInRect(&loc,&patch->r) == YES)
		{
			//
			// shift-click adds the patch to the select list
			//
			//if (theEvent->flags & NX_SHIFTMASK)
			if ([event modifierFlags] & NX_SHIFTMASK)
			{
				if ([textureEdit_i	selTextureEditPatchExists:i] == NO)
					[textureEdit_i	addSelectedTexturePatch:i];
				else
					[textureEdit_i	removeSelTextureEditPatch:i];
				[textureEdit_i	updateTexPatchInfo];
			}
			else
			if (![textureEdit_i	selTextureEditPatchExists:i])
			{
				[[textureEdit_i	getSTP]	empty];
				[textureEdit_i	addSelectedTexturePatch:i];
				[textureEdit_i	updateTexPatchInfo];
			}
			[self	display];
			clicked = 1;
			break;
		}
	}
	
	//
	// Did user click outside area? If so, get rid of all selections
	//
	if (!clicked)
		[[textureEdit_i	getSTP]	empty];
	
	//
	// move around texture patches
	//
	max = [[textureEdit_i getSTP]	count];
	[deltaTable	empty];
	for (j = 0; j < max; j++)
	{
		delta_t	d;
		d.p = [texturePatches	elementAt:
				*(int *)[[textureEdit_i getSTP] elementAt:j]];
		d.xoff = loc.x - d.p->r.origin.x;
		d.yoff = loc.y - d.p->r.origin.y;
		[deltaTable	addElement:&d];
	}
	
	do
	{
		//event = [NXApp getNextEvent:	NX_MOUSEUPMASK | NX_MOUSEDRAGGEDMASK];
		event2 = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
		//newloc = event->location;
		newloc = [self convertPoint:[event locationInWindow] fromView:nil];
		//[self convertPoint:&newloc  fromView:NULL];
		warn = 0;
		for (j = 0;j < max;j++)
		{
			delta_t	*d;
			NXPoint	l;
			
			d = [deltaTable	elementAt:j];
			l = newloc;
			l.x = ((int)l.x - d->xoff) & -2;
			l.y = ((int)l.y - d->yoff) & -2;
			//
			// dragged selections off texture? if so, pull back the ones already lost.
			//
			if (l.x < 0 || l.y < 0 || l.x/2 > textures[ct].width || l.y/2 > textures[ct].height)
				warn = 1;
			d->p->r.origin = l;
			d->p->patchInfo.originx = l.x / 2;
			d->p->patchInfo.originy = textures[ct].height - 
								((l.y / 2) + (d->p->r.size.height / 2));

		}
		[ self		display ];
		[textureEdit_i	updateTexPatchInfo];
		[textureEdit_i	setWarning:warn];
	//} while (event->type != NX_MOUSEUP);
	} while ([event2 type] != NSEventTypeLeftMouseUp);

	if ([[textureEdit_i	getSTP] count] == 1)
	{
		delta_t *d;
		d = [deltaTable elementAt:0];
//		[textureEdit_i	setOldVars:d->p->patchInfo.originx + d->p->r.size.width/2
//					:(textures[ct].height - d->p->patchInfo.originy) - d->p->r.size.height/2];
		[textureEdit_i	setOldVars:d->p->patchInfo.originx + d->p->r.size.width/2
					:d->p->patchInfo.originy];
	}
	//return self;
}

@end
