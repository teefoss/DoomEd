
#import <appkit/appkit.h>
#import "EditWorld.h"
#import "NXConvert.h"

extern	id	linepanel_i;
extern	id	lineSpecialPanel_i;

@interface LinePanel:Object
{
	id	p1_i;
	id	p2_i;
	id	special_i;
	
	id pblock_i;
	id toppeg_i;
	id bottompeg_i;
	id twosided_i;
	id secret_i;
	id soundblock_i;
	id dontdraw_i;
	id monsterblock_i;
	
	id	sideradio_i;
	id	sideform_i;
	id	tagField_i;
	id	linelength_i;
	
	id	window_i;
	id	firstColCalc_i;
	id	fc_currentVal_i;
	id	fc_incDec_i;
	worldline_t	baseline, oldline;
}

- emptySpecialList;
- (IBAction)menuTarget:sender;
- updateInspector: (BOOL)force;
- sideRadioTarget:sender;
- updateLineInspector;

- (IBAction)monsterblockChanged:sender;
- (IBAction)blockChanged: sender;
- (IBAction)twosideChanged: sender;
- (IBAction)toppegChanged: sender;
- (IBAction)bottompegChanged: sender;
- (IBAction)secretChanged:sender;
- (IBAction)soundBlkChanged:sender;
- (IBAction)dontDrawChanged:sender;
- (IBAction)specialChanged: sender;
- (IBAction)tagChanged: sender;
- (IBAction)sideChanged: sender;

- getFromTP:sender;
- setTP:sender;
- zeroEntry:sender;
- suggestTagValue:sender;
- (int)getTagValue;

// FIRSTCOL CALCULATOR
- (IBAction)setFCVal:sender;
- (IBAction)popUpCalc:sender;
- (IBAction)incFirstCol:sender;
- (IBAction)decFirstCol:sender;

-baseLine: (worldline_t *)line;

- updateLineSpecial;
- activateSpecialList:sender;
- updateLineSpecialsDSP:(FILE *)stream;
@end
