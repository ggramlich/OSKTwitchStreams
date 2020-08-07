#import "64spec/lib/64spec.asm"
#import "libSprites.asm"

initState:
{

  .const MARKER = %10110101
  lda #MARKER
  sta libSprites.Workspace

  ldx #0

  !loop: {
    lda #0
    sta libSprites.Enabled,x
    inx
    lda #MARKER
    cmp libSprites.Enabled,x
    bne !loop-
  }
  lda #0
  sta SPENA
  rts
}

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
