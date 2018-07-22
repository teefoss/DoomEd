
#import "TextLog.h"

@implementation TextLog

//======================================================
//
//	TextLog Class
//
//	Simply lets you send a bunch of strings to a list (for errors and status info)
//
//======================================================

- initTitle:(NSString *)title
{
	window_i = [NSBundle loadNibNamed:@"textlog" owner:self];
	
//	window_i =	[NXApp
//				loadNibSection:	"TextLog.nib"
//				owner:			self
//				withNames:		NO
//				];
	
	//[window_i	setTitle:title ];
	return self;
}

- msg:(char *)string
{
//	int		len;
//
//	len = [text_i textLength];
//	[text_i setSel:len :len];
//	[text_i replaceSel:string];
//	[text_i	scrollSelToVisible];

	int		len;

	NSString *newtext = [[NSString alloc] initWithCString:string encoding:NSUTF8StringEncoding];
	NSString *current = [[NSString alloc] initWithString:[text_i string]];
	NSString *newstr = [current stringByAppendingString:newtext];
	
	[text_i setString:newstr];
	
	return self;
}

- display:sender
{
	//[window_i	makeKeyAndOrderFront:NULL];
	[window_i makeKeyAndOrderFront:self];
	return self;
}

- clear:sender
{
//	int		len;
//
//	len = [text_i textLength];
//	[text_i setSel:0 :len];
//	[text_i replaceSel:"\0"];
	[text_i setString:@""];

	return self;
}

@end
