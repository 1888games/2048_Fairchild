	processor f8


	org	$800

	db	$55	;	// cartridge id
	db	$2b	;	// unknown


	include "scripts/macros.asm"

Entry:


	dci sfx.prizeEat
	pi playSong

	li	%00000000	;// 3-colour, green background
	lr	3, A		;// store A to R3
	pi 	clrscrn 	;// call BIOS clear screen

	clr
	Store_Ram RAM.Twenty48Done

	dci sfx.ghostEat
	;pi playSong

	;// Title Screen
	dci	gfx.2048.bmp.parameters	; address of parameters
	pi	blitGraphic

	Clear16Bytes RAM.Time	

TitleSelect:

	pi WaitForInput

	lr a, 1
	ci 0
	bnz TitleSelect

;// Check what game mode selected
	lr a, 2
	ni %00000010

	bnz Twenty48

	lr a, 2
	ni %00000100

	bnz TimeAttack

	lr a, 2
	ni %10000000

	bnz Normal

	jmp TitleSelect


Normal:
	
	li GAME_MODE_NORMAL
	Store_Ram RAM.GameMode

	jmp ReadyToPlay

TimeAttack:

	li GAME_MODE_TIME
	Store_Ram RAM.GameMode

	li 8
	Store_Ram RAM.TimeTens

	li 1
	Store_Ram RAM.TimeHundreds

	pi UpdateTimer

	jmp ReadyToPlay

Twenty48:

	li GAME_MODE_TWENTY
	Store_Ram RAM.GameMode	

ReadyToPlay:

	lr A, 0
	dci RAM.Seed
	st

	dci sfx.move
	pi playSong

	;// Seed our 'random' list


PlayAgain:

	
	Clear16Bytes RAM.Grid
	Clear16Bytes RAM.Moved
	Clear16Bytes RAM.Score


	li	%11000011	;// 3-colour, green background
	lr	3, A		;// store A to R3
	pi 	clrscrn 	;// call BIOS clear screen


	pi GetNewBox
	pi GetNewBox

	jmp Draw2048

Done2048:

	li 0
	Store_Ram RAM.XReg

InitialLoop:
	
	lr 0, a
	pi DrawBox
	pi DrawTile

	Inc_Ram RAM.XReg
	ci 16
	bnz InitialLoop

		pi DisplayScore

TryAgain:

	;jmp TryAgain

	pi WaitForInput

	lr a, 1
	ci 0
	bz NoTimer

	pi UpdateTimer
	lr a, 7
	ci 0
	bz NoTickSound

	dci sfx.move
	pi playSong

NoTickSound:

	pi DisplayScore
	jmp TryAgain

NoTimer:

	Load_Ram RAM.ScoreCounter
	ai 25
	bnc NoWrapping

	li 255

NoWrapping:

	Store_Ram RAM.ScoreCounter

	lr a, 2
	
	ni %00000001
	bz NotRight

	jmp MoveRight

NotRight:

	lr a, 2
	ni %00000010

	bz NotLeft

	jmp MoveLeft

NotLeft:

	lr a, 2
	ni %00000100

	bz NotDown

	jmp MoveDown

NotDown:

	lr a, 2
	ni %00001000

	bz NotUp

	jmp MoveUp

NotUp:

	lr a, 2
	ni %10000000

	bz TryAgain

	jmp Fire


MoveRight:

	Clear16Bytes RAM.Moved

	clr
	Store_Ram RAM.XReg
	Store_Ram RAM.MoveMade
	lr 0, a

RightLoop:
	
	lr a, 0
	;// Get this cell ID
	GetFromArray_A Right
	Store_Ram RAM.CurrentID

	;//Get the column we're in
	Load_Ram RAM.XReg
	GetFromArray_A RightDown
	Store_Ram RAM.CurrentColumn

CascadeLoop:
	
	;// Check if has a number in
	Load_Ram RAM.CurrentID
	GetFromArray_A RAM.Grid
	ci 0
	bnz ContinueRight

	jmp NextRightCell

