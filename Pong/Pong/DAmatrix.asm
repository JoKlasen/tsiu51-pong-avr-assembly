;::::::::::::::::::::::::::::::::::::::::::::
;
; DAmatrix.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
;   Den här filen hanterar rutinerna för vår diplay bestående av två horisontellt länkade DAmatrix.
;   
;   Används främst genom utskrift mha "DA_PRINT_MEM" som skriver ut det befintliga värdena i videominnet "DA_MEM" i memory.asm.
;
;   Den finns rutiner för att skriva ut stillbilder från tabeller i flash som laddas till videominnet, 
;   men det är tänkt att man ska sköta detta genom regelbunden överföring från minnestabellen "GAMEBOARD" genom "LOAD_DA_MEM"
; 
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Läs eventuellt in DDRB och or:a in istället vid init (för kompabilitet med högtalaren)
;       * Lös bugg med blinkande lampor om få "pixlar" är tända
;       * Ändra flashutskriftrutin till att ta argument, så kan man mata in vilken laddad tabell som helst. (Bra för vinstskärmar/animationer?)
;         (KLAR se GAMEBOARD_FROM_FLASH_ZPTR)       
;
; ENDTODO
;::::::::::::::::

#ifndef _DAMATRIX_
#define _DAMATRIX_


;::::::::::::::::
;       SPI
;::::::::::::::::

SPI_MasterInit:
; Set MOSI and SCK output, all others input
        ldi     r17, (1<<MATRIX_LATCH)|(1<<MOSI)|(1<<SPI_CLK)
        out     DDRB, r17
; Enable SPI, Master, set clock rate fck/4
        ldi     r17, (1<<SPE)|(1<<MSTR)|(0<<SPR1)|(0<<SPR0)
        out     SPCR, r17
        ret

SPI_OPEN:
    push    r16
    in      r16, PORTB
    cbr     r16, (1<<MATRIX_LATCH)
    out     PORTB, r16
    pop     r16
    ret

SPI_CLOSE:
        push    r16
        in      r16, PORTB
        sbr     r16, (1<<MATRIX_LATCH)
        out     PORTB, r16
        pop     r16
        ret



SPI_SEND_BYTE:
; Start transmission of data (r16)
        out     SPDR, r16
SPI_WAIT:
; Wait for transmission complete
        in      r16, SPSR
        sbrs    r16, SPIF
        rjmp    SPI_WAIT
        ret

;::::::::::::::::
;	DAmatrix
;::::::::::::::::


GAMEBOARD_FROM_FLASH:
        ldi		YH, HIGH(GAMEBOARD)
		ldi		YL, LOW(GAMEBOARD)
        ldi		ZH, HIGH(PIC_RAM*2)
		ldi		ZL, LOW(PIC_RAM*2)
        ldi     r17, $80            ; 8 rader x 16 bytes
GAMEBOARD_FROM_FLASH_LOOP:
        lpm     r16, Z+
        st      Y+, r16
        dec     r17
        brne    GAMEBOARD_FROM_FLASH_LOOP
        ret

DA_MEM_FLASH:
        ldi		YH, HIGH(DAMATRIX_MEM)
		ldi		YL, LOW(DAMATRIX_MEM)
        ldi		ZH, HIGH(PIC*2)
		ldi		ZL, LOW(PIC*2)
        ldi     r17, $30            ; 8 rader x 6 bytes
DA_MEM_FLASH_LOOP:
        lpm     r16, Z+
        st      Y+, r16
        st      Y+, r16
        st      Y+, r16
        dec     r17
        brne    DA_MEM_FLASH_LOOP
        ret

;:::::::::::
; Animering    
;:::::::::::

GAMEBOARD_FROM_FLASH_ZPTR:			; Tar tabell som argument i Z-pekaren
        ldi		YH, HIGH(GAMEBOARD)
		ldi		YL, LOW(GAMEBOARD)
        ldi     r17, $80            ; 8 rader x 16 bytes
GAMEBOARD_FROM_FLASH_ZPTR_LOOP:
        lpm     r16, Z+
        st      Y+, r16
        dec     r17
        brne    GAMEBOARD_FROM_FLASH_ZPTR_LOOP
        ret

FIREWORKS:
		ldi		ZH, HIGH(FW_ANIM1*2)
		ldi		ZL, LOW(FW_ANIM1*2)
		call	GAMEBOARD_FROM_FLASH_ZPTR
		call	LOAD_DA_MEM
		call	DA_PRINT_MEM
		call	DELAY_N
		ldi		ZH, HIGH(FW_ANIM2*2)
		ldi		ZL, LOW(FW_ANIM2*2)
		call	GAMEBOARD_FROM_FLASH_ZPTR
		call	LOAD_DA_MEM
		call	DA_PRINT_MEM
		call	DELAY_N
		ldi		ZH, HIGH(FW_ANIM3*2)
		ldi		ZL, LOW(FW_ANIM3*2)
		call	GAMEBOARD_FROM_FLASH_ZPTR
		call	LOAD_DA_MEM
		call	DA_PRINT_MEM
		call	DELAY_N
		ret

;:::::::::::
; Gameboard        
;:::::::::::


; Laddar från Gameboard till videominne
LOAD_DA_MEM:
        push    YH
        push    YL
        push    ZH
        push    ZL
        ldi	YH, HIGH(DAMATRIX_MEM)
	ldi	YL, LOW(DAMATRIX_MEM)
        ldi	ZH, HIGH(GAMEBOARD)
	ldi	ZL, LOW(GAMEBOARD)

        ldi     r17, 16
