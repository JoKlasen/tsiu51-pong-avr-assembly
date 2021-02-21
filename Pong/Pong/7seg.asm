;::::::::::::::::::::::::::::::::::::::::::::
;
; 7seg.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Modulen för manipulering av DAvid-kortets båda 7-segments displayer.
;
; Använder en lookup-tabell för att översätta ett värde mellan 0 och F till 7-seg format.
;
; Anropas med RIGHT8_WRITE/LEFT8_WRITE som tar ett inargument i r16 och skriver ut den låga nibblen.
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Argument för att styra till punkten
;       * Gör en rutin för att skriva ut hel byte(i hex) till båda displayerna (bra för felsökning?)
;       
; ENDTODO
;::::::::::::::::

#ifndef _7_SEG_
#define _7_SEG_

;::::::::::::::::
;	Tabell
;::::::::::::::::

TAB_7SEG:
		.db 	$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7C, $39, $5E, $79, $71
									; LOOKUP-tabell f�r 0-F i 7-seg (pgfedcba), p=0

;::::::::::::::::
;	Rutiner
;::::::::::::::::

RIGHT8_WRITE:						; Beh�ver indata i r16, kommer enbart kolla l�g nibble
		andi	r16, $0F			; 0000xxxx
		call	LOOKUP_7SEG
		ldi		r17, ADDR_RIGHT8
		call	TWI_SEND
		ret

	; ---------------

LEFT8_WRITE:						; Beh�ver indata i r16, kommer enbart kolla l�g nibble
		andi	r16, $0F
		call	LOOKUP_7SEG
		ldi		r17, ADDR_LEFT8
		call	TWI_SEND
		ret

    ; ---------------

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

#endif /* _7_SEG_ */
;::::::::::::::::
;	End of file
;::::::::::::::::