ContinueRight:

	Store_Ram RAM.Amount

	Load_Ram RAM.CurrentID
	inc
	Store_Ram RAM.TargetID

	;// Check if next block has number
	GetFromArray_A RAM.Grid
	ci 0
	bz MoveIntoRight

	;// Check if matching number
	dci RAM.Amount
	cm
	bz MergeRight

	jmp NextRightCell

MergeRight:
	
	Load_Ram RAM.TargetID
	GetFromArray_A RAM.Moved
	ci 0
	bz OkayToMergeRight

	jmp NextRightCell

OkayToMergeRight:

	Inc_Ram RAM.MoveMade

	;// Clear cell
	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.TargetID
	Increment_Indexed_Ram RAM.Grid

	lr 0, a
	pi AddToScore
	dci sfx.place
	pi playSong

	li 1
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	jmp NextRightCell


MoveIntoRight:
	
	Inc_Ram RAM.MoveMade

	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.Amount
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Grid

	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	;// Check if more space on right
	Inc_Ram RAM.CurrentColumn
	ci 3
	bz NextRightCell

	Inc_Ram RAM.CurrentID

	jmp CascadeLoop


NextRightCell:

	Inc_Ram RAM.XReg
	lr 0, a
	ci 12
	bnz KeepGoingRight

	jmp AddNewBox

KeepGoingRight:

	jmp RightLoop

	
MoveLeft:
	
	Clear16Bytes RAM.Moved

	clr
	Store_Ram RAM.XReg
	Store_Ram RAM.MoveMade
	lr 0, a

LeftLoop:
	
	lr a, 0
	;// Get this cell ID
	GetFromArray_A Left
	Store_Ram RAM.CurrentID

	;//Get the column we're in
	Load_Ram RAM.XReg
	GetFromArray_A LeftUp
	Store_Ram RAM.CurrentColumn

CascadeLoopLeft:
	
	;// Check if has a number in
	Load_Ram RAM.CurrentID
	GetFromArray_A RAM.Grid
	ci 0
	bnz ContinueLeft

	jmp NextLeftCell

ContinueLeft:
	
	

	Store_Ram RAM.Amount

	Load_Ram RAM.CurrentID
	ai 255
	Store_Ram RAM.TargetID

	;// Check if next block has number
	GetFromArray_A RAM.Grid
	ci 0
	bz MoveIntoLeft

	;// Check if matching number
	dci RAM.Amount
	cm
	bz MergeLeft

	jmp NextLeftCell

MergeLeft:

	Load_Ram RAM.TargetID
	GetFromArray_A RAM.Moved
	ci 0
	bz OkayToMergeLeft

	jmp NextLeftCell

OkayToMergeLeft:

	Inc_Ram RAM.MoveMade
	
	;// Clear cell
	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.TargetID
	Increment_Indexed_Ram RAM.Grid

	lr 0, a
	pi AddToScore
	dci sfx.place
	pi playSong

	li 1
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	jmp NextLeftCell


MoveIntoLeft:

	Inc_Ram RAM.MoveMade

	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.Amount
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Grid


	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	;// Check if more space on left
	Dec_Ram RAM.CurrentColumn
	ci 0
	bz NextLeftCell

	Dec_Ram RAM.CurrentID

	jmp CascadeLoopLeft


NextLeftCell:

	Inc_Ram RAM.XReg
	lr 0, a
	ci 12
	bnz KeepGoingLeft

	jmp AddNewBox

KeepGoingLeft:

	jmp LeftLoop


MoveUp:
	
	Clear16Bytes RAM.Moved

	clr
	Store_Ram RAM.XReg
	Store_Ram RAM.MoveMade
	lr 0, a

UpLoop:
	
	lr a, 0
	;// Get this cell ID
	GetFromArray_A Up
	Store_Ram RAM.CurrentID

	;//Get the column we're in
	Load_Ram RAM.XReg
	GetFromArray_A LeftUp
	Store_Ram RAM.CurrentColumn

CascadeLoopUp:
	
	;// Check if has a number in
	Load_Ram RAM.CurrentID
	GetFromArray_A RAM.Grid
	ci 0
	bnz ContinueUp

	jmp NextUpCell

