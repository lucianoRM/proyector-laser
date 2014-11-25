/*
 * tplabo2.asm
 *
 *  Created: 11/18/2014 7:47:49 PM
 *   Author: Luciano
 */ 


 /*
 * tplabo1.asm
 *
 *  Created: 08/11/2014 9:53:07
 *   Author: Carlos
 */ 

.include "m328Pdef.inc"

.equ PIN_LASER = 0;(PORTB0)
.equ PIN_MOTOR = 0;(PORTC0)

.org 0					;jump al programa principal
	jmp main
	
.org INT0addr			;ubicacion de la external interrupt 0 (INT0 -> PORTD2)
	jmp sensor	;routina llamada por la interrupcion externa para el sensor hall

//.include "tp_labo_letras.asm"

main:
	
	;inicializacion stack
	ldi r20, high(RAMEND)
	out SPH, r20
	ldi r20, low(RAMEND)
	out SPL, r20

	call iniciar_fan
	//call esperar_fan
	call configurar_laser
	call configurar_timer
	call configurar_interrupcion

	;bucle principal, aca se ejecutan las interrupciones
	main_loop:
		jmp main_loop;

;---------- definicion de rutinas ----------
;configura como salida y activa el motor
iniciar_fan:

	sbi DDRC, PIN_MOTOR; configuro como salida el bit del motor
	sbi PORTC, PIN_MOTOR; prendo el motor

	ret


;configura el laser
configurar_laser:

	sbi DDRB, PIN_LASER;configura como salida el laser
	cbi PORTB, PIN_LASER;apagado

	ret

;configura la interrupcion del sensor
configurar_interrupcion:
	clr r21			; limpio fila
	clr r22			; limpio columna
	;configuracion de interrupcion
	;seteo la interrupcion externa para que se active con flanco ascendente
	ldi r20, (1<<ISC01) | (1 <<ISC00)
	sts EICRA, r20; EICRA esta mapeado en memoria, inconsistencias de avr (?)

	;habilito la interrupción INT0 (PORTD2)
	ldi r20, 1 << INT0
	out EIMSK, r20
	
	;habilito las interrupciones globalmente
	sei

	ret

; configura y resetea el timer
configurar_timer:
	;timer
	;cargo valor inicial del timer en 1 (parte alta y baja)
	call reset_timer

	;cargo la configuracion del timer 1, modo normal, sin prescaler
	clr r20
	sts TCCR1A, r20

	ldi r20, 1 << CS10
	sts TCCR1B, r20

	ret	

; resetea el timer 1 (16bit)
reset_timer:
	;timer
	;cargo valor inicial del timer en 1 (parte alta y baja)
	clr r0
	sts TCNT1H, r0
	sts TCNT1L, r0

	ret

; prende y apaga el laser segun el valor actual del laser. No hace falta ret, pues viene de un jmp
dibujar:

	clr r22; Columnas

	//r3:r4 contiene todo el tiempo el momento en el cual tengo que empezar a dibujar la prox columna
	//se inicializa con r3=tiempo que tengo que estar pintando una columna
	clr r4 ; Parte alta de la suma de deltas de tiempo
	mov r3,r2 ; r3 se queda con el delta de tiempo entre columnas.Es la parte alta directamente porque es tiempo/256.

	//En este momento el tiempo a pintar sobre cada lado del par entre interrupciones esta en r2.
	
	
	
dibujar_columna:
	//Pinto fila 0
	clr r0;
	cpi r21,0
	brne sacar0;
	inc r0;
sacar0:
	out PORTB,r0;


check_time:
	lds r1,TCNT1L
	lds r2,TCNT1H
	cp r2,r4 ;comparo partes altas entre timer actual y suma de deltas(timer actual(HIGH) - suma de deltas(HIGH))
	brmi check_time; Espero porque todavia no llegue al tiempo para la proxima columna
	brpl proxima_columna;
	cp r1,r3 ;comparo partes bajas
	brmi check_time;
	jmp proxima_columna;



proxima_columna:
	cpi r16, 1
	breq wait_for_interruption
	inc r16
	inc r22;
	cpi r22, 128;
	brne dibujar_columna;
	inc r21;
	jmp dibujar;

wait_for_interruption:
	jmp wait_for_interruption

	




;---------- definicion de interrupciones ----------
sensor:
	; obtengo el valor actual del timer y actualizo
	lds r1, TCNT1L
	lds r2, TCNT1H

	; reseteo el timer
	call reset_timer

	cpi r16, 1
	breq check_last_col
	inc r21

check_last_col:
	clr r16						; limpio flag que indica si llego a pasar al segundo espejo
	//inc r21					; incremento el nro de fila
	cpi r21, 8
	brne continue
	clr r21					; si la fila == 8 => fila = 0
	
continue:
	
	sei

	jmp dibujar
	; reti ausente, acordarse de habilitar las interrupciones