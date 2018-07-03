//
//  postscript.h
//  DoomEd
//
//  Created by Thomas Foster on 7/1/18.
//  Copyright © 2018 Thomas Foster. All rights reserved.
//

#ifndef postscript_h
#define postscript_h

void	PSsetrgbcolor(float red, float green, float blue);
void	PSmoveto(float x, float y);
void	PSsetlinewidth(float width);
void	PSlineto(float x, float y);
void	PSstroke(void);

void	AddLineToPath(NSBezierPath *path, int x1, int y1, int x2, int y2);

#endif /* postscript_h */