ContinueUp:

	Store_Ram RAM.Amount

	Load_Ram RAM.CurrentID
	ai 252
	Store_Ram RAM.TargetID

	;// Check if next block has number
	GetFromArray_A RAM.Grid
	ci 0
	bz MoveIntoUp

	;// Check if matching number
	dci RAM.Amount
	cm
	bz MergeUp

	jmp NextUpCell


MergeUp:

	Load_Ram RAM.TargetID
	GetFromArray_A RAM.Moved
	ci 0
	bz OkayToMergeUp

	jmp NextUpCell

OkayToMergeUp:
	
	Inc_Ram RAM.MoveMade

	;// Clear cell
	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.TargetID
	Increment_Indexed_Ram RAM.Grid

	lr 0, a
	pi AddToScore
	dci sfx.place
	pi playSong

	li 1
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	jmp NextUpCell


MoveIntoUp:
	
	Inc_Ram RAM.MoveMade

	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.Amount
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Grid

	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	;// Check if more space on left
	Dec_Ram RAM.CurrentColumn
	ci 0
	bz NextUpCell

	Load_Ram RAM.CurrentID
	ai 252
	Store_Ram RAM.CurrentID

	jmp CascadeLoopUp


NextUpCell:

	Inc_Ram RAM.XReg
	lr 0, a
	ci 12
	bnz KeepGoingUp

	jmp AddNewBox

KeepGoingUp:

	jmp UpLoop

MoveDown:

	Clear16Bytes RAM.Moved

	clr
	Store_Ram RAM.XReg
	Store_Ram RAM.MoveMade
	lr 0, a

DownLoop:
	
	lr a, 0
	;// Get this cell ID
	GetFromArray_A Down
	Store_Ram RAM.CurrentID

	;//Get the column we're in
	Load_Ram RAM.XReg
	GetFromArray_A RightDown
	Store_Ram RAM.CurrentColumn

CascadeLoopDown:
	
	;// Check if has a number in
	Load_Ram RAM.CurrentID
	GetFromArray_A RAM.Grid
	ci 0
	bnz ContinueDown

	jmp NextDownCell

ContinueDown:

	Store_Ram RAM.Amount

	Load_Ram RAM.CurrentID
	ai 4
	Store_Ram RAM.TargetID

	;// Check if next block has number
	GetFromArray_A RAM.Grid
	ci 0
	bz MoveIntoDown

	;// Check if matching number
	dci RAM.Amount
	cm
	bz MergeDown

	jmp NextDownCell


MergeDown:

	Load_Ram RAM.TargetID
	GetFromArray_A RAM.Moved
	ci 0
	bz OkayToMergeDown

	jmp NextDownCell

OkayToMergeDown:
	
	Inc_Ram RAM.MoveMade
	;// Clear cell
	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.TargetID
	Increment_Indexed_Ram RAM.Grid

	lr 0, a
	pi AddToScore
	dci sfx.place
	pi playSong

	li 1
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	jmp NextDownCell


MoveIntoDown:
	
	Inc_Ram RAM.MoveMade

	Load_Ram RAM.CurrentID
	Reset_Indexed_RAM RAM.Grid

	Load_Ram RAM.CurrentID
	lr 0, a
	pi DrawBox
	pi DrawTile

	Load_Ram RAM.Amount
	lr 0, a
	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Grid

	Load_Ram RAM.TargetID
	SaveR0ToArray_A RAM.Moved

	Load_Ram RAM.TargetID
	lr 0, a
	pi DrawBox
	pi DrawTile

	;// Check if more space on left
	Inc_Ram RAM.CurrentColumn
	ci 3
	bz NextDownCell

	Load_Ram RAM.CurrentID
	ai 4
	Store_Ram RAM.CurrentID

	jmp CascadeLoopDown


NextDownCell:

	Inc_Ram RAM.XReg
	lr 0, a
	ci 12
	bnz KeepGoingDown

	jmp AddNewBox

KeepGoingDown:

	jmp DownLoop



MoveBlocks:
	



Fire:

	jmp TryAgain


DrawBox:
	
	lr a, 0
	dci RAM.Grid
	adc
	lm
	lr 5, a

	dci Foreground
	adc
	lm
	lr 1, a

	lr a, 5
	dci Background
	adc
	lm
	lr 2, a


	lr a, 0
	dci ColumnX
	adc
	lm
	inc
	lr 3, a

	lr a, 0
	dci ColumnY
	adc
	lm
	lr 4, a

	pop


