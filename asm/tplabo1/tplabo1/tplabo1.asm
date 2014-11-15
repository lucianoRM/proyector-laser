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

ultima_duracion_vuelta_h:
	.dw 0x00
ultima_duracion_vuelta_l:
	.dw 0x00

main:
	
	;inicializacion stack
	ldi r20, high(RAMEND)
	out SPH, r20
	ldi r20, low(RAMEND)
	out SPL, r20

	call iniciar_fan
	call esperar_fan
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
	;seteo la interrupcion externa para que se active con flanco descendente
	ldi r20, 1<<ISC01
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
	ldi r20, 0x00
	sts TCNT1H, r20
	sts TCNT1L, r20

	;cargo la configuracion del timer 1, modo normal, sin prescaler
	ldi r20, 0x00
	sts TCCR1A, r20

	ldi r20, 1 << CS10
	sts TCCR1B, r20

	ret	

; resetea el timer 1 (16bit)
reset_timer:
	;timer
	;cargo valor inicial del timer en 1 (parte alta y baja)
	ldi r20, 0x00
	sts TCNT1H, r20
	sts TCNT1L, r20

	ret

; prende y apaga el laser segun el valor actual del laser. No hace falta ret, pues viene de un jmp
dibujar:

	/*
	t = tiempo que tarda en dar una vuelta		0 <= t <= 2^16				2 byte
	t_prox_cambio = delta													2 byte			r23:r24

	delta = t / 8 / 128							0 <= delta <= 2^6			1 byte			r20
												;dividimos por 8 lados y 128 pixeles por lado
	fila = 0									0 <= fila <= 2^3 - 1		1 byte			r21
	columna = 0									0 <= columna <= 2^7 - 1		1 byte			r22

	while(fila < 2^3 && columna < 2^7)

		dibujar_pixel(fila, columna) ; falta ver como skippear las primeras columnas y las ultimas por las dudas

		if (timer_actual > t_prox_cambio)
			columna++
			t_prox_cambio += delta

			if (columna == 2^7)
				fila++
				columna = 0

	*/

	;lds r20, ultima_duracion_vuelta_l innecesario
	lds r20, ultima_duracion_vuelta_h

	; shift a la derecha 2 veces
	lsr r20
	lsr r20

	; numero de fila
	ldi r21, 0;
	; numero de columna
	ldi r22, 0;

	; t_prox_cambio = delta
	ldi r23, 0; alta
	mov r24, r20; baja

	loop_dibujar:
		sbrc r21, 2	; salteo si el bit 2 de la fila esta seteado
		jmp dibujar_end

		; dibujar el pixel TODO, pasarle la fila y la columna
		; laser prueba
		; deberia prender una fila y otra no
		out PORTB, r22

		; obtengo el valor actual del timer
		lds r17, TCNT1L
		lds r16, TCNT1H

		cp r16, r23
		brmi loop_dibujar ; si r16 - r23 < 0 => la parte alta de timer_actual es menor
		brne mayor; si no es cero entonces ya puedo ver el contenido del if
		cp r17, r24; caso en que las partes altas son iguales
		brmi loop_dibujar; miro las partes bajas y las comparo

		mayor:
			inc r22; columna++

			;t_prox_cambio += delta
			add r24, r20; sumo partes bajas
			ldi r25, 0
			adc r23, r25; le sumo a la parte alta el carry de la sumas de la partes bajas

			cpi r22, 128
			brne loop_dibujar
			; si columna == 2^7 == 128
			inc r21; fila++
			ldi r22, 0; columna = 0

		jmp loop_dibujar

	; bucle por las dudas
	dibujar_end:
		jmp dibujar_end

;---------- definicion de interrupciones ----------
sensor:
	; obtengo el valor actual del timer
	lds r20, TCNT1L
	lds r21, TCNT1H

	; actualizo el ultimo valor de la vuelta
	sts ultima_duracion_vuelta_l, r20
	sts ultima_duracion_vuelta_h, r21

	; reseteo el timer
	call reset_timer
	
	sei

	jmp dibujar
	; reti ausente, acordarse de habilitar las interrupciones
