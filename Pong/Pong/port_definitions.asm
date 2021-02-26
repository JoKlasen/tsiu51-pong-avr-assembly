;::::::::::::::::::::::::::::::::::::::::::::
;
; port_definitions.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Detta är en lista på olika portdefinitioner och 
; adresser till de olika twi-expanders på DAvid-kortet.
;
; Bör inkluderas i början av main.asm.
;
;::::::::::::::::

#ifndef _PORT_DEF_
#define _PORT_DEF_

;::::::::::::::::
;	Adresser
;::::::::::::::::

        .equ    ADDR_LCD    = $20       ; IC1
		.equ	ADDR_LEFT8	= $24		; IC2
		.equ	ADDR_RIGHT8	= $25		; IC3
		.equ	ADDR_ROTLED	= $26		; IC4
		.equ	ADDR_SWITCH	= $27		; IC5			
		;.equ	SLA_W		= (ADDR_RIGHT8 << 1) | 0	; $4A 0b01001010
		;.equ	SLA_R		= (ADDR_RIGHT8 << 1) | 1	; $4B 0b01001011

;::::::::::::::::
;	Arduino pins
;::::::::::::::::

		.equ	IR_RX		= PB0	
		.equ	SPEAKER		= PB1		; Piezo-högtalaren (även IR-TX)

		.equ	MATRIX_LATCH= PB2		; SPI CS
		.equ	MOSI		= PB3		; SPI
		.equ	MISO		= PB4		; SPI	(Även RGB-remsan)
		.equ	SPI_CLK		= PB5		; SPI


		.equ	JOY_R_H		= PC0		; Höger joystick x-led
		.equ	JOY_R_V		= PC1		; Höger joystick y-led
		.equ	JOY_L_H		= PC2		; Vänster joystick x-led
		.equ	JOY_L_V		= PC3		; Vänster joystick y-led

		.equ	SDA			= PC4       ; TWI
		.equ	SCL			= PC5       ; TWI
		

		.equ	SW_R		= PD0       ; Tryckknapp R
		.equ	SW_L		= PD1       ; Tryckknapp L

		.equ	RTC_CLK		= PD2		; Realtidsklocka

		.equ	SW_ROT		= PD3		; Tryckknapp vred

		.equ	D_LED_R		= PD4		; LED på kortet, skiljt från LED_R ovan knapp R (IC4)
		.equ	D_LED_L		= PD5		; Se ovan

		.equ	ROT_B		= PD6		; Rotary B
		.equ	ROT_A		= PD7		; Rotary A, undersök vilken av dessa som är höger/vänster

;::::::::::::::::
;	I/O-expanders bit-definitioner
;::::::::::::::::


	;:: IC1, LCD ::
		.equ	LCD_RS		= 0
		.equ	LCD_RW		= 1
		.equ	LCD_E		= 2
		.equ	LCD_BL		= 3
		.equ	LCD_D4  	= 4
		.equ	LCD_D5  	= 5
        .equ	LCD_D6  	= 6
        .equ	LCD_D7  	= 7


	;:: IC4, LEDS ::
		.equ	LED_ROT0	= 0
		.equ	LED_ROT1	= 1
		.equ	LED_L1  	= 2
		.equ	LED_L		= 3
		.equ	LED_L2  	= 4
		.equ	LED_R1  	= 5
        .equ	LED_R     	= 6
        .equ	LED_R2  	= 7


	;:: IC5, SWITCH ::
		.equ	SW_R1		= 0
		.equ	SW_R2		= 1
		.equ	SW_L1		= 2
		.equ	SW_L2		= 3
		.equ	JOY_R_SEL	= 4
		.equ	JOY_L_SEL	= 5


#endif /* _PORT_DEF_ */
;::::::::::::::::
;	End of file
;::::::::::::::::