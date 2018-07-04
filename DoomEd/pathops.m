#import "pathops.h"
#import "PreferencePanel.h"
//#import "wraps.h"
#import "postscript.h"

#define LINETYPES	16
#define MAXLINES	100
#define MAXPOINTS	(MAXLINES*2)

float		coords[LINETYPES][MAXPOINTS*2], *coord_p[LINETYPES];
char		ops[LINETYPES][MAXPOINTS], *ops_p[LINETYPES], *stopop[LINETYPES];
float		bbox[LINETYPES][4];

void		FinishPath (int path);


/*
==============
=
= StartPath
=
==============
*/

void		StartPath (int path)
{
#if 0

	bbox[path][0] = -MAXFLOAT/2;
	bbox[path][1] = -MAXFLOAT/2;
	bbox[path][2] = MAXFLOAT/2;
	bbox[path][3] = MAXFLOAT/2;
	
	coord_p[path] = coords[path];
	ops_p[path] = ops[path];
	stopop[path] = &ops[path][MAXPOINTS];
#endif
}

/*
==============
=
= AddLine
=
==============
*/

#if 0
void		AddLine (int path, float x1, float y1, float x2, float y2)
{
	float	*box;
	
	box = bbox[path];
	
	x1 = x1+0.5;
	y1 = y1+0.5;
	x2 = x2+0.5;
	y2 = y2+0.5;
	
	if (x1 < box[0])
		box[0] = x1;
	if (x1 > box[2])
		box[2] = x1;
	if (x2 < box[0])
		box[0] = x2;
	if (x2 > box[2])
		box[2] = x2;
		
	if (y1 < box[1])
		box[1] = y1;
	if (y1 > box[3])
		box[3] = y1;
	if (y2 < box[1])
		box[1] = y2;
	if (y2 > box[2])
		box[3] = y2;
		
	*ops_p[path]++ = dps_moveto;
	*coord_p[path]++ = x1;
	*coord_p[path]++ = y1;
	*ops_p[path]++ = dps_lineto;
	*coord_p[path]++ = x2;
	*coord_p[path]++ = y2;
	
	if (ops_p[path] == stopop[path])
	{	// buffer is full, write out what we have and start over
		FinishPath (path);
		StartPath (path);
	}
}
#endif



/*
==============
=
= FinishPath
=
==============
*/

void		FinishPath (int path)
{
	int	count;
	
	count = ops_p[path] - ops[path];
	if (!count)
		return;		// nothing in list
		
	bbox[path][0] -= 1.0;
	bbox[path][1] -= 1.0;
	bbox[path][2] += 1.0;
	bbox[path][3] += 1.0;
	
	NXSetColor ([prefpanel_i colorFor: path]);
	DPSDoUserPath(coords[path], count*2, dps_float, ops[path], count, bbox[path], dps_ustroke);
}


/*
==============
=
= LineInRect
=
==============
*/


#define	RECTPTS	12
#define	LINEPTS		8
#define	RECTOPS	6
#define	LINEOPS		3

#if 0
BOOL	LineInRect (NXPoint *p1, NXPoint *p2, NXRect *r)
{
	float		rectpts[RECTPTS];
	float		linepts[LINEPTS];
	char		rectops[RECTOPS];
	char		lineops[LINEOPS];
	int		hit;
	
//
// build a user path for the rectangle
//
	rectops[0] = dps_setbbox;
	rectpts[0] = r->origin.x-1;
	rectpts[1] = r->origin.y-1;
	rectpts[2] = r->origin.x+r->size.width+1;
	rectpts[3] = r->origin.y+r->size.height+1;
	
	rectops[1] = dps_moveto;
	rectpts[4] = r->origin.x;
	rectpts[5] = r->origin.y;

	rectops[2] = dps_rlineto;
	rectpts[6] = r->size.width;
	rectpts[7] = 0;

	rectops[3] = dps_rlineto;
	rectpts[8] = 0;
	rectpts[9] = r->size.height;

	rectops[4] = dps_rlineto;
	rectpts[10] = -r->size.width;
	rectpts[11] = 0;

	rectops[5] = dps_closepath;

//
// build a user path for the line
//
	lineops[0] = dps_setbbox;
	if (p1->x < p2->x)
	{
		linepts[0] = p1->x-1;
		linepts[2] = p2->x+1;
	}
	else
	{
		linepts[0] = p2->x-1;
		linepts[2] = p1->x+1;
	}
	if (p1->y < p2->y)
	{
		linepts[1] = p1->y-1;
		linepts[3] = p2->y+1;
	}
	else
	{
		linepts[1] = p2->y-1;
		linepts[3] = p1->y+1;
	}
	
	lineops[1] = dps_moveto;
	linepts[4] = p1->x;
	linepts[5] = p1->y;

	lineops[2] = dps_lineto;
	linepts[6] = p2->x;
	linepts[7] = p2->y;

//
// test for intersection
//
	PSWHitPath (rectpts, RECTPTS, rectops, RECTOPS
	, linepts, LINEPTS, lineops, LINEOPS, &hit);
		
	return hit;
}
#endif


