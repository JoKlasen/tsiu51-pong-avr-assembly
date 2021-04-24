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
;       Timer
;::::::::::::::::

		.equ	TIMER1_TICKS = 31250 - 1	; 1/8 sekund @ 16/64 MHz

TIMER1_INIT:
		push	r16
		ldi		r16, (1<<WGM12)|(1<<CS11)|(1<<CS10)	; CTC, prescale 64
		sts		TCCR1B, r16
		ldi		r16, HIGH(TIMER1_TICKS)
		sts		OCR1AH, r16
		ldi		r16, LOW(TIMER1_TICKS)
		sts		OCR1AL, r16
		ldi		r16, (1<<OCIE1A)			; allow to interrupt
		sts		TIMSK1, r16
		pop		r16
		ret

TIMER1_INT:
		push 	r19
		push 	r18
		push 	r17
		push	r16
		in		r16, SREG
		push	r16
		call	UPDATE_BALL
		lds 	r16, COUNTER_UPDATE
		inc 	r16
		cpi		r16, $02
		brne	TIMER_DONE
		call 	UPDATE_PADDLE1 ; vänstra planket
		call 	UPDATE_PADDLE2 ; högra planket
		clr 	r16
TIMER_DONE:
		sts 	COUNTER_UPDATE, r16
		pop		r16
		out		SREG, r16
		pop		r16
		pop 	r17
		pop 	r18
		pop 	r19
		reti


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

/*INIT_BALL:
		; Startposition
		ldi 	ZH, HIGH(BALL)
		ldi 	ZL, LOW(BALL)
		ldi 	r16, 7
		st  	Z+, r16
		ldi		r16, 4
		st 		Z+, r16 
		ldi		r16, $06
		st		Z, r16
		ret*/

INIT_BALL:
		; Startposition
		ldi 	ZH, HIGH(BALL)
		ldi 	ZL, LOW(BALL)
		lds		r17, TCNT1L		; pseudo-random-värde hämtat från räknare

		sbrc	r17, 2
		ldi 	r16, $07
		sbrs	r17, 2
		ldi		r16, $08
		st  	Z+, r16		; X

		mov		r16, r17
		andi	r16, $07	; Maska med 00000XXX, värde mellan 0-7
		st 		Z+, r16		; Y

		andi	r17, $0F
		cpi		r17, $04
		brlo	DIR_5
		cpi		r17, $08
		brlo	DIR_6
		cpi		r17, $0C
		brlo	DIR_9
DIR_10:
		ldi		r16, $0A
		rjmp	STORE_DIR
DIR_9:
		ldi		r16, $09
		rjmp	STORE_DIR
DIR_6:
		ldi		r16, $06
		rjmp	STORE_DIR
DIR_5:
		ldi		r16, $05
STORE_DIR:	
		st		Z, r16		; Riktning
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

		call	CHECK_SCORING
		call	MOVE_BALL
		call	CHECK_PADDLE_COLLISION
		call	WALL_BOUNCE
		ret

		
CHECK_SCORING:
		lds 	r16, (BALL)		; bollens X
		cpi		r16, $00
		breq	SCORE2
		cpi 	r16, $0F
		breq	SCORE1
		rjmp	CHECK_SCORING_DONE
SCORE2:
		ldi		r16, $01
		sts     PLAYER2_SCORED, r16	
		rjmp	CHECK_SCORING_DONE
SCORE1:
		ldi		r16, $01
		sts     PLAYER1_SCORED, r16	
		rjmp	CHECK_SCORING_DONE
CHECK_SCORING_DONE:
		ret

;Generell move
MOVE_BALL:
		lds 	r16, (BALL)		; bollens X
		lds 	r17, (BALL+1)	; bollens Y
		lds 	r18, (BALL+2)	; "riktning"
		sbrc	r18, 0			; Xr+
		inc 	r16
		sbrc	r18, 1			; Xr-
		dec 	r16
		sbrc	r18, 2			; Yr+
		inc 	r17
		sbrc 	r18, 3			; Yr-
		dec 	r17
		sts		(BALL), r16
		sts 	(BALL+1), r17
		ret


; Kolla om krock med Paddle
CHECK_PADDLE_COLLISION:
		lds 	r16, (BALL)		; bollens X
		lds 	r17, (BALL+1)	; bollens Y
		cpi 	r16, $01
		brne	NO_POT_COLLISION_LEFT
		lds 	r18, (PADDLE1+1)
		cp  	r17, r18
		breq	COLLISION
		inc 	r18
		cp  	r17, r18
		breq	COLLISION
NO_POT_COLLISION_LEFT:
		cpi 	r16, $0E
		brne	NO_COLLISION
		lds 	r18, (PADDLE2+1)
		cp  	r17, r18
		breq	COLLISION
		inc 	r18
		cp  	r17, r18
		breq	COLLISION
		rjmp	NO_COLLISION
COLLISION:
		call	PADDLE_BOUNCE
