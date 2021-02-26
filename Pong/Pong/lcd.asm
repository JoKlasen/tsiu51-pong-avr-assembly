;::::::::::::::::::::::::::::::::::::::::::::
;
; lcd.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klasén, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Modulen för utskrifter på 2x16 LCDn på DAvid.
;
; Omgjord för överföring med TWI-protokoll.
; Används primärt genom att lagra meddelanden i LINE i SRAM och använda LINE_PRINT, eller hårdkodat meddelande i .db MESSAGE anropat med LCD_FLASH_PRINT
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Gör om rutinerna för att funka med TWI (KLAR)
;       * Stöd för att skriva till båda raderna
;		* Ändra så att LCD_FLASH_PRINT skriver från ett valbart meddelande i flash, skickat som argument
;		* (Ev. samma för LINE, eller bygg på med bättre rutiner för att skriva saker dit.)
;		* Integrera knappstyrning?
;       
; ENDTODO
;::::::::::::::::

#ifndef _LCD_
#define _LCD_

		; Display kommandon						
		.equ	FN_SET	= $28	;0b 001(DL)NF--
		.equ	DISP_ON	= $0F	;0b 00001DCB
		.equ	LCD_CLR	= $01	;0b 00000001
		.equ	E_MODE	= $06	;0b 000001(I/D)S
		.equ	C_HOME	= $02	;0b 0000001-

MESSAGE:					; Max 16 tecken, sträng som skrivs ut med LCD_FLASH_PRINT
		.db		"HELLO WORLD", $00

;::::::::::::::::
;	Rutiner
;::::::::::::::::

;::	Utskrifts-rutiner ::

LCD_PRINT_HEX:							; r16 som indata, skriver ut ett hex-värde för en byte i ascii över två rutor på displayen
		push	r17
		ldi		XH, HIGH(LINE)
		ldi		XL, LOW(LINE)

		call	GET_HIGH_NIBBLE
		call	CONVERT_BIN_TO_HEX_ASCII
		st		X+, r17					; 16-talet i hex lagrat som ascii i LINE+0
		call	GET_LOW_NIBBLE
		call	CONVERT_BIN_TO_HEX_ASCII
		st		X+, r17					; Entalet i hex lagrat som ascii i LINE+1
		ldi		r17, $00				;
		st		X+, r17					; Insert nullbyte

		call	LINE_PRINT
		pop		r17
		ret

GET_HIGH_NIBBLE:
		mov		r17, r16
		swap	r17
		andi	r17, $0F				; Ta in data från r16 höga nibble och maska bort resten.
		ret

GET_LOW_NIBBLE:
		mov		r17, r16
		andi	r17, $0F
		ret

CONVERT_BIN_TO_HEX_ASCII:
		cpi		r17, $0A
		brmi	BELOW_TEN
TEN_OR_ABOVE:
		subi	r17, $09
		ori		r17, $40
		rjmp	CONV_DONE
BELOW_TEN:
		ori		r17, $30
CONV_DONE:
		ret
		
	; ---------------

LCD_FLASH_PRINT:
		ldi 	ZH, HIGH(MESSAGE*2)
		ldi 	ZL, LOW(MESSAGE*2)
		ldi		XH, HIGH(LINE)
		ldi		XL, LOW(LINE)
TRANSFER_CHAR:
		lpm		r16, Z+
		st		X+, r16
		cpi		r16, $00
		brne	TRANSFER_CHAR
		call	LINE_PRINT
		ret

	; ---------------

LINE_PRINT:
		push	r16
		push	ZH
		push	ZL
		call	LCD_HOME
		ldi		ZH, HIGH(LINE)
		ldi		ZL, LOW(LINE)
		call	LCD_PRINT
		pop		ZL
		pop		ZH
		pop		r16
		ret

	; ---------------

LCD_PRINT:
		ld		r16, Z+
		cpi		r16, $00
		breq	PRINT_DONE
		call	LCD_ASCII
		rjmp	LCD_PRINT
PRINT_DONE:
		ret

	; ---------------

LCD_ASCII:
		push	r18
		lds     r18, LCD_PORT
        sbr     r18, (1<<LCD_RS)
		sts		LCD_PORT, r18
		call	LCD_WRITE8
		pop 	r18
		ret

	; ---------------

LCD_COMMAND:
		push	r18
		lds     r18, LCD_PORT
        cbr     r18, (1<<LCD_RS)
		sts		LCD_PORT, r18
		call	LCD_WRITE8
		pop 	r18
		ret

	; ---------------

