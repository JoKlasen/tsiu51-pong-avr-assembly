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

										; H�r kan vi k�ra satta v�rden som .equ listor och liknande


;::::::::::::::::
;	Uppstart
;::::::::::::::::


START:
										; Initiera stackpekaren
		ldi 	r16, HIGH(RAMEND)
		out 	SPH, r16
		ldi 	r16, LOW(RAMEND)
		out 	SPL, r16


;::::::::::::::::
;	Huvudprogram
;::::::::::::::::


MAIN:
		call	WAIT
		rjmp	MAIN


;::::::::::::::::
;	Subrutiner
;::::::::::::::::

WAIT:						
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
		ret	