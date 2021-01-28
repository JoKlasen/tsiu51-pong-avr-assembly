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
		.equ	SLA_W		= (ADDR_RIGHT8 << 1) | 0	; $4A 0b01001010
		.equ	SLA_R		= (ADDR_RIGHT8 << 1) | 1	; $4B 0b01001011

		.equ	SCL		= PC5
		.equ	SDA		= PC4


		.equ	N		= $64							; Styr en sekund delay DELAY_N, som går att variera lite
														; $64 = ~1000,03 ms om DELAY=10ms
														; $3D = ~999,5 ms om DELAY=16ms

7SEG:
		.db 	$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
														; LOOKUP-tabell för 0-F i 7-seg (pgfedcba)
;::::::::::::::::
;	Uppstart
;::::::::::::::::


COLD:
														; Initiera stackpekaren
		ldi 	r16, HIGH(RAMEND)
		out 	SPH, r16
		ldi 	r16, LOW(RAMEND)
		out 	SPL, r16


;::::::::::::::::
;	Huvudprogram
;::::::::::::::::


MAIN:
		call	DELAY_N
		call	HARD_0_TWI_SEND
		call	DELAY_N
		call	HARD_7_TWI_SEND
		rjmp	MAIN


;::::::::::::::::
;	Subrutiner
;::::::::::::::::

HARD_0_TWI_SEND:
		call	START
									; Adress $4A 0b01001010
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0

		call	SDH		; ACK
									; Data $3F 0b00111111
		call	SDL					; 0
		call	SDL					; 0
		call	SDH					; 1
		call	SDH					; 1
		call	SDH					; 1
		call	SDH					; 1
		call	SDH					; 1
		call	SDH					; 1

		call	SDH		; ACK

		call	STOP
		ret

	; ---------------

HARD_7_TWI_SEND:
		call	START
									; Adress $4A 0b01001010
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0
		call	SDH					; 1
		call	SDL					; 0

		call	SDH		; ACK
									; Data $07 0b00000111
		call	SDL					; 0
		call	SDL					; 0
		call	SDL					; 0
		call	SDL					; 0
		call	SDL					; 0
		call	SDH					; 1
		call	SDH					; 1
		call	SDH					; 1

		call	SDH		; ACK

		call	STOP
		ret

	; ---------------

TWI_SEND:
		call	START
		;call	SEND_ADR			; +R/W'
									; Släpp SDA för att lyssna på ACK + 1 CP
		;call	SEND_DATA
		call	STOP

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

;::	Vänterutiner ::

WAIT:
		ldi		r16, $34
W1:
		dec		r16
		brne	W1
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