;::::::::::::::::::::::::::::::::::::::::::::
;
; main.asm
;
; TSIU51 -	Lab1 Two Wire Interface
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::


;::::::::::::::::
; �vergripande beskrivning av programmet f�r dokumentation
; Fyll p� h�r eftersom
;
;::::::::::::::::

		jmp		COLD

;::::::::::::::::
;	Data
;::::::::::::::::
		
		; H�r kan vi k�ra satta v�rden som .equ listor och liknande

		; Adresser
		.equ	ADDR_LEFT8	= $24		; IC2
		.equ	ADDR_RIGHT8	= $25		; IC3
		.equ	ADDR_ROTLED	= $26		; IC4
		.equ	ADDR_SWITCH	= $27		; IC5			
		.equ	SLA_W		= (ADDR_RIGHT8 << 1) | 0	; $4A 0b01001010
		;.equ	SLA_R		= (ADDR_RIGHT8 << 1) | 1	; $4B 0b01001011

		; Arduino pins
		.equ	SCL			= PC5
		.equ	SDA			= PC4

		.equ	SW_R		= PD0
		.equ	SW_L		= PD1

		; IC5, SWITCH 
		.equ	SW_R1		= 0
		.equ	SW_R2		= 1
		.equ	SW_L1		= 2
		.equ	SW_L2		= 3
		.equ	JOY_R_SEL	= 4
		.equ	JOY_L_SEL	= 5

		.equ	N		= $64							; Styr en sekund delay DELAY_N, som g�r att variera lite
														; $64 = ~1000,03 ms om DELAY=10ms
														; $3D = ~999,5 ms om DELAY=16ms

		.equ	TWBR_PRESCALE	= 72
		; F�r USART initiering
		.equ	F_CPU	= 16000000
		.equ	baud	= 9600					; baudrate
		.equ	bps		= (F_CPU/16/baud) - 1	; baud prescale



TAB_7SEG:
		.db 	$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
														; LOOKUP-tabell f�r 0-F i 7-seg (pgfedcba), p=0
;::::::::::::::::
;	Uppstart
;::::::::::::::::


COLD:
														; Initiera stackpekaren
		ldi 	r16, HIGH(RAMEND)
		out 	SPH, r16
		ldi 	r16, LOW(RAMEND)
		out 	SPL, r16

		call	INIT_TWI
		;call	INIT_USART

		jmp		KEY_TEST2

;::::::::::::::::
;	Huvudprogram
;::::::::::::::::

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
		call	DELAY_N
		call	ROTLED_RED
		call	DELAY_N
		call	ROTLED_OFF
		rjmp	HARD_TEST

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

RQ:
		sbis	PIND, SW_R
		sez
		ret


R1Q:
		call	SWITCHES		; Flytta eventuellt ut och g�r ett gemensamt call f�r samtliga queries? Eller ska dom kunna kallas separat?
		;cpi	r16, $FE
		clz						; SWITCHES verkar s�tta Z-flaggan i n�got steg, s� denna beh�vs efter. Mer r�tt med en sbrc innan. Eller kanske v�nda p� sbrs under f�r f�rre instruktioner?
		sbrs	r16, SW_R1		; Kollar om bit SW_R1 (0) i r16 (h�mtat fr�n switches) �r 0 och s�tter d� Z-flaggan
		sez
		ret

R2Q:
		call	SWITCHES
		cpi		r16, $FD		; Den h�r sortens maskning funkar enbart om man trycker en knapp i taget, trycker man ner tv� eller fler knappar kommer ingen att registreras. Alt med andi eller sbrs/sbrc
		ret

LQ:
		sbis	PIND, SW_L
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
		ldi		r17, ADDR_SWITCH
		call	TWI_READ
		ret

ROTLED_RED:
		ldi		r17, ADDR_ROTLED; << 1) | 0
		ldi		r16, $01						; Obs omv�nt r�d/gr�n fr�n h�rdvarubeskrivning. Maska eventuellt med en byte i SRAM om LED f�r L1/L/L2 osv ska anv�ndas
		call	TWI_SEND
		ret

ROTLED_GREEN:
		ldi		r17, ADDR_ROTLED; << 1) | 0
		ldi		r16, $02						; Obs omv�nt r�d/gr�n fr�n h�rdvarubeskrivning. Maska eventuellt med en byte i SRAM om LED f�r L1/L/L2 osv ska anv�ndas
		call	TWI_SEND
		ret

ROTLED_BOTH:
		ldi		r17, ADDR_ROTLED; << 1) | 0
		ldi		r16, $00
		call	TWI_SEND
		ret

ROTLED_OFF:
		ldi		r17, ADDR_ROTLED; << 1) | 0
		ldi		r16, $03
		call	TWI_SEND
		ret

RIGHT8_WRITE:						; Beh�ver indata i r16, kommer enbart kolla l�g nibble
		andi	r16, $0F			; 0000xxxx
		call	LOOKUP_7SEG
		ldi		r17, ADDR_RIGHT8
		call	TWI_SEND
		ret

LEFT8_WRITE:						; Beh�ver indata i r16, kommer enbart kolla l�g nibble
		andi	r16, $0F
		call	LOOKUP_7SEG
		ldi		r17, ADDR_LEFT8
		call	TWI_SEND
		ret

LOOKUP_7SEG:						; Tar BIN/HEX v�rde i r16 (0-15) och omvandlar till r�tt 7-seg symbol (utan punkt) 
		push	ZL
		push	ZH
		ldi 	ZH,HIGH(TAB_7SEG*2)
		ldi 	ZL,LOW(TAB_7SEG*2)
		add 	ZL,r16
		lpm 	r16,Z
		pop 	ZH
		pop 	ZL
		ret

	; ---------------