LCD_WRITE8:
		call	LCD_WRITE4
		swap	r16
		call	LCD_WRITE4
		ret

LCD_WRITE4:
		lds 	r19, LCD_PORT
		mov 	r18, r16
		andi	r18, $F0
		andi	r19, $0F
		add 	r19, r18
		sts 	LCD_PORT, r19
		call	PULSE_E
		call	DELAY
		ret

PULSE_E:
		call	LCD_E_UP
		call	DELAY
		call	LCD_E_DOWN
		ret

LCD_E_UP:
        push    r16
        lds     r16, LCD_PORT
        sbr     r16, (1<<LCD_E)
		call	LCD_WRITE
		pop 	r16
		ret

LCD_E_DOWN:
        push    r16
        lds     r16, LCD_PORT
        cbr     r16, (1<<LCD_E)
		call	LCD_WRITE
		pop 	r16
		ret

LCD_WRITE:
		sts 	LCD_PORT, r16
		ldi 	r17, ADDR_LCD
		call	TWI_SEND
		ret

;::	Display-styrning ::

LCD_COL:								; Kommande för att sätta cursorn till position i r16 (värde från $00-$0F, för andra raden $40-4F
		ori		r16, $80
		call	LCD_COMMAND
		ret

	; ---------------

LCD_ERASE:
		push	r16
		ldi		r16, LCD_CLR
		call	LCD_COMMAND
		pop		r16
		ret

	; ---------------

LCD_HOME:
		push	r16
		ldi		r16, C_HOME
		call	LCD_COMMAND
		pop		r16
		ret

	; ---------------

LCD_BACKLIGHT_ON:
        push    r16
        lds     r16, LCD_PORT
		sbr		r16, (1<<LCD_BL)
        ;sts     LCD_PORT, r16   ; (Göra denna i LCD_WRITE?)
        call	LCD_WRITE       ; med tom indata? command?
        pop     r16
		ret

	; ---------------

LCD_BACKLIGHT_OFF:
        push    r16
        lds     r16, LCD_PORT
		cbr		r16, (1<<LCD_BL)
        ;sts     LCD_PORT, r16
        call	LCD_WRITE       ; med tom indata? command?
        pop     r16
		ret

;::	Initieringsrutiner ::

LINE_INIT:								; Fyller hela LINE med mellanslag (" ", $20) för intitiering av skärmutskriften. Möjliggör utskrift efter en tom ruta (jmf nullbyte som avbryter utskrift)
		ldi		ZH, HIGH(LINE)
		ldi		ZL, LOW(LINE)
		ldi		r16, $20
		clr		r17
LINE_CYCLE:								; Laddar in $20 i LINE+X fram tills LINE+16
		cpi		r17, $10
		breq	LINE_CYCLE_DONE
		st		Z+, r16					
		inc		r17
		rjmp	LINE_CYCLE
LINE_CYCLE_DONE:
		clr		r16
		st		z, r16					; Avslutar med nullbyte i LINE+16
		ret

	; ---------------

LCD_INIT:
		clr 	r16
		sts 	LCD_PORT, r16
							; Tänd bakgrundsljuset
		call	LCD_BACKLIGHT_ON
							; Vänta på att displayen ska vakna
		call	DELAY

							; Initiering av 4-bits mode på displayen
		ldi		r16, $30	
		call	LCD_WRITE4
		call	LCD_WRITE4
		call	LCD_WRITE4
		ldi		r16, $20
		call	LCD_WRITE4
							; Konfigurering
							; 4-bit mode, 2 line, 5x8 font
		ldi		r16, FN_SET	
		call	LCD_COMMAND
							; Display on, cursor on, cursor blink
		ldi		r16, DISP_ON
		call	LCD_COMMAND
							; Clear display
		ldi		r16, LCD_CLR
		call	LCD_COMMAND
							; Entry mode: Increment cursor, no shift
		ldi		r16, E_MODE
		call	LCD_COMMAND
		ret

	; ---------------

LCD_PORT_INIT:
							; Initiering av portriktningar på arduinon
		ldi 	r16, $07	;
		out 	DDRB, r16	; PORTB, bit 0-2 (RS, E och BGLT) till output
		ldi		r16, $F0	;
		out		DDRD, r16	; PORTD, bit 4-7 till output
		ret

	; ---------------

#endif /* _LCD_ */
;::::::::::::::::
;	End of file
;::::::::::::::::