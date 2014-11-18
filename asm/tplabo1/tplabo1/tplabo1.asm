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
	ldi r20, 0x00
	sts TCNT1H, r20
	sts TCNT1L, r20

	;cargo la configuracion del timer 1, modo normal, sin prescaler
	ldi r20, 0x00
	sts TCCR1A, r20

	ldi r20, 1 << CS10
	sts TCCR1B, r20

	ldi r30,0 ; CONTADOR DE FILA
	ldi r29,0 ;

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
	mov r20, r9

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
		/*sbrc r21, 3	; salteo si el bit 2 de la fila esta seteado
		jmp dibujar_end*/

		mov r1, r21					; pasaje de parametros
		mov r2, r22
		//jmp rutina_dibujar

		vuelta:

		; dibujar el pixel TODO, pasarle la fila y la columna
		; deberia prender una fila y otra no
		clr r0
		mov r31,r30
		lsr r31
		lsr r31
		lsr r31
		lsr r31
		
		

		cp r21, r31
		breq print1
print0:
		out PORTB, r0
		jmp esperar
print1:
		inc r0
		out PORTB, r0

esperar:
		; obtengo el valor actual del timer
		lds r17, TCNT1L
		lds r16, TCNT1H

		cp r23, r16
		brmi mayor
		brne esperar
		cp r24, r17
		brmi mayor
		jmp esperar
		
		
		/*cp r16, r23
		brmi loop_dibujar ; si r16 - r23 < 0 => la parte alta de timer_actual es menor
		brne mayor; si no es cero entonces ya puedo ver el contenido del if
		cp r17, r24; caso en que las partes altas son iguales
		brmi loop_dibujar; miro las partes bajas y las comparo*/

		mayor:
			inc r22; columna++

			;t_prox_cambio += delta
			ldi r25, 0
			add r24, r20; sumo partes bajas
			adc r23, r25; le sumo a la parte alta el carry de la sumas de la partes bajas

			cpi r22, 128
			brne loop_dibujar
			; si columna == 2^7 == 128
			inc r21; fila++
			inc r29;
			brne salto2;
			inc r30; CONTADOR++
		salto2:
			ldi r22, 0; columna = 0
			cpi r21, 8
			breq dibujar_end

		jmp loop_dibujar

	; bucle por las dudas
	dibujar_end:
		clr r0
		out PORTB, r0
		jmp dibujar_end

;---------- definicion de interrupciones ----------
sensor:
	; obtengo el valor actual del timer y actualizo
	lds r8, TCNT1L;innecesario
	lds r9, TCNT1H

	; reseteo el timer
	call reset_timer
	
	sei

	jmp dibujar
	; reti ausente, acordarse de habilitar las interrupciones
