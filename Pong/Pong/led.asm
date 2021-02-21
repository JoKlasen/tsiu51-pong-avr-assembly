;::::::::::::::::::::::::::::::::::::::::::::
;
; led.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Modulen för hantering av DAvid-kortets lysdioder
;
; Behöver utökas
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Övriga LEDs förutom rotary encoderns LEDs
;
; ENDTODO
;::::::::::::::::

#ifndef _LEDS_
#define _LEDS_


;::::::::::::::::
;	LED-rutiner
;::::::::::::::::

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

	; ---------------

#endif /* _LEDS_ */
;::::::::::::::::
;	End of file
;::::::::::::::::