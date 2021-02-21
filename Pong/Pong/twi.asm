;::::::::::::::::::::::::::::::::::::::::::::
;
; twi.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
; Modulen för hårdvarustött TWI-protokoll.
;
; Kräver un uppstart med INIT_TWI.
; Man kan sen använda TWI_SEND och TWI_READ för att skicka/ta emot 1 byte data.
;
; Båda använder r16 för indata/utdata, och kräver en adress laddad (7bits format) i r17.
;
; Beroende av portdefinitionerna för SDL och SDA.
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Lägg till felkodshantering
;       * Interuppt-säkra
;       * Gör varianter för att skicka/ta emot mer än 1 byte vid varje transaktion.
;       * Anpassa eventuellt namn till drivrutins-standard
;		
; ENDTODO
;::::::::::::::::

#ifndef _TWI_
#define _TWI_


		.equ	TWBR_PRESCALE	= 72
        ; Bestämmer överföringshastigheten (SCLs frekvens) enligt
        ; F_SCL = F_CPU / (16 + 2 * TWBR * 4^prescaler[TWPS0-1 i TWSR])
        ; Här 100 kHz


;::::::::::::::::
;	INIT_TWI
;::::::::::::::::

INIT_TWI:
		ldi		r16, TWBR_PRESCALE
		sts		TWBR, r16
		lds		r16, TWSR
		andi	r16, $FC
		sts		TWSR, r16
		ret

;::::::::::::::::
;	TWI_SEND
;::::::::::::::::

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

;::::::::::::::::
;	TWI_READ
;::::::::::::::::

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

;::::::::::::::::
;	Subrutiner
;::::::::::::::::

START:
		push	r18
		ldi 	r18, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
		sts 	TWCR, r18
		pop 	r18
		ret

	; ---------------

STOP:
		push	r18
		ldi 	r18, (1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
		sts 	TWCR, r18
		pop 	r18
		ret

	; ---------------

SEND_ADDR:
		push	r16
		mov		r16, r17
		call	WRITE_BYTE
		pop		r16
		ret

	; ---------------
    
TWI_WAIT:
		push	r18
	TWI_WAIT_LOOP:	
		lds  	r18,TWCR
		sbrs 	r18,TWINT
		rjmp 	TWI_WAIT_LOOP
		pop 	r18
		ret

	; ---------------

WRITE_BYTE:
		push	r18
		sts 	TWDR, r16
		ldi 	r18, (1<<TWINT)|(1<<TWEN)
		sts 	TWCR, r18
		pop 	r18
		ret

	; ---------------

READ_BYTE:
		push	r18		
		ldi 	r18, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
		sts 	TWCR, r18
		call 	TWI_WAIT
		lds 	r16, TWDR
		pop 	r18
		ret

	; ---------------

#endif /* _TWI_ */
;::::::::::::::::
;	End of file
;::::::::::::::::