
#import <appkit/appkit.h>
#import "EditWorld.h"
#import "NXConvert.h"

extern	id	linepanel_i;
extern	id	lineSpecialPanel_i;

@interface LinePanel:Object
{
	IBOutlet id	p1_i;
	IBOutlet id	p2_i;
	IBOutlet id	special_i;
	
	IBOutlet id pblock_i;
	IBOutlet id toppeg_i;
	IBOutlet id bottompeg_i;
	IBOutlet id twosided_i;
	IBOutlet id secret_i;
	IBOutlet id soundblock_i;
	IBOutlet id dontdraw_i;
	IBOutlet id monsterblock_i;
	
	IBOutlet id	sideradio_i;
	IBOutlet id	sideform_i;
	IBOutlet id	tagField_i;
	IBOutlet id	linelength_i;
	
	id	window_i;
	id	firstColCalc_i;
	id	fc_currentVal_i;
	id	fc_incDec_i;
	worldline_t	baseline, oldline;
}

- emptySpecialList;
- menuTarget:sender;
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
