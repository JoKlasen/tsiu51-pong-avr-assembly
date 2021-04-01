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
	ldi		r16, (1<<WGM12)|(1<<CS11)|(1<<CS10)	; CTC, prescale 64
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
	;call	UPDATE_BALL
	lds 	r16, COUNTER_UPDATE
	inc 	r16
	cpi		r16, $03
	brne	TIMER_DONE
	call 	UPDATE_PADDLE1 ; vänstra planket
	call 	UPDATE_PADDLE2 ; högra planket
	clr 	r16
TIMER_DONE:
	sts 	COUNTER_UPDATE, r16
	pop		r16
	out		SREG, r16
	pop		r16
	reti


; TIMER0_INIT:
; 	push 	r16
; 	ldi		r16, (1<<WGM01)	; CTC, prescale 64
; 	sts		TCCR0A, r16
; 	ldi		r16, (1<<CS02)|(1<<CS01)|(1<<CS00)	; CTC, prescale 64
; 	sts		TCCR0B, r16
; 	;TCCR0B
; 	;OCR0A
	







;::::::::::::::::
;       Paddles
;::::::::::::::::

UPDATE_PADDLE1:
	; READ_JOY_L_V
	; JOY i mitten 7F
	call 	READ_JOY_L_V
	cpi 	r16, $40			; Gå ner
	brcs	INC_PADDLE1
	cpi 	r16, $BF			; Gå upp
	brcc	DEC_PADDLE1
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
	cpi 	r16, $40			; Gå ner
	brcs	INC_PADDLE2
	cpi 	r16, $BF			; Gå upp
	brcc	DEC_PADDLE2
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


;::::::::::::::::
;       Ball
;::::::::::::::::

INIT_BALL:
	; Startposition
	ldi 	ZH, HIGH(BALL)
	ldi 	ZL, LOW(BALL)
	ldi 	r16, 7
	st  	Z+, r16
	ldi		r16, 4
	st 		Z+, r16 
	ldi		r16, 1
	st		Z, r16
	ret

LOAD_BALL:
	ldi 	ZH, HIGH(BALL)
	ldi 	ZL, LOW(BALL)
	ldi		YH, HIGH(GAMEBOARD)
	ldi		YL, LOW(GAMEBOARD)
	ld		r16, Z+				; Ball X-koord
	add		YL, r16				; Lägg till X koord som offset på gameboard-pekaradressen
	brcc	BALL_NO_CARRY_X
	inc 	YH
BALL_NO_CARRY_X:	
	ld  	r16, Z+				; Ball Y-koord
	ldi 	r17, 16
	mul 	r16, r17

	add		YL, R0				; Lägg till Y koord som offset på gameboard-pekaradressen
	brcc	BALL_NO_CARRY_Y
	inc 	YH
	BALL_NO_CARRY_Y:

	ldi 	r16, 'R'
	st  	Y, r16
	ret

UPDATE_BALL:
	lds 	r16, (BALL+2)
	cpi		r16, $01
	breq	MOVE1
	cpi		r16, $02
	breq	MOVE2
	cpi		r16, $03
	breq	MOVE3
	cpi		r16, $04
	breq	MOVE4
	cpi		r16, $05
	breq	MOVE5
	cpi		r16, $06
	breq	MOVE6
	rjmp	UPDATE_END
MOVE1:
	call 	UPD_MOVE1
	rjmp 	UPDATE_END
MOVE2:	
	call  	UPD_MOVE2
	rjmp	UPDATE_END
MOVE3:
	call 	UPD_MOVE3
	rjmp 	UPDATE_END
MOVE4:
	call 	UPD_MOVE4
	rjmp 	UPDATE_END
MOVE5:
	call 	UPD_MOVE5
	rjmp 	UPDATE_END
MOVE6:
	call 	UPD_MOVE6
	rjmp 	UPDATE_END
UPDATE_END:
	ret

SCORE2:
	ldi		r16, $01
	sts     PLAYER2_SCORED, r16	
	ret	
SCORE1:
	ldi		r16, $01
	sts     PLAYER1_SCORED, r16	
	ret		

; MOVE1
UPD_MOVE1:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 0
	breq    MV1SC2			; Om bollen når vägg
	lds		r17, (BALL+1)	; Bollens Y-koord
	cpi 	r17, $07
	breq	UPD_MOVE1_CHANGE_DIR	; Om bollen når tak/golv, byt riktning
	dec 	r16						; Annars öka/minska båda koordinaterna
	sts		BALL, r16
	inc		r17
	sts 	(BALL+1), r17
	rjmp 	UPD_MOVE1_DONE
UPD_MOVE1_CHANGE_DIR:
	lds 	r16, (BALL+2)
	ldi		r17, $02
	add		r16, r17
	sts		(BALL+2), r16
	rjmp	UPD_MOVE1_DONE
MV1SC2:
	call 	SCORE2
UPD_MOVE1_DONE:
	ret

