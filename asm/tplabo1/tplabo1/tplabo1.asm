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

.include "tp_labo_letras.asm"

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

;rutina que espera que el fan tome velocidad
esperar_fan:
	clr r1
	clr r2
	clr r16

	loop_esperar_fan:
		inc r1
		brne loop_esperar_fan
		inc r2
		brne loop_esperar_fan
		inc r16
		cpi r16, 76
		brne loop_esperar_fan

	ret

;configura el laser
configurar_laser:

	sbi DDRB, PIN_LASER;configura como salida el laser
	cbi PORTB, PIN_LASER;apagado

	ret

;configura la interrupcion del sensor
configurar_interrupcion:
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

	/*
	t = tiempo que tarda en pasar un lado		0 <= t <= 2^16				2 byte
	t_prox_cambio = delta													2 byte			r23:r24

	delta = t / 128							0 <= delta <= 2^6			1 byte			r20
												;dividimos por 128 pixeles por lado
	fila = 0									0 <= fila <= 2^3 - 1		1 byte			r21
	columna = 0									0 <= columna <= 2^7 - 1		1 byte			r22

	while(true)

		dibujar_pixel(fila, columna) ; falta ver como skippear las primeras columnas y las ultimas por las dudas

		if (timer_actual > t_prox_cambio)
			columna++
			t_prox_cambio += delta

	*/

	; numero de columna
	ldi r22, 0;

	; delta = r8:r9
		mov r0, r9
		lsl r0				; r0[1:7] = old_r9[0:6] y r0[0] = 0
		sbrc r8, 7
		inc r0				; r0[0] = old_r8[7]
		mov r8, r0			; r8[0] = old_r8[7] y r8[1:7] = old_r9[0:6]
	
		clr r0
		sbrc r9, 7
		inc r0				; r0[0] = old_r9[7] y r0[1:7] = 0
		mov r9, r0			; r9[0] = old_r9[7] y r9[1:7] = 0

loop_dibujar:
		mov r1, r21					; pasaje de parametros
		mov r2, r22
		jmp rutina_dibujar

vuelta:
		out PORTB, r0
		
esperar:
		; obtengo el valor actual del timer
		lds r10, TCNT1L
		lds r11, TCNT1H

		cp r9, r11
		brmi proxima_columna
		brne esperar
		cp r8, r10
		brmi proxima_columna
		jmp esperar

	proxima_columna:
		inc r22
		cpi r22, 128
		brne loop_dibujar

	; bucle por las dudas
	dibujar_end:
		jmp dibujar_end

;---------- definicion de interrupciones ----------
sensor:
	; obtengo el valor actual del timer y actualizo
	lds r8, TCNT1L
	lds r9, TCNT1H

	; reseteo el timer
	call reset_timer

	inc r21					; incremento el nro de fila
	cpi r21, 8
	brne continue
	clr r21					; si la fila == 8 => fila = 0
	
continue:
	
	sei

	jmp dibujar
	; reti ausente, acordarse de habilitar las interrupciones