AddNewBox: 

	Load_Ram RAM.Twenty48Done
	ci 0
	bz Not20482

	jmp GameOver	

Not20482:

	Load_Ram RAM.MoveMade
	ci 0
	bz NoMove

	pi GetNewBox
	lr 0, a
	pi DrawBox
	pi DrawTile

	jmp DisplayScore

NoMove:

	jmp TryAgain




GetNewBox:

	GetRandom
	ni %00001111

	dci RAM.Grid
	lr 1, a
	adc
	lr h, dc0
	lm
	ci 0
	bnz GetNewBox

	lr dc0, h
	li 1
	st

	GetRandom
	ci 230
	bc No4

	lr dc0, h
	li 2
	st

No4:
	
	lr a, 1
	pop


DisplayScore:

	clr
	Store_Ram RAM.XReg

	li 62
	Store_Ram RAM.X

	li 0
	Store_Ram RAM.Y
	lr 0, a

LineLoop:

	li Red
	lr 1, a

	Load_Ram RAM.X
	lr 2, a

	Load_Ram RAM.Y
	lr 3, a

	pi plot

	lr a, 0
	inc
	ci 58
	bz DoneLine

	lr 0, a
	Inc_Ram RAM.Y
	jmp LineLoop

DoneLine:

	li 65
	Store_Ram RAM.X

ScoreLoop:

	;// Score Number
		
	Load_Ram RAM.XReg
	GetFromArray_A RAM.Score
	lr 5, a

	li Green
	lr 1, a	

	li Red
	lr 2, a

	li 25
	lr 4, a

	Load_Ram RAM.X
	lr 3, a

	pi DrawChar

	;// Score Char
	Load_Ram RAM.XReg
	ci 0
	bz NoChar

	ci 6
	bz NoChar

	ai 9
	lr 5, a

	li Red
	lr 2, a

	li Clear
	lr 1, a

	li 18
	lr 4, a

 	Load_Ram RAM.X
	lr 3, a

	pi DrawChar

	;// Timer Number
		
	Load_Ram RAM.XReg
	ai 255
	GetFromArray_A RAM.Time
	lr 5, a

	li Green
	lr 1, a	

	li Blue
	lr 2, a

	li 45
	lr 4, a

	Load_Ram RAM.X
	lr 3, a

	pi DrawChar

	Load_Ram RAM.XReg
	ai 14
	lr 5, a

	li Blue
	lr 2, a

	li Clear
	lr 1, a

	li 38
	lr 4, a

 	Load_Ram RAM.X
	lr 3, a

	pi DrawChar



NoChar:

	Load_Ram RAM.X
	ai 5
	Store_Ram RAM.X

	Inc_Ram RAM.XReg
	ci 7
	bz ScoreDone

	jmp ScoreLoop

ScoreDone:

	

	jmp TryAgain


AddToScore: 


	Load_Ram RAM.GameMode
	ci GAME_MODE_TWENTY
	bnz Not2048

	lr a, 0
	ci 11
	bnz Not2048

	Inc_Ram RAM.Twenty48Done

Not2048:

	lr a, 0
	dci ScoreDigits
	adc
	lm
	Store_Ram RAM.ScoreAddDigits

	lr a, 0
	dci ScoreTens
	adc
	lm
	Store_Ram RAM.ScoreAddTens

	lr a, 0
	dci ScoreHundreds
	adc
	lm
	Store_Ram RAM.ScoreAddHundreds

	lr a, 0
	dci ScoreThousands
	adc
	lm
	Store_Ram RAM.ScoreAddThousands
	

	lr a, 0
	dci ScoreTenThousands
	adc
	lm
	Store_Ram RAM.ScoreAddTenThousands

	lr a, 0
	dci ScoreHundredThousands
	adc
	lm
	Store_Ram RAM.ScoreAddHundredThousands

	;// loop back from digit 6 to digit 1
	li 6
	lr 1, a

;// 0 = temp
;// 1 = digit loop
;// 2 = carry loop

