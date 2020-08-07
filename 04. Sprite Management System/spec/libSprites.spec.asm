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

        :assert_equal libSprites.Y+7: #130
        :assert_equal libSprites.YFrac+7: #0

        :assert_equal SP0Y + 2*7: #130
    }



    :describe("AddToY")

    :it("adds to y position for sprite 6"); {
        jsr initState

        lda #120
        ldy #6
        jsr libSprites.SetY

        // Fraction 0 + 250 = 250
        lda #250
        // Pixel 120 + 3 = 123
        ldx #3
        ldy #6
        jsr libSprites.AddToY

        :assert_equal libSprites.Y+6: #123
        :assert_equal libSprites.YFrac+6: #250
        :assert_equal SP0Y + 2*6: #123

        // Add a second time, make the fraction overflow into pixel
        // Fraction 250 + 10 = 1*256 + 4
        lda #10
        // Pixel 123 + 7 + 1 = 131
        ldx #7
        ldy #6
        jsr libSprites.AddToY

        :assert_equal libSprites.Y+6: #131
        :assert_equal libSprites.YFrac+6: #4
        :assert_equal SP0Y + 2*6: #131
    }



    :describe("SubFromY")

    :it("subtracts from y position for sprite 6"); {
        jsr initState

        lda #120
        ldy #6
        jsr libSprites.SetY

        // Fraction 256 - 250 = 6 (causes underflow in px)
        lda #250
        // Pixel 120 - 3 - 1 = 116
        ldx #3
        ldy #6
        jsr libSprites.SubFromY

        :assert_equal libSprites.Y+6: #116
        :assert_equal libSprites.YFrac+6: #6
        :assert_equal SP0Y + 2*6: #116

        // Subtract a second time, make the fraction underflow into pixel again
        // Fraction 256 + 6 - 10 = 252
        lda #10
        // Pixel 116 - 7 - 1 = 108
        ldx #7
        ldy #6
        jsr libSprites.SubFromY

        :assert_equal libSprites.Y+6: #108
        :assert_equal libSprites.YFrac+6: #252
        :assert_equal SP0Y + 2*6: #108

        // Subtract a third time, no underflow this time
        // Fraction 252 - 30 = 222
        lda #30
        // Pixel 108 - 7 = 101
        ldx #7
        ldy #6
        jsr libSprites.SubFromY

        :assert_equal libSprites.Y+6: #101
        :assert_equal libSprites.YFrac+6: #222
        :assert_equal SP0Y + 2*6: #101

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
