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


LCD_PORT:
		.byte	1
LINE:
		.byte	17
LCD_LINE1:
	    .byte	17
LCD_LINE2:
	    .byte	17        
CURSOR:	
        .byte	1						; Cursor-position
		
        
DAMATRIX_MEM: ; Vidominnet
										; En rad är Matris 1s GBR följt av matris 2s GBR
DA_ROW1:
		.byte	6
DA_ROW2:
		.byte	6
DA_ROW3:
		.byte	6
DA_ROW4:
		.byte	6
DA_ROW5:
		.byte	6
DA_ROW6:
		.byte	6
DA_ROW7:
		.byte	6
DA_ROW8:
		.byte	6

        
GAMEBOARD: 

GB_ROW1:
		.byte 	16
GB_ROW2:
		.byte 	16
GB_ROW3:
		.byte 	16
GB_ROW4:
		.byte 	16
GB_ROW5:
		.byte 	16
GB_ROW6:
		.byte 	16
GB_ROW7:
		.byte 	16
GB_ROW8:
		.byte 	16


        .cseg


#endif /* _MEM_ */
;::::::::::::::::
;	End of file
;::::::::::::::::