DigitLoop:
		
	;// Get the amount to add to this digit, store in 0
	lr a, 1
	GetFromArray_A RAM.ScoreToAdd
	ci 0
	bz NextDigit
	lr 0, a

	;// add the amount to the current digit value and save
	lr a, 1
	GetFromArray_A RAM.Score
	as 0
	lr 0, a
	lr a, 1
	SaveR0ToArray_A RAM.Score

	ai 246				;//subtract 10
	bm NextDigit		;// test if still positive - need to carry

	;// Save the digit with -10
	lr 0, a
	lr a, 1
	SaveR0ToArray_A RAM.Score
	lr a, 1
	ai 255
	lr 2, a


CarryLoop:
		
	;//Digit index for carry
	lr a, 2
	;//add one to digit and check if carry cascades
	Increment_Indexed_Ram RAM.Score
	ci 10
	bnz NextDigit

	;// set this digit to zero
	lr a, 2
	Reset_Indexed_RAM RAM.Score

	;// add one to next digit
	lr a, 2
	inc
	Increment_Indexed_Ram RAM.Score

	;// check if finished carrying
	lr a, 2
	ai 255
	ci 0
	bz NextDigit
	lr 2, a

	jmp CarryLoop

NextDigit:

	lr a, 1
	ai 255
	ci 0
	bz DoneAdding
	lr 1, a

	jmp DigitLoop



DoneAdding:

	pop



UpdateTimer:
	
	li 0
	lr 7, a

	Load_Ram RAM.GameMode
	ci GAME_MODE_TIME
	bz Reduce

Increase:

	Inc_Ram RAM.TimeDigits
	ci 10
	bnz EndIncrease

	Reset_Ram RAM.TimeDigits
	Inc_Ram RAM.TimeTens
	ci 10
	bnz EndIncrease

	Reset_Ram RAM.TimeTens
	Inc_Ram RAM.TimeHundreds
	ci 10
	bnz EndIncrease

	Reset_Ram RAM.TimeHundreds
	Inc_Ram RAM.TimeThousands
	ci 10
	bnz EndIncrease

	Reset_Ram RAM.TimeThousands
	Inc_Ram RAM.Time

EndIncrease:

	pop

Reduce:
	

	Dec_Ram RAM.TimeDigits
	ci 255
	bnz EndTimeCode

	Load_Ram RAM.TimeTens
	ci 0
	bnz NoTick

	Load_Ram RAM.TimeHundreds
	ci 0
	bnz NoTick

	li 1
	lr 7, a

NoTick:

	li 9
	Store_Ram RAM.TimeDigits

	Dec_Ram RAM.TimeTens
	ci 255
	bnz EndTimeCode

	li 9
	Store_Ram RAM.TimeTens

	Load_Ram RAM.TimeHundreds
	ci 0
	bz GameOver
	
	Dec_Ram RAM.TimeHundreds
	ci 255
	bnz EndTimeCode

	
	li 9
	Store_Ram RAM.TimeHundreds

	Dec_Ram RAM.TimeThousands
	ci 255
	bnz EndTimeCode

	li 9
	Store_Ram RAM.TimeThousands

	Dec_Ram RAM.Time

	pop


EndTimeCode:

	pop


GameOver:
	
	dci sfx.dying.3
	pi playSong

LoopInput:

	pi WaitForInput

	lr a, 1
	ci 0
	bnz LoopInput

	jmp Entry	
	


Draw2048:

	li 65
	Store_Ram RAM.X

	clr
	Store_Ram RAM.XReg

DrawLoop:

	;// Score Number
		
	Load_Ram RAM.XReg
	ai 20
	lr 5, a

	li Transparent
	lr 1, a	

	Load_Ram RAM.XReg
	ci 4
	bz DoRed

	ci 4
	bm DoBlue

	li Green
	lr 2, a
	jmp SaveColour

DoBlue:

	li Blue
	lr 2, a
	jmp SaveColour

DoRed:

	li Red
	lr 2, a
	jmp SaveColour

