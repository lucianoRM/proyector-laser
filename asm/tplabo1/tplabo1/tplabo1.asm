// usa r0, r1, r2, r3, r4, r5, r6, r9, r16, r17, r20, r21, r22, r23, r24

.include "m328Pdef.inc"

.equ PIN_LASER = 0;(PORTB0)
.equ PIN_MOTOR = 0;(PORTC0)

.org 0					;jump al programa principal
	jmp main
	
.org INT0addr			;ubicacion de la external interrupt 0 (INT0 -> PORTD2)
	jmp sensor	;routina llamada por la interrupcion externa para el sensor hall

.include "tp_labo_letras.asm"

main:
	clr r25
	clr r26
	sbi DDRC, 1	;configuro como salida el led rojo
	sbi DDRC, 2	;configuro como salida el led verde

	;inicializacion stack
	ldi r20, high(RAMEND)
	out SPH, r20
	ldi r20, low(RAMEND)
	out SPL, r20

	call preparar_dibujar
	call esperar_clock
	call configurar_laser
	call configurar_timer
	call configurar_interrupcion
	call iniciar_fan

	;bucle principal, aca se ejecutan las interrupciones
	main_loop:
		sbi PORTC, 2
		jmp main_loop;

;---------- definicion de rutinas ----------
esperar_clock:
	clr r1
	clr r2
	clr r16

	loop_esperar_fan:
		inc r1
		brne loop_esperar_fan
		inc r2
		brne loop_esperar_fan
		inc r16
		cpi r16, 3
		brne loop_esperar_fan

	; pongo el clock en 8MHz
	ldi r16, 0b10000000
	sts CLKPR, r16
	clr r16
	sts CLKPR, r16

	ret

;configura como salida y activa el motor
iniciar_fan:

	sbi DDRC, PIN_MOTOR; configuro como salida el bit del motor
	sbi PORTC, PIN_MOTOR; prendo el motor

	;habilito las interrupciones globalmente
	sei

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

	ret

; configura y resetea el timer
configurar_timer:
	;timer
	;cargo valor inicial del timer en 1 (parte alta y baja)
	call reset_timer

	;cargo la configuracion del timer 1, modo normal, prescaler = 1
	clr r20
	sts TCCR1A, r20

	ldi r20, 1 << CS10; 
	sts TCCR1B, r20

	ldi r30,0 ; CONTADOR DE FILA
	ldi r29,0 ;

	ret	

; resetea el timer 1 (16bit)
reset_timer:
	;timer
	;cargo valor inicial del timer en 1 (parte alta y baja)
	clr r0
	sts TCNT1H, r0
	sts TCNT1L, r0

	ret

; prende y apaga el laser segun el valor actual del laser.
; en r21 debe estar el nro de fila
; en r22 debe estar el nro de columna
; en r3:r4 debe estar el tiempo en el cual se debe pasar a la prox columna
dibujar_lado:

	ldi r22, 127

	// acomodo los offsets de acuerdo a la columna que trato, se toca viendo las filas en la imagen
	cpi r21, 0
	breq offset_fila_0
	cpi r21, 1
	breq offset_fila_1
	cpi r21, 2
	breq offset_fila_2
	cpi r21, 3
	breq offset_fila_3
	cpi r21, 4
	breq offset_fila_4
	cpi r21, 5
	breq offset_fila_5
	cpi r21, 6
	breq offset_fila_6
	cpi r21, 7
	breq offset_fila_7

	// valores elegidos para los offsets, depende de la posición del espejo/imanes
	offset_fila_0:
		ldi r16, 2
		jmp set_offset
	offset_fila_1:
		ldi r16, 6
		jmp set_offset
	offset_fila_2:
		ldi r16, 6
		jmp set_offset
	offset_fila_3:
		ldi r16, 4
		jmp set_offset
	offset_fila_4:
		ldi r16, 0
		jmp set_offset
	offset_fila_5:
		ldi r16, 0
		jmp set_offset
	offset_fila_6:
		ldi r16, 2
		jmp set_offset
	offset_fila_7:
		ldi r16, 6
		jmp set_offset

	set_offset:
		sub r22, r16

dibujar_columna:
	cpi r22, 95
	brpl sacar0
	jmp rutina_dibujar
sacar0:
	clr r0
vuelta:
	out PORTB, r0 // r0

check_time:
	lds r18, TCNT1L
	lds r19, TCNT1H
	cp r19, r4				; HIGH(tActual) - HIGH(tPasarProxCol)
	brmi check_time			; HIGH(tActual) < HIGH(tPasarProxCol) => Vuelvo a chequear
	brpl proxima_columna	; HIGH(tActual) > HIGH(tPasarProxCol) => Prox columna
							
							; HIGH(tActual) == HIGH(tPasarProxCol)
	cp r18,r3				; LOW(tActual) - LOW(tPasarProxCol)
	brmi check_time			; LOW(tActual) < LOW(tPasarProxCol) => Vuelvo a chequear
	jmp proxima_columna		; LOW(tActual) >= LOW(tPasarProxCol) => Prox columna

proxima_columna:
	clr r0							; fijo nuevo límite de tiempo para la columna, sumando delta
	add r3, r6						; LOW(tPasarProxCol) += delta
	adc r4, r5						; HIGH(tPasarProxCol) += carry

	dec r22							; columna --
	cpi r22, 10
	brpl dibujar_columna			; columna >= 0 => dibujar

wait_for_interruption:
	cbi PORTB, 0					; dejo de pintar
	;jmp wait_for_interruption
	clr r9
	reti

;---------- definicion de interrupciones ----------
sensor:
	cbi PORTC, 2
	tst r9
	breq nohabiainterrupcion
	sbi PORTC, 1					; prendo el led rojo
	jmp finchequeointerrupcion
nohabiainterrupcion:
	cbi PORTC, 1					; apago el led rojo
finchequeointerrupcion:
	clr r9
	inc r9

	;solo actualizo el tiempo entre los espejos una vez por vuelta si fila = 5
	cpi r21, 5
	brne continuar_igual

	; si fila = 0, actualizo el valor del tiempo
	; obtengo el valor actual del timer y actualizo
	lds r1, TCNT1L
	lds r2, TCNT1H

	continuar_igual:

	; reseteo el timer
	clr r0
	sts TCNT1H, r0
	sts TCNT1L, r0
	
	//r3:r4 contiene todo el tiempo el momento en el cual tengo que empezar a dibujar la prox columna
	//r6:r5 contiene el tiempo a incrementar entre columnas

	//necesito dividir por 128 = 2^7, me queda un bit en la parte alta, el resto en la parte baja
	mov r5, r2
	mov r6, r1
	;aplico esto por 7 => OPTIMIZAR
	lsr r5
	ror r6
	lsr r5
	ror r6
	lsr r5
	ror r6
	lsr r5
	ror r6
	lsr r5
	ror r6
	lsr r5
	ror r6
	lsr r5
	ror r6

	; copio partes altas y bajas
	mov r4, r5
	mov r3, r6

	inc r21 ; incremento numero de fila

	cpi r21, 8
	brmi continue			; si fila < 8 => seguir
	
	clr r0
	inc r0
	clr r24
	add r25, r0
	adc r26, r24
	
	cp r26, r15
	brmi noLimpiarOffset
	brne limpiarOffset
	cp r25, r14
	brmi noLimpiarOffset
	limpiarOffset:
	ldi r25, 128
	clr r26
	noLimpiarOffset:
	clr r21					; si la fila == 8 => fila = 0
	
continue:

	;sei
	jmp dibujar_lado
	; reti ausente, acordarse de habilitar las interrupciones
