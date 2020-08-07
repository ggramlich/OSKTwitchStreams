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

        lda #1
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%01000000
    }

    :it("keeps sprite 6 enabled"); {
        jsr initState
        ldx #%01000000
        stx SPENA

        lda #1
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #%01000000
    }

    :it("disables sprite 6"); {
        jsr initState
        ldx #%01000000
        stx SPENA

        lda #0
        ldy #6
        jsr libSprites.SetEnable

        :assert_equal SPENA: #0
    }




    :describe("SetFrame")

    :it("sets some frame for sprite 0"); {
        jsr initState

        lda #170
        ldy #0
        jsr libSprites.SetFrame

        :assert_equal SPRITE0: #170
    }

    :it("sets some frame for sprite 7"); {
        jsr initState

        lda #180
        ldy #7
        jsr libSprites.SetFrame

        :assert_equal SPRITE0+7: #180
    }



    :describe("SetY")

    :it("sets y position for sprite 0"); {
        jsr initState

        lda #120
        ldy #0
        jsr libSprites.SetY

        :assert_equal SP0Y: #120
    }

    :it("sets y position for sprite 7"); {
        jsr initState

        lda #130
        ldy #7
        jsr libSprites.SetY

        :assert_equal SP0Y + 2*7: #130
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
    
    ldx #MaximumNoOfSprites-1
    !loop:
        sta SPRITE0,x
        dex
        bne !loop-

    ldx #(2*MaximumNoOfSprites-1)
    !loop:
        sta SP0X,x
        dex
        bne !loop-

    sta MSIGX

    rts
}
