/*
 * tp_labo_test_interruption.asm
 *
 *  Created: 09/11/2014 16:09:27
 *   Author: Carlos
 */ 

.include "m328Pdef.inc"
.org 0					;jump al programa principal
	jmp main
	
.org INT0addr			;ubicacion de la external interrupt 0 (INT0 -> PORTD2)
	jmp sensor	;routina llamada por la interrupcion externa para el sensor hall

main:
	
	;inicializacion stack
	ldi r20, high(RAMEND)
	out SPH, r20
	ldi r20, low(RAMEND)
	out SPL, r20

	ldi r16, 0xFF
	out DDRC, r16
	out PORTC, r16

	;configuracion de interrupcion
	;seteo la interrupcion externa para que se active con flanco descendente
	ldi r20, 1<<ISC01
	sts EICRA, r20; EICRA esta mapeado en memoria, inconsistencias de avr (?)

	;habilito la interrupción INT0 (PORTD2)
	ldi r20, 1 << INT0
	out EIMSK, r20
	
	;habilito las interrupciones globalmente
	sei

	;bucle de prueba
here:
	jmp here;

;definicion de interrupciones
sensor:
	; toggle del portb
	in r21, PORTB
	ldi r22, 0xFF
	eor r21, r22
	out DDRB, r22
	out PORTB, r21

	reti