LOAD_DA_MEM_LOOP: ; kör 16 gånger (2 displayer) * (8 rader)
        call    READ_GAMEBOARD_TO_DA
        dec     r17
        brne    LOAD_DA_MEM_LOOP

        pop     ZL
        pop     ZH
        pop     YL
        pop     YH
        ret      

; läser en rad från en display och överför data till videominnet
READ_GAMEBOARD_TO_DA: ; x16
        push    r16
        push    r17
        push    r18
        push    r19
        push    r20
        
        clr     r17             ; till röd i videominne
        clr     r18             ; till blå
        clr     r19             ; till grön
        ldi     r20, $80
READ_GAMEBOARD_TO_DA_LOOP:
        ld      r16, Z+
        ; if(r16 = R,B,G)
        cpi     r16, 'R'
        breq    RED
        cpi     r16, 'B'
        breq    BLUE
        cpi     r16, 'G'
        breq    GREEN
        cpi     r16, 'W'
        breq    WHITE
        rjmp    END_IF

RED:
        or      r17, r20             
        rjmp    END_IF
BLUE:
        or      r18, r20
        rjmp     END_IF
GREEN:
        or      r19, r20
        rjmp     END_IF
WHITE:
        or      r17, r20
        or      r18, r20
        or      r19, r20
        rjmp    END_IF
END_IF:
        lsr     r20
        brne    READ_GAMEBOARD_TO_DA_LOOP
        call    DA_TRANSFER_BYTE_TO_DA_MEM
        pop     r20
        pop     r19
        pop     r18
        pop     r17
        pop     r16
        ret
              
; överför en byte till videominnet              
DA_TRANSFER_BYTE_TO_DA_MEM:
        st Y+, r17
        st Y+, r18
        st Y+, r19
        ret


;:::::::::::
; Videominnet        
;:::::::::::
        
; initierar videominnet med 0:or
DA_MEM_INIT:
        ldi	ZH, HIGH(DAMATRIX_MEM)
	ldi	ZL, LOW(DAMATRIX_MEM)
        ldi     r17, $30            ; 8 rader x 6 bytes
DA_MEM_INIT_LOOP:
        ldi     r16, $00
        st      Z+, r16
        dec     r17
        brne    DA_MEM_INIT_LOOP
        ret



;:::::::::::
; Print av videominnet        
;:::::::::::

DA_PRINT_MEM:
        ldi	ZH, HIGH(DA_ROW8 + 6)
        ldi	ZL, LOW(DA_ROW8 + 6)
        ldi     r17, $80 ;0b 1000 0000
        ;call    SPI_OPEN
DA_PRINT_MEM_LOOP:
        call    DA_PRINT_ROW
        brne    DA_PRINT_MEM_LOOP
        ;call    SPI_CLOSE
        ret
        ; $FF - (radnr)^2

DA_PRINT_ROW:

        ; Sätt rad
        mov     r18, r17
        com     r18
        call    SPI_OPEN
        call    DA_PRINT_ONE_DISPLAY
        call    DA_PRINT_ONE_DISPLAY
        call    SPI_CLOSE
        lsr     r17
        ret
        
DA_PRINT_ONE_DISPLAY:
        push    r17
        ldi     r17, $03
DA_PRINT_ONE_DISPLAY_LOOP:
        ld      r16, -Z
        call    SPI_SEND_BYTE
        dec     r17
        brne    DA_PRINT_ONE_DISPLAY_LOOP
        mov     r16, r18
        call    SPI_SEND_BYTE
        pop     r17
        ret


SPI_TEST:
        call    SPI_OPEN
        clr     r16
        call    SPI_SEND_BYTE       ; Grön
        clr     r16
        call    SPI_SEND_BYTE       ; Blå
        ser     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $FE                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad

        clr     r16
        call    SPI_SEND_BYTE       ; Grön
        clr     r16
        call    SPI_SEND_BYTE       ; Blå
        ser     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $FE                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad
        call    SPI_CLOSE

        ;call    DELAY_N
        ;call    DA_PRINT_MEM
        call    DELAY_N

        call    SPI_OPEN
        clr     r16
        call    SPI_SEND_BYTE       ; Grön
        ser     r16
        call    SPI_SEND_BYTE       ; Blå
        clr     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $FE                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad

        clr     r16
        call    SPI_SEND_BYTE       ; Grön
        ser     r16
        call    SPI_SEND_BYTE       ; Blå
        clr     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $FE                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad
        call    SPI_CLOSE

        ;call    DELAY_N
        ;call    DA_PRINT_MEM
        call    DELAY_N

        call    SPI_OPEN
        ser     r16
        call    SPI_SEND_BYTE       ; Grön
        clr     r16
        call    SPI_SEND_BYTE       ; Blå
        clr     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $F7                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad

        ser     r16
        call    SPI_SEND_BYTE       ; Grön
        clr     r16
        call    SPI_SEND_BYTE       ; Blå
        clr     r16
        call    SPI_SEND_BYTE       ; Röd
        ldi     r16, $F7                         ; 11111110, 11111101
        call    SPI_SEND_BYTE       ; Rad
        call    SPI_CLOSE

        ;call    DELAY_N
        ;call    DA_PRINT_MEM
        call    DELAY_N
    
        ret

#endif /* _DAMATRIX_ */
;::::::::::::::::
;	End of file
;::::::::::::::::