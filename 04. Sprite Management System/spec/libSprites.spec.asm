#import "../.ra/deps/c64lib/64spec/lib/64spec.asm"
#import "../libSprites.asm"


sfspec:
    :init_spec()

    :describe("SetEnable")

    :it("enables sprite 0"); {
        jsr initState
        ldx #%01001110
        stx SPENA

        lda #1
        ldy #0
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%01001111
    }

    :it("keeps sprite 0 enabled"); {
        jsr initState
        ldx #%01001111
        stx SPENA

        lda #1
        ldy #0
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%01001111
    }

    :it("disables sprite 0"); {
        jsr initState
        ldx #%01001111
        stx SPENA

        lda #0
        ldy #0
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%01001110
    }

    :it("enables sprite 6"); {
        jsr initState
        ldx #%10001110
        stx SPENA

        lda #1
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%11001110
    }

    :it("keeps sprite 6 enabled"); {
        jsr initState
        ldx #%11001110
        stx SPENA

        lda #1
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%11001110
    }

    :it("disables sprite 6"); {
        jsr initState
        ldx #%11001110
        stx SPENA

        lda #0
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%10001110
    }

    :finish_spec()

initState:
{
    // Unfortunately the constant libSprites.MaximumNoOfSprites is not accessible
    .const MaximumNoOfSprites = 8
    .const MARKER = %10110101
    
    // erase all entries in the libSprites arrays
    
    // set an arbitrary MARKER on the last entry of Workspace (which is the last array)
    ldx #(MaximumNoOfSprites-1)
    lda #MARKER
    sta libSprites.Workspace,x

    ldx #0

    // erase until MARKER is found
    !loop: {
        lda #0
        sta libSprites.Enabled,x
        inx
        lda #MARKER
        cmp libSprites.Enabled,x
        bne !loop-
    }
    // overwrite MARKER
    lda #0
    sta libSprites.Enabled,x

    // Make sure, that the loop actually ran to our MARKER and not accidentally found it at some address before
    ldx #(MaximumNoOfSprites-1)
    :assert_equal libSprites.Workspace,x: #0

    // init registers which are affected by the library routines
    lda #0
    sta SPENA
    rts
}