typedef int OutCode;

const int INSIDE = 0; // 0000
const int LEFT = 1;   // 0001
const int RIGHT = 2;  // 0010
const int BOTTOM = 4; // 0100
const int TOP = 8;    // 1000

// Compute the bit code for a point (x, y) using the clip rectangle
// bounded diagonally by (xmin, ymin), and (xmax, ymax)

// ASSUME THAT xmax, xmin, ymax and ymin are global constants.

OutCode ComputeOutCode(double x, double y, NSRect r)
{
	OutCode code;
	
	code = INSIDE;          // initialised as being inside of [[clip window]]
	
	if (x < r.origin.x)           // to the left of clip window
		code |= LEFT;
	else if (x > r.origin.x+r.size.width)      // to the right of clip window
		code |= RIGHT;
	if (y < r.origin.y)           // below the clip window
		code |= BOTTOM;
	else if (y > r.origin.y+r.size.height)      // above the clip window
		code |= TOP;
	
	return code;
}

// Cohen–Sutherland clipping algorithm clips a line from
// P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with
// diagonal from (xmin, ymin) to (xmax, ymax).
BOOL LineInRect(double x0, double y0, double x1, double y1, NSRect r)
{
	// compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
	OutCode outcode0 = ComputeOutCode(x0, y0, r);
	OutCode outcode1 = ComputeOutCode(x1, y1, r);
	bool accept = false;
	
	while (true) {
		if (!(outcode0 | outcode1)) {
			// bitwise OR is 0: both points inside window; trivially accept and exit loop
			accept = true;
			break;
		} else if (outcode0 & outcode1) {
			// bitwise AND is not 0: both points share an outside zone (LEFT, RIGHT, TOP,
			// or BOTTOM), so both must be outside window; exit loop (accept is false)
			break;
		} else {
			// failed both tests, so calculate the line segment to clip
			// from an outside point to an intersection with clip edge
			double x, y;
			
			// At least one endpoint is outside the clip rectangle; pick it.
			OutCode outcodeOut = outcode0 ? outcode0 : outcode1;
			
			// Now find the intersection point;
			// use formulas:
			//   slope = (y1 - y0) / (x1 - x0)
			//   x = x0 + (1 / slope) * (ym - y0), where ym is ymin or ymax
			//   y = y0 + slope * (xm - x0), where xm is xmin or xmax
			// No need to worry about divide-by-zero because, in each case, the
			// outcode bit being tested guarantees the denominator is non-zero
			if (outcodeOut & TOP) {           // point is above the clip window
				x = x0 + (x1 - x0) * (r.origin.y+r.size.height - y0) / (y1 - y0);
				y = r.origin.y+r.size.height;
			} else if (outcodeOut & BOTTOM) { // point is below the clip window
				x = x0 + (x1 - x0) * (r.origin.y - y0) / (y1 - y0);
				y = r.origin.y;
			} else if (outcodeOut & RIGHT) {  // point is to the right of clip window
				y = y0 + (y1 - y0) * (r.origin.x+r.size.width - x0) / (x1 - x0);
				x = r.origin.x+r.size.width;
			} else if (outcodeOut & LEFT) {   // point is to the left of clip window
				y = y0 + (y1 - y0) * (r.origin.x - x0) / (x1 - x0);
				x = r.origin.x;
			}
			
			// Now we move outside point to intersection point to clip
			// and get ready for next pass.
			if (outcodeOut == outcode0) {
				x0 = x;
				y0 = y;
				outcode0 = ComputeOutCode(x0, y0, r);
			} else {
				x1 = x;
				y1 = y;
				outcode1 = ComputeOutCode(x1, y1, r);
			}
		}
	}
	return accept;
}


