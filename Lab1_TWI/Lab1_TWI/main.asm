;::::::::::::::::::::::::::::::::::::::::::::
;
; main.asm
;
; TSIU51 -	Lab1 Two Wire Interface
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klasén, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::


;::::::::::::::::
; Övergripande beskrivning av programmet för dokumentation
; Fyll på här eftersom
;
;::::::::::::::::

		jmp		COLD

;::::::::::::::::
;	Data
;::::::::::::::::
		
		; Här kan vi köra satta värden som .equ listor och liknande

		.equ	ADDR_RIGHT8	= $25
		.equ	ADDR_ROTLED	= $26
		.equ	ADDR_SWIT	= $27				
		;.equ	SLA_W		= (ADDR_RIGHT8 << 1) | 0	; $4A 0b01001010
		;.equ	SLA_R		= (ADDR_RIGHT8 << 1) | 1	; $4B 0b01001011

		.equ	SCL		= PC5
		.equ	SDA		= PC4

		.equ	SW_R	= PD0
		.equ	SW_L	= PD1

		.equ	N		= $64							; Styr en sekund delay DELAY_N, som går att variera lite
														; $64 = ~1000,03 ms om DELAY=10ms
														; $3D = ~999,5 ms om DELAY=16ms

SEVEN_SEG:
		.db 	$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
														; LOOKUP-tabell för 0-F i 7-seg (pgfedcba), p=0
;::::::::::::::::
;	Uppstart
;::::::::::::::::


COLD:
														; Initiera stackpekaren
		ldi 	r16, HIGH(RAMEND)
		out 	SPH, r16
		ldi 	r16, LOW(RAMEND)
		out 	SPL, r16

		jmp		KEY_TEST2

;::::::::::::::::
;	Huvudprogram
;::::::::::::::::

TWI_SEND_TEST:
		ldi 	ZH, HIGH(SEVEN_SEG*2)
		ldi 	ZL, LOW(SEVEN_SEG*2)
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

/*
		ldi		r16, $71
		ldi		r17, SLA_W
		call	TWI_SEND
		call	DELAY_N
		rjmp	TWI_SEND_TEST*/


HARD_TEST:
		call	DELAY_N
		call	ROTLED_RED
		call	DELAY_N
		call	ROTLED_OFF
		rjmp	HARD_TEST

READ_TEST:
		ldi		r17, ADDR_SWIT
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

RQ:
		sbis	PIND, 0
		sez
		ret


R1Q:
		call	SWITCHES
		cpi		r16, $FE
		ret

R2Q:
		call	SWITCHES
		cpi		r16, $FD
		ret

LQ:
		sbis	PIND, 1
		sez
		ret

L1Q:
		call	SWITCHES
		cpi		r16, $FB
		ret

L2Q:
		call	SWITCHES
		cpi		r16, $F7
		ret

JOY_RQ:
		call	SWITCHES
		cpi		r16, $EF
		ret

JOY_LQ:
		call	SWITCHES
		cpi		r16, $DF
		ret

SWITCHES:
		ldi		r17, ADDR_SWIT
		call	TWI_READ
		ret

ROTLED_RED:
		ldi		r17, (ADDR_ROTLED << 1) | 0
		ldi		r16, $01						; Obs omvänt röd/grön från hårdvarubeskrivning. Maska eventuellt med en byte i SRAM om LED för L1/L/L2 osv ska användas
		call	TWI_SEND
		ret

ROTLED_GREEN:
		ldi		r17, (ADDR_ROTLED << 1) | 0
		ldi		r16, $02						; Obs omvänt röd/grön från hårdvarubeskrivning. Maska eventuellt med en byte i SRAM om LED för L1/L/L2 osv ska användas
		call	TWI_SEND
		ret

ROTLED_BOTH:
		ldi		r17, (ADDR_ROTLED << 1) | 0
		ldi		r16, $00
		call	TWI_SEND
		ret

ROTLED_OFF:
		ldi		r17, (ADDR_ROTLED << 1) | 0
		ldi		r16, $03
		call	TWI_SEND
		ret

RIGHT8_WRITE:						; (OBS GÖR KLART)
		andi	r16, $0F			; 0000xxxx

	; ---------------

TWI_READ:							; Argument: in=Adress (7bits) i r17, ut=data i r16
		lsl		r17
		ori		r17, $01
		call	START
		call	SEND_ADDR			; (+R)
		call	SCP					; Släpp SDA för att lyssna på ACK + 1 CP
		call	READ_BYTE
		call	SDL					; ACK
		call	STOP
		ret

TWI_SEND:							; Argument: in=Adress (7bits) i r17, in=data i r16
		lsl		r17
		call	START
		call	SEND_ADDR			; (+W')
		call	SDH					; Släpp SDA för att lyssna på ACK + 1 CP
		call	WRITE_BYTE
		call	SDH					; ACK
		call	STOP
		ret

SEND_ADDR:
		push	r16
		mov		r16, r17
		call	WRITE_BYTE
		pop		r16
		ret

READ_BYTE:
		push	r18
		ldi		r18, $08
		clr		r16		
READ_LOOP:
		call	READ_BIT
		dec		r18
		cpi		r18, $00
		brne	READ_LOOP
		pop		r18
		ret

WRITE_BYTE:
		push	r18
		ldi		r18, $08		
WRITE_LOOP:
		call	SEND_BIT
		dec		r18
		cpi		r18, $00
		brne	WRITE_LOOP
		pop		r18
		ret
		
READ_BIT:
		lsl		r16
		sbic	PINC, 4		
		ori		r16, $01
		call	SCP
		ret


SEND_BIT:
		lsl		r16					; byten som ska skrivas måste vara laddad i r16 innan man gör call
		brcc	BIT_LOW
		call	SDH
		rjmp	BIT_WRITE_DONE
BIT_LOW:
		call	SDL
BIT_WRITE_DONE:
		ret



	; ---------------

START:
		sbi		DDRC, SDA
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

	; ---------------

STOP:
		sbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		cbi		DDRC, SDA
		call	WAIT
		ret

	; ---------------

SDL:
		sbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

	; ---------------

SDH:
		cbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

SCP:
		cbi		DDRC, SCL
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

;::	Vänterutiner ::

WAIT:
		push	r16
		ldi		r16, $34
W1:
		dec		r16
		brne	W1
		pop		r16
		ret

	; ---------------

DELAY_N:						; Längre vänteloop, styrt av N som är definerat i början under "Data".
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
								; Vänte-loop, upp till ~16 ms ($FFFF, här 10 ms
		push	r25
		push	r24
		ldi 	r25, $63		; $63C4 ger 160000 cykler för hela rutinen, i princip exakt 10.0 ms
		ldi 	r24, $C4	
D1:
		adiw	r24, 1
		brne	D1
		pop		r24
		pop		r25
		ret