NO_COLLISION:
		ret


; Generell studs mot paddel
PADDLE_BOUNCE:
		lds 	r16, (BALL)		; bollens X
		lds		r18, (BALL+2)	; "riktning"

		ldi 	r19, $01
		cpi 	r16, $01
		breq	PADDLE_BOUNCE_LEFT	; vänster vägg, -1 på riktning
		cpi 	r16, $0E
		breq	PADDLE_BOUNCE_RIGHT	; höger vägg, +1 på riktning
		rjmp 	PADDLE_BOUNCE_DONE
PADDLE_BOUNCE_LEFT:
		sub 	r18, r19
		sts 	(BALL+2), r18
		rjmp 	PADDLE_BOUNCE_DONE
PADDLE_BOUNCE_RIGHT:
		add 	r18, r19
		sts 	(BALL+2), r18
		rjmp 	PADDLE_BOUNCE_DONE		
PADDLE_BOUNCE_DONE:
		call 	PLAY_NOTE_G
		ret


; Generell studs tak/golv
WALL_BOUNCE:
		lds 	r17, (BALL+1)	; bollens Y
		lds		r18, (BALL+2)	; "riktning"
		
		ldi 	r19, $04
		cpi 	r17, $00
		breq	WALL_BOUNCE_TOP	; tak, -4 på riktning
		cpi 	r17, $07
		breq	WALL_BOUNCE_BOT	; golv, +4 på riktning
		rjmp 	WALL_BOUNCE_DONE
WALL_BOUNCE_TOP:
		sub 	r18, r19
		sts 	(BALL+2), r18
		call 	PLAY_NOTE_B
		rjmp 	WALL_BOUNCE_DONE
WALL_BOUNCE_BOT:
		add 	r18, r19
		sts 	(BALL+2), r18
		call 	PLAY_NOTE_A
		rjmp 	WALL_BOUNCE_DONE		
WALL_BOUNCE_DONE:
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
		cpi 	r16, $05
		brne	P1_NO_WIN
		ldi 	r17, $01
		sts		PLAYER_WIN, r17
P1_NO_WIN:
		call	LEFT8_WRITE
		call 	INIT_BALL
		rjmp	PLAYER_SCORED_DONE
INC_P2_SCORE:
		clr 	r16
		sts		PLAYER2_SCORED, r16
		lds     r16, P2_SCORE
		inc		r16
		sts		P2_SCORE, r16
		cpi		r16, $05
		brne 	P2_NO_WIN
		ldi 	r17, $01
		sts 	PLAYER_WIN, r17
P2_NO_WIN:
		call 	RIGHT8_WRITE
		call 	INIT_BALL
PLAYER_SCORED_DONE:
		et

CHECK_WIN:
		lds 	r16, PLAYER_WIN
		cpi		r16, $01
		ret

;::::::::::::::::
;       GAMELOOP
;::::::::::::::::	


PONG:
		call	DELAY
		call	DELAY
		call	DELAY
		
		call 	UPDATE
		call 	DA_PRINT_MEM
		call	CHECK_WIN
		breq	WIN
		rjmp 	PONG
WIN:
		cli
		call	PRINT_WIN_MSG
		; call	FIREWORKS
		; Spela ljud
		ldi 	r16, $03
		call	DELAY_S		; 3 sekunder
		call	LCD_ERASE
		ret

UPDATE:
		call 	CLEAR_GAMEBOARD
		call	LOAD_PADDLES
		call	LOAD_BALL
		call 	LOAD_DA_MEM
		call 	PLAYER_SCORED
		ret

; Laddar kordinaterna till Gameboard

PRINT_WIN_MSG:
		lds 	r16, P1_SCORE
		cpi 	r16, $05
		brne	OTHER_PLAYER
		ldi 	ZH, HIGH(P1_WINS_MSG*2)
		ldi 	ZL, LOW(P1_WINS_MSG*2)
		rjmp 	WIN_MSG_LOADED
	OTHER_PLAYER:
		ldi 	ZH, HIGH(P2_WINS_MSG*2)
		ldi 	ZL, LOW(P2_WINS_MSG*2)
WIN_MSG_LOADED:
		call 	LCD_FLASH_PRINT
		ret

GAME_INIT:
		call 	INIT_PADDLES
		call 	INIT_BALL
		
		clr 	r16			; Cleara alla flaggor och räknare för spelet i minnet
		ldi 	ZH, HIGH(PLAYER2_SCORED)
		ldi 	ZL, LOW(PLAYER2_SCORED)
		st  	Z+, r16
		st  	Z+, r16
		st  	Z+, r16
		st  	Z+, r16
		st  	Z+, r16
		st  	Z+, r16
		
		call 	LEFT8_WRITE
		clr 	r16
		call	RIGHT8_WRITE

		sei

		ret


#endif /* _GAME_ENGINE_ */
;::::::::::::::::
;	End of file
;::::::::::::::::