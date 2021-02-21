;::::::::::::::::::::::::::::::::::::::::::::
;
; memory.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Detta är en lista på minnesallokeringar i processorns SRAM.
;
; Bör inkluderas i början av main.asm.
;
;::::::::::::::::

#ifndef _MEM_
#define _MEM_

;::::::::::::::::
;	Minne
;::::::::::::::::

		.dseg
		.org	SRAM_START


LED_STATUS:
        .byte   1

RIGHT8_VAL:
		.byte	1
LEFT8_VAL:
		.byte	1

LCD_LINE1:
	    .byte	17
LCD_LINE2:
	    .byte	17        
CURSOR:	
        .byte	1						; Cursor-position
		
        
        
        .cseg


#endif /* _MEM_ */
;::::::::::::::::
;	End of file
;::::::::::::::::