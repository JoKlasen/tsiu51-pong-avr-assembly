;::::::::::::::::::::::::::::::::::::::::::::
;
; main.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::


;::::::::::::::::
; �vergripande beskrivning av programmet f�r dokumentation
; Fyll p� h�r eftersom
;
;::::::::::::::::


;::::::::::::::::
;
; TODO:
;       * Massor
;       
;       
; ENDTODO
;::::::::::::::::

        .INCLUDE "port_definitions.asm"

		.org	$0000
		jmp		COLD
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

		;call	SPI_MasterInit
		;call	DA_MEM_INIT
		;call	DA_PRINT_MEM

		call	INIT_TWI
		call	LINE_INIT
		call	LCD_INIT
		call	SPI_MasterInit
		call	TIMER1_INIT
		call	DA_MEM_INIT
		;call	DA_PRINT_MEM
		;call	INIT_USART
		;call	DA_MEM_FLASH
		call 	INIT_PADDLES
		call 	INIT_BALL
		
		clr 	r16
		sts 	COUNTER_UPDATE, r16

		sei

		jmp		PONG_TEST

;::::::::::::::::
;	Huvudprogram
;::::::::::::::::

PONG_TEST:
		jmp		PONG
		

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
;	End of file
;::::::::::::::::