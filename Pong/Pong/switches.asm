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
;		* Gör rutiner för joysticksen. (DELVIS KLAR)
;		* Avkoda AD-signaler från dom båda joysticksens två axlar på ett bättre sätt (förslag: 1byte - 2bits/axel för båda joysticksen genom tabell-intervall)
;       * Skriv eventuellt alternativ rutin för att kolla samtliga knappar, eller avkoda SWITCHES.
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

/*
R2Q:
		call	SWITCHES
		cpi		r16, $FD		; Den h�r sortens maskning funkar enbart om man trycker en knapp i taget, trycker man ner tv� eller fler knappar kommer ingen att registreras. Alt med andi eller sbrs/sbrc
		ret
		*/

R2Q:
		call	SWITCHES
		clz		
		sbrs	r16, SW_R2
		sez
		ret

LQ:
		sbis	PIND, SW_L
		sez
		ret

L1Q:
		call	SWITCHES
		clz		
		sbrs	r16, SW_L1
		sez
		ret

L2Q:
		call	SWITCHES
		clz		
		sbrs	r16, SW_L2
		sez
		ret

JOY_RQ:
		call	SWITCHES
		clz		
		sbrs	r16, JOY_R_SEL
		sez
		ret

JOY_LQ:
		call	SWITCHES
		clz		
		sbrs	r16, JOY_L_SEL
		sez
		ret

    ; ---------------

SWITCHES:
		ldi		r17, ADDR_SWITCH
		call	TWI_READ
		ret


;::::::::::::::::
;	Joystick
;::::::::::::::::

READ_JOY_R_H:
		ldi		r16, (1<<REFS0)|(1<<ADLAR)|JOY_R_H		; Väljer kanal för AD-omvandlaren, med 5v referens-spänning och left adjust (8 bitar)
		sts		ADMUX, r16
		call	ADC_READ8
		ret

READ_JOY_R_V:
		ldi		r16, (1<<REFS0)|(1<<ADLAR)|JOY_R_V		; Väljer kanal för AD-omvandlaren, med 5v referens-spänning och left adjust (8 bitar)
		sts		ADMUX, r16
		call	ADC_READ8
		ret

READ_JOY_L_H:
		ldi		r16, (1<<REFS0)|(1<<ADLAR)|JOY_L_H		; Väljer kanal för AD-omvandlaren, med 5v referens-spänning och left adjust (8 bitar)
		sts		ADMUX, r16
		call	ADC_READ8
		ret

READ_JOY_L_V:
		ldi		r16, (1<<REFS0)|(1<<ADLAR)|JOY_L_V		; Väljer kanal för AD-omvandlaren, med 5v referens-spänning och left adjust (8 bitar)
		sts		ADMUX, r16
		call	ADC_READ8
		ret

    ; ---------------

ADC_READ8:								; Returnerar ett värde mellan 0-255 från vald ADC-kanal till r16
		ldi		r16, (1<<REFS0)|(1<<ADLAR)|PC0
		sts		ADMUX, r16
		ldi		r16, (1<<ADEN)|7		; Sätt AD-enable och prescaler till 128 (=> 125 kHz)
		sts		ADCSRA, r16

ADC_CONVERT:							; Starta omvandling
		lds		r16, ADCSRA
		ori		r16, (1<<ADSC)
		sts		ADCSRA, r16
ADC_BUSY:								; Vänta tills omvandling är klar
		lds		r16, ADCSRA
		sbrc	r16, ADSC
		jmp		ADC_BUSY
		lds		r16, ADCH
		ret

	; ---------------


#endif /* _SWITCH_ */
;::::::::::::::::
;	End of file
;::::::::::::::::