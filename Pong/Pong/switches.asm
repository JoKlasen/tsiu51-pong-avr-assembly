;::::::::::::::::::::::::::::::::::::::::::::
;
; switches.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Modulen för hantering av DAvid-kortets knappar
;
; Använder just nu query-anrop för enskilda knappar, sätter Z-flaggan vid knapptryck.
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Skriv eventuellt alternativ rutin för att kolla samtliga knappar
;
; ENDTODO
;::::::::::::::::

#ifndef _SWITCH_
#define _SWITCH_


;::::::::::::::::
;	Knapp-queries
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

    ; ---------------

SWITCHES:
		ldi		r17, ADDR_SWITCH
		call	TWI_READ
		ret

	; ---------------

#endif /* _SWITCH_ */
;::::::::::::::::
;	End of file
;::::::::::::::::