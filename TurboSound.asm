        #include    "plus.inc"
        section code_user

        extern  PT3Player_PlaySongA
        extern  PT3Player_DecodeA
        extern  AYREGSA
        extern  PT3Player_PlaySongB
        extern  PT3Player_DecodeB
        extern  AYREGSB

        defc    NTSC_RELOAD=6

        public  _main
_main:
		; Map user RAM to BANK0 so we can write
		; our interrupt vector to $38
        in      a, (IO_BANK0)           ; Save bank0 mapping
        push    af
        ld      a, USER_RAM             ; Map in USER_RAM
        out     (IO_BANK0), a

        call    initISR

        ld      hl, songA
        xor     a
        call    PT3Player_PlaySongA
        ld      hl, songB
        xor     a
        call    PT3Player_PlaySongB

loop:
        halt
        jr      loop

        pop     af
        out     (IO_BANK0), a
        ret

ROUT:
        XOR     A
        LD      C, D
LOUT:
        OUT     (C), A
        LD      C, E
        OUTI
        LD      C, D
        INC     A
        CP      13
        JR      NZ, LOUT
        OUT     (C), A
        LD      A, (HL)
        AND     A
        RET     M
        LD      C, E
        OUT     (C), A
        RET

ISR:
        push    af
        ex      af, af'
        push    af
        exx

        ; Drop 1 out of every 6 frames
        ld      hl, ntscCount
        dec     (hl)
        jr      z, skipping
noSkip:
        call    PT3Player_DecodeA
        call    PT3Player_DecodeB

        LD      HL, AYREGSA
        LD      DE, (IO_PSG1ADDR<<8)|IO_PSG1DATA
        call    ROUT

        LD      HL, AYREGSB
        LD      DE, (IO_PSG2ADDR<<8)|IO_PSG2DATA
        call    ROUT

skipFrame:
        ; Clear VBLANK interrupt
        ld      a, IRQ_VBLANK
        out     (IO_IRQSTAT), a

        exx
        pop     af
        ex      af, af'
        pop     af

        ei
        ret

skipping:
        ld      (hl), NTSC_RELOAD
        jr      skipFrame

initISR:
        ; Enable VBLANK interrupt
        ld      a, IRQ_VBLANK
        out     (IO_IRQMASK), a

        ; Interrupt mode 1 (rst38)
        IM      1

		; Setup the jump vector at $38
        ld      a, $c3                  ; Opcode for JP
        ld      ($38), a
        ld      hl, ISR                 ; Address of ISR
        ld      ($39), hl

        ei
        ret

        section data_user
ntscCount:
        db      NTSC_RELOAD

        section rodata_user
songA:
        binary  "Shiru - BallQuest2 (2006)-1.pt3"
songB:
        binary  "Shiru - BallQuest2 (2006)-2.pt3"
