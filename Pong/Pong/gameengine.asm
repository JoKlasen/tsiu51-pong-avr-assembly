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

TIMER1_INT:
	push	r16
	in		r16, SREG
	push	r16
	call 	UPDATE_PADDLE1 ; vänstra planket
	call 	UPDATE_PADDLE2 ; högra planket
	pop		r16
	out		SREG, r16
	pop		r16
	reti

UPDATE_PADDLE1:
	; READ_JOY_L_V
	; JOY i mitten 7F
	call 	READ_JOY_L_V
	cpi 	r16, $40		; Gå upp
	brcs	DEC_PADDLE1
	cpi 	r16, $BF			; Gå ner
	brcc	INC_PADDLE1
	rjmp	RETURN_PADDLE1
DEC_PADDLE1:
	lds 	r16, PADDLE1+1
	cpi 	r16, $00
	breq	RETURN_PADDLE1
	dec 	r16
	sts		PADDLE1+1, r16
	rjmp	RETURN_PADDLE1
INC_PADDLE1:
	lds 	r16, PADDLE1+1
	cpi 	r16, $06
	breq	RETURN_PADDLE1
	inc 	r16
	sts		PADDLE1+1, r16
	rjmp	RETURN_PADDLE1
RETURN_PADDLE1:
	ret


UPDATE_PADDLE2:
	; READ_JOY_R_V
	; JOY i mitten 7E
	call 	READ_JOY_R_V
	cpi 	r16, $40		; Gå upp
	brcs	DEC_PADDLE2
	cpi 	r16, $BF			; Gå ner
	brcc	INC_PADDLE2
	rjmp	RETURN_PADDLE2
DEC_PADDLE2:
	lds 	r16, PADDLE2+1
	cpi 	r16, $00
	breq	RETURN_PADDLE2
	dec 	r16
	sts		PADDLE2+1, r16
	rjmp	RETURN_PADDLE2
INC_PADDLE2:
	lds 	r16, PADDLE2+1
	cpi 	r16, $06
	breq	RETURN_PADDLE2
	inc 	r16
	sts		PADDLE2+1, r16
	rjmp	RETURN_PADDLE2
RETURN_PADDLE2:
	ret

PONG:
	call 	UPDATE
	call 	DA_PRINT_MEM
	rjmp 	PONG
	ret

UPDATE:
	call 	CLEAR_GAMEBOARD
	call	LOAD_PADDLES

	call 	LOAD_DA_MEM
	ret

; Laddar kordinaterna till Gameboard
LOAD_PADDLES:
	ldi 	ZH, HIGH(PADDLE1)
	ldi 	ZL, LOW(PADDLE1)
	call	LOAD_ONE_PADDLE
	; Z = PADDLE2
	call	LOAD_ONE_PADDLE
	ret

LOAD_ONE_PADDLE:
	    ldi		YH, HIGH(GAMEBOARD)
		ldi		YL, LOW(GAMEBOARD)
		ld		r16, Z+				; Paddles X-koord
		add		YL, r16				; Lägg till X koord som offset på gameboard-pekaradressen
		brcc	NO_CARRY_X
		inc 	YH
	NO_CARRY_X:	
		ld  	r16, Z+				; Paddles Y-koord
		ldi 	r17, 16
		mul 	r16, r17
	
		add		YL, R0				; Lägg till Y koord som offset på gameboard-pekaradressen
		brcc	NO_CARRY_Y
		inc 	YH
	NO_CARRY_Y:
									; Här pekar Y på adress i gameboard som motsvarar X,Y-koordinaterna
		ldi 	r16, 'B'
		st  	Y, r16
		adiw    YH:YL, 16
		st  	Y, r16
		ret
CLEAR_GAMEBOARD:
        ldi		YH, HIGH(GAMEBOARD)
		ldi		YL, LOW(GAMEBOARD)
		clr 	r16
        ldi     r17, $80            ; 8 rader x 16 bytes
CLEAR_GAMEBOARD_LOOP:
        st      Y+, r16
        dec     r17
        brne    CLEAR_GAMEBOARD_LOOP
        ret

INIT_PADDLES:
		ldi 	ZH, HIGH(PADDLE1)
		ldi 	ZL, LOW(PADDLE1)
		ldi		r16, 0
		st  	Z+, r16
		ldi		r16, 3
		st  	Z+, r16
		ldi		r16, 15
		st  	Z+, r16
		ldi		r16, 3
		st  	Z+, r16
		ret


#endif /* _GAME_ENGINE_ */
;::::::::::::::::
;	End of file
;::::::::::::::::