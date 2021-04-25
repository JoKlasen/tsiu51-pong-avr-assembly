;::::::::::::::::::::::::::::::::::::::::::::
;
; speaker.asm
;
; TSIU51 -	Mikrodatorprojekt
; Author :	Oskar Lundh, osklu130, Di1b 
;			Johan Klas�n, johkl473, Di1b
;
;::::::::::::::::::::::::::::::::::::::::::::

;::::::::::::::::
;
;   Rutiner för att spela ljud på kortets pizeoelektriska högtalare.
;
;   Genererar med hjälp av interrupts oscillerande på/av signaler på PB1 för att hålla ljudet igång vid
;   en viss frekvens en satt tid.
;
;   Anropas lämpligtvis med hjälp av "PLAY_NOTE_X".
;
;::::::::::::::::

;::::::::::::::::
;
; TODO:
;       * Sekvenser av flera ljud.
;
; ENDTODO;
;::::::::::::::::

#ifndef _SPEAKER_
#define _SPEAKER_
        
        ; F(Speaker Timer)  = 500 000 Hz

        .equ        NOTE_G  = 80       ; = F(ST)/F(G)*2 ; F(G) = 3135.963 Hz
        .equ        NOTE_A  = 71       ; = F(ST)/F(A)*2 ; F(A) = 3520.000 Hz
        .equ        NOTE_B  = 63       ; = F(ST)/F(B)*2 ; F(B) = 3951.066 Hz


        ; Längder för tonerna om dom ska vara 0.05 sekunder
        .equ 		NOTE_G_005_H	= $01
        .equ 		NOTE_G_005_L	= $3A		
        .equ 		NOTE_A_005_H	= $01
        .equ 		NOTE_A_005_L	= $60
        .equ 		NOTE_B_005_H	= $01
        .equ 		NOTE_B_005_L	= $8B


;::::::::::::::::
;       Titel
;::::::::::::::::


TIMER2_INIT:
        push 	r16
                                            ; Set data direction till output för Speaker pin
        ;ldi	r16, (1<<SPEAKER)
	;out	DDRB, r16
        sbi     DDRB, SPEAKER
		
        ldi	r16, (1<<WGM21)	; CTC
        sts	TCCR2A, r16
        ldi	r16, (0<<CS22)|(1<<CS21)|(1<<CS20)	; prescale 32
        sts	TCCR2B, r16
        pop     r16
        ret

ENABLE_SPEAKER_INT:
        ldi	r16, (1<<OCIE2A)			; allow to interrupt
	sts	TIMSK2, r16
        ret

DISABLE_SPEAKER_INT:
        ldi	r16, (0<<OCIE2A)			; allow to interrupt
	sts	TIMSK2, r16
        ret

PLAY_NOTE_G:
        ldi     r16, NOTE_G
        sts     OCR2A, r16
        ldi	r16, NOTE_G_005_H
        sts 	NOTE_LENGTH_HIGH, r16
        ldi 	r16, NOTE_G_005_L
        sts 	NOTE_LENGTH_LOW, r16
        call    ENABLE_SPEAKER_INT
        ret

PLAY_NOTE_A:
        ldi     r16, NOTE_A
        sts     OCR2A, r16
        ldi	r16, NOTE_A_005_H
        sts 	NOTE_LENGTH_HIGH, r16
        ldi 	r16, NOTE_A_005_L
        sts 	NOTE_LENGTH_LOW, r16
        call    ENABLE_SPEAKER_INT
        ret

PLAY_NOTE_B:
        ldi     r16, NOTE_B
        sts     OCR2A, r16
        ldi	r16, NOTE_B_005_H
        sts 	NOTE_LENGTH_HIGH, r16
        ldi 	r16, NOTE_B_005_L
        sts 	NOTE_LENGTH_LOW, r16
        call    ENABLE_SPEAKER_INT
        ret

STOP_SPEAKER:
        cbi	PORTB, PB1
        call    DISABLE_SPEAKER_INT
        ret

SPEAKER_TIMER_INT:
        push	r16
        in	r16, SREG
        push	r16

        call    TOGGLE_SPEAKER
	call	CHECK_NOTE_LENGTH

        pop	r16
        out	SREG, r16
        pop	r16
        reti


TOGGLE_SPEAKER:
        sbis    PORTB, PB1
    	rjmp    TOGGLE_SPEAKER_ON
        rjmp    TOGGLE_SPEAKER_OFF
TOGGLE_SPEAKER_ON:
        sbi	PORTB, PB1
        rjmp    TOGGLE_SPEAKER_DONE
TOGGLE_SPEAKER_OFF:		
	cbi	PORTB, PB1
TOGGLE_SPEAKER_DONE:
        ret


CHECK_NOTE_LENGTH:
        push	r25
        push 	r24
        lds 	r24, NOTE_LENGTH_LOW
        lds 	r25, NOTE_LENGTH_HIGH
        sbiw	r25:r24, 1
        breq	STOP_NOTE
        sts 	NOTE_LENGTH_LOW, r24
        sts 	NOTE_LENGTH_HIGH, r25
        rjmp 	CHECK_NOTE_DONE
STOP_NOTE:
	call	STOP_SPEAKER
CHECK_NOTE_DONE:
	pop 	r24
	pop 	r25
	ret

#endif /* _SPEAKER_ */
;::::::::::::::::
;	End of file
;::::::::::::::::