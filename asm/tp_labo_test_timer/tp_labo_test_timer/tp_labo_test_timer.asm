/*
 * tp_labo_test_timer.asm
 *
 *  Created: 09/11/2014 15:11:37
 *   Author: Carlos
 */ 

.include "m328Pdef.inc"
.org 0					;jump al programa principal
	jmp main

main:
	;inicializacion stack
	ldi r20, high(RAMEND)
	out SPH, r20
	ldi r20, low(RAMEND)
	out SPL, r20

	call reset_timer

here:
	jmp here

reset_timer:
	;timer
	;cargo valor inicial del timer en 0 (parte alta y baja)
	ldi r20, 0x00
	sts TCNT1H, r20
	sts TCNT1L, r20

	;cargo la configuracion del timer, modo normal, sin prescaler
	ldi r20, 0x00
	sts TCCR1A, r20

	ldi r20, 1 << CS10
	sts TCCR1B, r20

	ret

parar_timer:
	ldi r20, 0x00
	sts TCCR1B, r20

	ret