; MOVE2
UPD_MOVE2:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 0
	breq    MV2SC2			; Om bollen når vänstra väggen
	breq	UPD_MOVE2_CHANGE_DIR	;
	dec 	r16						; Annars minska x kordinaten
	sts		BALL, r16
	rjmp 	UPD_MOVE2_DONE
UPD_MOVE2_CHANGE_DIR:
	ldi 	r16, 5
	sts 	BALL+2, r16
	rjmp	UPD_MOVE2_DONE
MV2SC2:
	call 	SCORE2	
UPD_MOVE2_DONE:
	ret	

; MOVE3
UPD_MOVE3:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 0
	breq    MV3SC2			; Om bollen når vägg
	lds		r17, (BALL+1)	; Bollens Y-koord
	cpi 	r17, $00
	breq	UPD_MOVE3_CHANGE_DIR	; Om bollen når tak/golv, byt riktning
	dec 	r16						; Annars öka/minska båda koordinaterna
	sts		BALL, r16
	dec		r17
	sts 	(BALL+1), r17
	rjmp 	UPD_MOVE3_DONE

UPD_MOVE3_CHANGE_DIR:
	ldi		r16, 1
	sts		(BALL+2), r16
	rjmp	UPD_MOVE3_DONE
MV3SC2:
	call 	SCORE2
UPD_MOVE3_DONE:
	ret


; MOVE4
UPD_MOVE4:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 15
	breq    MV4SC1			; Om bollen når vägg
	lds		r17, (BALL+1)	; Bollens Y-koord
	cpi 	r17, 7
	breq	UPD_MOVE4_CHANGE_DIR	; Om bollen når tak/golv, byt riktning
	inc 	r16						; Annars öka/minska båda koordinaterna
	sts		BALL, r16
	dec		r17
	sts 	(BALL+1), r17
	rjmp 	UPD_MOVE4_DONE

UPD_MOVE4_CHANGE_DIR:
	ldi		r16, 1
	sts		(BALL+2), r16
	rjmp	UPD_MOVE4_DONE
MV4SC1:
	call 	SCORE1
UPD_MOVE4_DONE:
	ret	

; MOVE5
UPD_MOVE5:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 15
	breq    MV5SC1			; Om bollen når högra väggen
	breq	UPD_MOVE5_CHANGE_DIR	;
	inc 	r16						; Annars öka x kordinaten
	sts		BALL, r16
	rjmp 	UPD_MOVE5_DONE
UPD_MOVE5_CHANGE_DIR:
	ldi 	r16, 2
	sts 	BALL+2, r16
	rjmp	UPD_MOVE5_DONE
MV5SC1:
	call 	SCORE1	
UPD_MOVE5_DONE:
	ret	


; MOVE6
UPD_MOVE6:
	lds 	r16, BALL		; Bollens X-koord
	cpi		r16, 15
	breq    MV6SC1			; Om bollen når vägg
	lds		r17, (BALL+1)	; Bollens Y-koord
	cpi 	r17, $00
	breq	UPD_MOVE6_CHANGE_DIR	; Om bollen når tak/golv, byt riktning
	dec 	r16						; Annars öka/minska båda koordinaterna
	sts		BALL, r16
	inc		r17
	sts 	(BALL+1), r17
	rjmp 	UPD_MOVE6_DONE

UPD_MOVE6_CHANGE_DIR:
	ldi		r16, 4
	sts		(BALL+2), r16
	rjmp	UPD_MOVE6_DONE
MV6SC1:
	call 	SCORE1
UPD_MOVE6_DONE:
	ret	


;::::::::::::::::
;       Gameboard
;::::::::::::::::

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

;::::::::::::::::
;       If scored
;::::::::::::::::	

PLAYER_SCORED: ; kontrollerar om spelaren och gjort mål och inc score:n
	lds		r16, PLAYER1_SCORED
	cpi		r16, 1
	breq	INC_P1_SCORE
	lds		r16, PLAYER2_SCORED
	cpi		r16, 1
	breq	INC_P2_SCORE
	rjmp 	PLAYER_SCORED_DONE
INC_P1_SCORE:
	clr 	r16
	sts		PLAYER1_SCORED, r16
	lds     r16, P1_SCORE
	inc		r16
	sts		P1_SCORE, r16
	rjmp	PLAYER_SCORED_DONE
INC_P2_SCORE:
	clr 	r16
	sts		PLAYER2_SCORED, r16
	lds     r16, P2_SCORE
	inc		r16
	sts		P2_SCORE, r16
PLAYER_SCORED_DONE:
	ret


;::::::::::::::::
;       GAMELOOP
;::::::::::::::::	


PONG:
	call 	UPDATE_BALL
	call 	UPDATE
	call 	DA_PRINT_MEM
	call 	PLAYER_SCORED
	call	DELAY
	call	DELAY
	call	DELAY
	rjmp 	PONG
	ret

UPDATE:
	call 	CLEAR_GAMEBOARD
	call	LOAD_PADDLES
	call	LOAD_BALL

	call 	LOAD_DA_MEM
	ret

; Laddar kordinaterna till Gameboard



#endif /* _GAME_ENGINE_ */
;::::::::::::::::
;	End of file
;::::::::::::::::