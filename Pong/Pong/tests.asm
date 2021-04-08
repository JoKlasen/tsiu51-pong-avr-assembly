;::::::::::::::::::::::::::::::::::::::::::::
;
; tests.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
;   Den här filen innehåller diverse test "huvudprogram" som har används under uppbyggnaden
;   olika subrutiner.
;   Sparad för mer historisk dokumentation, används ej i det riktiga huvudprogrammet.
;
;   Används genom att i slutet av COLD byta "jmp MAIN" till något av nedanstående program.
;
;::::::::::::::::


#ifndef _TESTS_
#define _TESTS_


;::::::::::::::::
;   TEST-PROGRAM
;::::::::::::::::

PONG_TEST:
		jmp		PONG
		
SPEAKER_TEST:
		call	PLAY_NOTE_B
		;ldi 	r16, $02
		;call	DELAY_S
		call	DELAY_N
		call	PLAY_NOTE_A
		;ldi 	r16, $02
		;call	DELAY_S
		call	DELAY_N
		;call	PLAY_NOTE_G
		;ldi 	r16, $02
		;call	DELAY_S
		;call	DELAY
		;call	DELAY
		;call	DELAY
		;call 	STOP_SPEAKER
		;call	DELAY_N
		rjmp	SPEAKER_TEST

GAMEBOARD_TEST:
		call	DA_MEM_INIT
		call	GAMEBOARD_FROM_FLASH
		call	LOAD_DA_MEM
GB_LOOP:
		call	DA_PRINT_MEM
		rjmp	GB_LOOP

DA_TEST:
		
		call 	DA_PRINT_MEM
		rjmp 	DA_TEST


JOY_TEST:
		call	READ_JOY_L_V
		call	LCD_PRINT_HEX
		rjmp	JOY_TEST


LCD_BACKLIGHT_TEST:
		call 	LCD_FLASH_PRINT
		call	DELAY_N
		call	DELAY_N
		

RIGHT8_COUNTER:
		ldi		r18, $00
RCOUNTER_LOOP:
		mov		r16, r18
		;call	UART_SEND
		call	RIGHT8_WRITE
		call	DELAY_N
		cpi		r18, $0F
		breq	RIGHT8_COUNTER
		inc		r18
		rjmp	RCOUNTER_LOOP

TWI_SEND_TEST:
		ldi 	ZH, HIGH(TAB_7SEG*2)
		ldi 	ZL, LOW(TAB_7SEG*2)
		ldi		r18, $0F
TEST_LOOP:
		lpm		r16, Z+
		ldi		r17, ADDR_RIGHT8
		call	TWI_SEND
		call	DELAY_N
		cpi		r18, $00
		breq	TWI_SEND_TEST
		dec		r18
		rjmp	TEST_LOOP

TWI_SEND_TEST2:
		ldi		r16, $71
		ldi		r17, ADDR_RIGHT8
		call	TWI_SEND
		call	DELAY_N
		rjmp	TWI_SEND_TEST2


HARD_TEST:
		lds		r16, LED_STATUS
		ldi		r16, $03
		sts		LED_STATUS, r16
HARD_TEST_LOOP:
		call	DELAY_N
		call	ROTLED_RED
		call	DELAY_N
		call	ROTLED_OFF
		call	ROTLED_GREEN
		call	DELAY_N
		call	ROTLED_OFF
		call	ROTLED_BOTH
		call	DELAY_N
		call	ROTLED_OFF
		rjmp	HARD_TEST_LOOP

READ_TEST:
		ldi		r17, ADDR_SWITCH
		call	TWI_READ
		ldi		r17, ADDR_RIGHT8
		call	TWI_SEND
		rjmp	READ_TEST

KEY_TEST:
		call	L1Q
		brne	NO_KEY
		call	ROTLED_BOTH
		rjmp	KEY_TEST
NO_KEY:
		call	ROTLED_OFF
		rjmp	KEY_TEST

KEY_TEST2:
		call	L1Q
		breq	KEY_PRESSED
		call	L2Q
		breq	KEY_PRESSED
		call	R1Q
		breq	KEY_PRESSED
		call	R2Q
		breq	KEY_PRESSED
		call	JOY_LQ
		breq	KEY_PRESSED
		call	JOY_RQ
		breq	KEY_PRESSED
		call	RQ
		breq	KEY_PRESSED
		call	LQ
		breq	KEY_PRESSED
		call	ROTLED_OFF
		rjmp	KEY_TEST2
KEY_PRESSED:
		call	ROTLED_BOTH
		rjmp	KEY_TEST2


#endif /* _TESTS_ */
;::::::::::::::::
;	End of file
;::::::::::::::::