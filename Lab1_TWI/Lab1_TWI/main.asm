;::::::::::::::::::::::::::::::::::::::::::::
;
; main.asm
;
; TSIU51 -	Lab1 Two Wire Interface
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

; �vergripande beskrivning av programmet f�r dokumentation
;
;

;::::::::::::::::
;	Data
;::::::::::::::::

		.equ	ADDR_RIGHT8	= $25						; H�r kan vi k�ra satta v�rden som .equ listor och liknande
		.equ	SLA_W		= (ADDR_RIGHT8 << 1) | 0
		.equ	SLA_R		= (ADDR_RIGHT8 << 1) | 1

		.equ	SCL		= PC5
		.equ	SDA		= PC4

				MISO
				MOSI
				SCK
				CS_Modul1
				CS_Modul2
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
		call	WAIT_ALT
		rjmp	MAIN


;::::::::::::::::
;	Subrutiner
;::::::::::::::::

TWI_SEND:
		call	START
		call	SEND_ADR			; +R/W'
									; Sl�pp SDA f�r att lyssna p� ACK + 1 CP
		call	SEND_DATA
		call	STOP






START:
		sbi		DDRC, SDA
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

STOP:
		sbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		cbi		DDRC, SDA
		call	WAIT
		ret

SDL:
		sbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

SDH:
		cbi		DDRC, SDA
		call	WAIT
		cbi		DDRC, SCL
		call	WAIT
		sbi		DDRC, SCL
		call	WAIT
		ret

/*WAIT:						
							; V�nte-loop, upp till ~16 ms
		push	r25
		push	r24
		ldi 	r25, $63	; $63C4 ger 160000 cykler f�r hela rutinen, i princip exakt 10.0 ms, $FE6F ~100 �s
		ldi 	r24, $C4	
W1:
		adiw	r24, 1
		brne	W1
		pop		r24
		pop		r25
		ret	*/

WAIT:
		ldi		r16, $34
W1:
		dec		r16
		brne	W1
		ret