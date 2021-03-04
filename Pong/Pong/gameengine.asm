;::::::::::::::::::::::::::::::::::::::::::::
;
; gameengine.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
;   Beskrivning
; 
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       *
;
; ENDTODO
;::::::::::::::::

#ifndef _GAME_ENGINE_
#define _GAME_ENGINE_


;::::::::::::::::
;       Titel
;::::::::::::::::


.equ	SECOND_TICKS = 62500 - 1	; @ 16/256 MHz

TIMER1_INIT:
	push	r16
	ldi		r16, (1<<WGM12)|(1<<CS12)	; CTC, prescale 256
	sts		TCCR1B, r16
	ldi		r16, HIGH(SECOND_TICKS)
	sts		OCR1AH, r16
	ldi		r16, LOW(SECOND_TICKS)
	sts		OCR1AL, r16
	ldi		r16, (1<<OCIE1A)			; allow to interrupt
	sts		TIMSK1, r16
	pop		r16
	ret



#endif /* _GAME_ENGINE_ */
;::::::::::::::::
;	End of file
;::::::::::::::::