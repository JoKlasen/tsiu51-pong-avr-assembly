;::::::::::::::::::::::::::::::::::::::::::::
;
; main.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::



        .INCLUDE "port_definitions.asm"

		.org	$0000
		jmp		COLD
		.org 	OC2Aaddr
		jmp 	SPEAKER_TIMER_INT
		.org	OC1Aaddr
		jmp		TIMER1_INT

		.org	INT_VECTORS_SIZE

		.INCLUDE "memory.asm"
        .INCLUDE "twi.asm" 
        .INCLUDE "switches.asm"
        .INCLUDE "7seg.asm"
        .INCLUDE "led.asm"
		.INCLUDE "lcd.asm"
		.INCLUDE "DAmatrix.asm"
		.INCLUDE "gameengine.asm"
		.INCLUDE "speaker.asm"

        .equ	N		= $64


;::::::::::::::::
;	Uppstart
;::::::::::::::::


COLD:
	; Initiera stackpekaren
		ldi 	r16, HIGH(RAMEND)
		out 	SPH, r16
		ldi 	r16, LOW(RAMEND)
		out 	SPL, r16


	; Kör initieringar av hårdvara och minne
		call	INIT_TWI
		call	LINE_INIT
		call	LCD_INIT
		call	SPI_MasterInit
		call	TIMER1_INIT
		call	TIMER2_INIT
		call	DA_MEM_INIT
		call	DA_PRINT_MEM


	; Skriv ut välkomstmeddelande
		ldi 	ZH, HIGH(WELCOME_MSG*2)
		ldi 	ZL, LOW(WELCOME_MSG*2)
		call	LCD_FLASH_PRINT
		ldi 	r16, $02
		call	DELAY_S
		
				; Kör MAIN, eller välj ett testprogram från tests.asm
		jmp		MAIN

;::::::::::::::::
;	Huvudprogram
;::::::::::::::::

MAIN:
	; Skriv ut "redo"-meddelandet
		ldi 	ZH, HIGH(READY_MSG*2)
		ldi 	ZL, LOW(READY_MSG*2)
		call	LCD_FLASH_PRINT

	; Kolla knapptryckningar för att starta spelet
		clz
		call	RQ
		;brne	MAIN	; Avkommentera denna om vi vill att båda spelarna måste trycka "redo" 
		call	LQ
		brne	MAIN

	; Töm LCDn på "redo"-meddelandet
		;call	LINE_INIT
		;call	LINE_PRINT
		call	LCD_ERASE

	; Starta spelet
		call 	GAME_INIT
		call 	PONG
		rjmp 	MAIN




;::::::::::::::::
;	Subrutiner
;::::::::::::::::

;::	V�nterutiner ::

WAIT:
		push	r16
		ldi		r16, $34
W1:
		dec		r16
		brne	W1
		pop		r16
		ret

	; ---------------

DELAY_S:						; Vänteloop som varar i antal sekunder, angivet som argument i r16.
		push	r17
		mov		r17, r16
		ldi		r16, N
DELAY_S1:
		call	DELAY_N
		dec 	r17
		brne	DELAY_S1
		pop		r17
		ret

	; ---------------


DELAY_N:						; L�ngre v�nteloop, styrt av N som �r definerat i b�rjan under "Data".
		push	r16
		ldi		r16, N
DELAY_N1:
		call	DELAY
		dec 	r16
		brne	DELAY_N1
		pop		r16
		ret

	; ---------------

DELAY:						
								; V�nte-loop, upp till ~16 ms ($FFFF, h�r 10 ms
		push	r25
		push	r24
		ldi 	r25, $63		; $63C4 ger 160000 cykler f�r hela rutinen, i princip exakt 10.0 ms
		ldi 	r24, $C4	
D1:
		adiw	r24, 1
		brne	D1
		pop		r24
		pop		r25
		ret



;::::::::::::::::
;	Flashminnes-data
;::::::::::::::::

		.INCLUDE "flash_messages.asm"

;::::::::::::::::
;	End of file
;::::::::::::::::