SaveColour:

	li 2
	lr 4, a

	Load_Ram RAM.X
	lr 3, a

	pi DrawChar

	Load_Ram RAM.X
	ai 5
	Store_Ram RAM.X

	Inc_Ram RAM.XReg
	ci 7
	bz DrawDone

	jmp DrawLoop

DrawDone:
	
	jmp Done2048

Loop:



	jmp Loop


	;org $1600

	
	include "scripts/draw.asm"
	include "scripts/labels.asm"
	include "scripts/bitmaps.asm"
	include "scripts/chars.asm"
	include "scripts/drawing.inc"
	include "scripts/ram.asm"
	include "scripts/input.asm"
	include "scripts/sound.asm"



RandomLookup:

	.byte 29,61,10,138,52,207,52,178,0
  	.byte 168,192,236,42,44,36,42,224,37
  	.byte 39,68,183,60,168,188,246,67,24,18
  	.byte 159,56,24,238,172,103,212,17,24,170,202,50,118
  	.byte 95,33,219,36,169,99,26,242,79,85,138,61,118,50
  	.byte 210,128,110,61,53,44,70,183,212, 101,45,118,124
  	.byte 5,34,212,173,193,83,57,153,200,102,68,40,157,118
  	.byte 59,231,7,237,98,205,14,247,121,19,133,40,20,97,121,
  	.byte 33,76,210,247,136,112,54,252,122,253,25,58,148,46,39,
  	.byte 8,186,125,173,250,229,251,93,85,39,74,89,104,215
   	.byte 180,173,126,245,197,53,139,110,160,38,242,78,116
   	.byte 189,233,27,37,109,163,11,125,33,114,128,179,129,51,11,
   	.byte 67,54,145,7,119,225,186,140,19,169,134,139,227,211
   	.byte 74,254,76,7,206,218,17,224,186,186,137,198,85,103
   	.byte 192,169,142,75,68,194,181,16,66,234,105,193,106,137
    .byte 86,93,70,244,152,75,22,119,108,154,79,250,239,9,203,191
    .byte 35,16,249,72,193,122,236,64,244,160,3,235,60,143
    .byte 8,58,208,155,53,97,206,193,232,183,28,179,121,21
    .byte 33,59,173,224,249,8,141,215,250,87,204,240,137,119
    .byte 143,182

ColumnX:	.byte 2, 17, 32, 47,2, 17, 32, 47,2, 17, 32, 47,2, 17, 32, 47 
ColumnY:	.byte 2, 2, 2, 2, 16, 16, 16, 16, 30, 30, 30, 30, 44, 44, 44, 44


ScoreHundredThousands:	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
ScoreTenThousands:		.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 6, 3
ScoreThousands:			.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 8, 6, 2, 5, 1
ScoreHundreds:			.byte 0, 0, 0, 0, 0, 0, 0, 1, 2, 5, 0, 0, 0, 1, 3, 7, 5, 0
ScoreTens:				.byte 0, 0, 0, 0, 1, 3, 6, 2, 5, 1, 2, 4, 9, 9, 8, 6, 3, 7
ScoreDigits:			.byte 0, 2, 4, 8, 6, 2, 4, 8, 6, 2, 4, 8, 6, 2, 4, 8, 6, 2
		

Up:			.byte 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
Down:		.byte 8, 9, 10, 11, 4, 5, 6, 7, 0, 1, 2, 3
Left:		.byte 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15
Right:		.byte 2, 6, 10, 14, 1, 5, 9, 13, 0, 4, 8, 12

RightDown:	.byte 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0
LeftUp:		.byte 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3


MoveAmount:	.byte -4, 4, -1, 1

Pointers:	.word Up, Down, Left, Right

Background:		.byte Transparent, Green, Green, Blue, Blue, Red, Red, Green, Green, Blue, Blue, Red, Red,Green, Green, Blue, Blue, Red, Red 
Foreground:		.byte Green, Blue, Red, Green, Transparent, Green, Transparent, Blue, Red, Green, Transparent, Green, Transparent, Blue, Red, Green, Transparent, Green, Transparent
   ;//	1	2	3	4	5	6	7	8	9	10		11		12		13		14		15		16		17
   ;//	2	4	8	16	32	64	128	256	512	1024 	2048	4096	8192	16384	32768	65536	131072

    