TWI_SEND:
		lsl 	r17
		call	START
		call 	TWI_WAIT
		call	SEND_ADDR
		call 	TWI_WAIT
		call 	WRITE_BYTE
		call	TWI_WAIT
		call 	STOP
		ret

TWI_READ:
		lsl 	r17
		ori 	r17, $01
		call	START
		call 	TWI_WAIT
		call	SEND_ADDR
		call 	TWI_WAIT
		call 	READ_BYTE
		call	TWI_WAIT
		call 	STOP
		ret

START:
		push	r18
		ldi 	r18, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
		sts 	TWCR, r18
		pop 	r18
		ret

STOP:
		push	r18
		ldi 	r18, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
		sts 	TWCR, r18
		pop 	r18
		ret

SEND_ADDR:
		push	r16
		mov		r16, r17
		call	WRITE_BYTE
		pop		r16
		ret

TWI_WAIT:
		push	r18
	TWI_WAIT_LOOP:	
		lds  	r18,TWCR
		sbrs 	r18,TWINT
		rjmp 	TWI_WAIT_LOOP
		pop 	r18
		ret

WRITE_BYTE:
		push	r18
		sts 	TWDR, r16
		ldi 	r18, (1<<TWINT)|(1<<TWEN)
		sts 	TWCR, r18
		pop 	r18
		ret

READ_BYTE:
		push	r18		
		ldi 	r18, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
		sts 	TWCR, r18
		call 	TWI_WAIT
		lds 	r16, TWDR
		pop 	r18
		ret


; Icke hårdvaru-stödd TWI

; TWI_READ:							; Argument: in=Adress (7bits) i r17, ut=data i r16
; 		lsl		r17
; 		ori		r17, $01
; 		call	START
; 		call	SEND_ADDR			; (+R)
; 		call	SCP					; Sl�pp SDA f�r att lyssna p� ACK + 1 CP
; 		call	READ_BYTE
; 		call	SDL					; ACK
; 		call	STOP
; 		ret

; TWI_SEND:							; Argument: in=Adress (7bits) i r17, in=data i r16
; 		lsl		r17
; 		call	START
; 		call	SEND_ADDR			; (+W')
; 		call	SDH					; Sl�pp SDA f�r att lyssna p� ACK + 1 CP
; 		call	WRITE_BYTE
; 		call	SDH					; ACK
; 		call	STOP
; 		ret

; SEND_ADDR:
; 		push	r16
; 		mov		r16, r17
; 		call	WRITE_BYTE
; 		pop		r16
; 		ret

; READ_BYTE:
; 		push	r18
; 		ldi		r18, $08
; 		clr		r16		
; READ_LOOP:
; 		call	READ_BIT
; 		dec		r18
; 		cpi		r18, $00
; 		brne	READ_LOOP
; 		pop		r18
; 		ret

; WRITE_BYTE:
; 		push	r18
; 		ldi		r18, $08		
; WRITE_LOOP:
; 		call	SEND_BIT
; 		dec		r18
; 		cpi		r18, $00
; 		brne	WRITE_LOOP
; 		pop		r18
; 		ret
		
; READ_BIT:
; 		lsl		r16
; 		sbic	PINC, 4		
; 		ori		r16, $01
; 		call	SCP
; 		ret


; SEND_BIT:
; 		lsl		r16					; byten som ska skrivas m�ste vara laddad i r16 innan man g�r call
; 		brcc	BIT_LOW
; 		call	SDH
; 		rjmp	BIT_WRITE_DONE
; BIT_LOW:
; 		call	SDL
; BIT_WRITE_DONE:
; 		ret



; 	; ---------------

; START:
; 		sbi		DDRC, SDA
; 		call	WAIT
; 		sbi		DDRC, SCL
; 		call	WAIT
; 		ret

; 	; ---------------

; STOP:
; 		sbi		DDRC, SDA
; 		call	WAIT
; 		cbi		DDRC, SCL
; 		call	WAIT
; 		cbi		DDRC, SDA
; 		call	WAIT
; 		ret

; 	; ---------------

; SDL:
; 		sbi		DDRC, SDA
; 		call	WAIT
; 		cbi		DDRC, SCL
; 		call	WAIT
; 		sbi		DDRC, SCL
; 		call	WAIT
; 		ret

; 	; ---------------

; SDH:
; 		cbi		DDRC, SDA
; 		call	WAIT
; 		cbi		DDRC, SCL
; 		call	WAIT
; 		sbi		DDRC, SCL
; 		call	WAIT
; 		ret

; SCP:
; 		cbi		DDRC, SCL
; 		call	WAIT
; 		sbi		DDRC, SCL
; 		call	WAIT
; 		ret

UART_SEND:							; r16 som indata f�r det som ska skickas
		lds		r17,UCSR0A			; load UCSR0A into r17
		sbrs	r17,UDRE0			; wait for empty transmit buffer
		rjmp	UART_SEND			; repeat loop

		mov		r19, r16
		ldi		r20, $30
		add		r19, r20
		sts		UDR0,r19			; transmit character

		ret

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


INIT_TWI:
		ldi		r16, TWBR_PRESCALE
		sts		TWBR, r16
		lds		r16, TWSR
		andi	r16, $FC
		sts		TWSR, r16
		ret

INIT_USART:
		ldi		r16,LOW(bps)		; load baud prescale
		ldi		r17,HIGH(bps)
	
		sts		UBRR0L,r16			; load baud prescale
		sts		UBRR0H,r17			; to UBRR0

		ldi		r16, (1<<RXEN0)|(1<<TXEN0)		; enable transmitter "(1<<RXEN0)|" f�r receiver ocks�
		sts		UCSR0B,r16			; and receiver

		ret	