#import <appkit/appkit.h>
#import "NXConvert.h"

void		StartPath (int path);
void		AddLine (int path, float x1, float y1, float x2, float y2);
void		FinishPath (int path);
//BOOL	LineInRect (NXPoint *p1, NXPoint *p2, NXRect *r);
BOOL LineInRect(double x0, double y0, double x1, double y1, NSRect r);
