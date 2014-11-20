// usa r0, r1, r2, r3, r4, r5, r16, r17, r20, r21, r22, r23, r24

.include "m328Pdef.inc"

.equ PIN_LASER = 0;(PORTB0)
.equ PIN_MOTOR = 0;(PORTC0)

.org 0					;jump al programa principal
	jmp main
	
.org INT0addr			;ubicacion de la external interrupt 0 (INT0 -> PORTD2)
	jmp sensor	;routina llamada por la interrupcion externa para el sensor hall

.include "tp_labo_letras.asm"

main:
	clr r17				; limpio flag de primera sincronizacion
	sbi DDRC, 1	;configuro como salida el led rojo
	sbi DDRC, 2	;configuro como salida el led verde
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
		cpi r16, 40
		brne loop_esperar_fan
	sbi PORTC, 2
	ldi r16, 0b10000000
	sts CLKPR, r16
	clr r16
	sts CLKPR, r16
	ret


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

	;ldi r20, 1 << CS10
	ldi r20, 0b00000010
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

; prende y apaga el laser segun el valor actual del laser.
; en r21 debe estar el nro de fila
; en r22 debe estar el nro de columna
; en r3:r4 debe estar el tiempo en el cual se debe pasar a la prox columna
dibujar_lado:

	clr r22; Columnas

dibujar_columna:
	mov r23, r21		; Pasaje de parámetros
	mov r24, r22
	jmp rutina_dibujar
vuelta:
	out PORTB,r0

check_time:
	lds r1,TCNT1L
	lds r2,TCNT1H
	cp r2,r4				; HIGH(tActual) - HIGH(tPasarProxCol)
	brmi check_time			; HIGH(tActual) < HIGH(tPasarProxCol) => Vuelvo a chequear
	brpl proxima_columna	; HIGH(tActual) > HIGH(tPasarProxCol) => Prox columna
							
							; HIGH(tActual) == HIGH(tPasarProxCol)
	cp r1,r3				; LOW(tActual) - LOW(tPasarProxCol)
	brmi check_time			; LOW(tActual) < LOW(tPasarProxCol) => Vuelvo a chequear
	jmp proxima_columna		; LOW(tActual) >= LOW(tPasarProxCol) => Prox columna

proxima_columna:
	clr r0							; fijo nuevo límite de tiempo para la columna, sumando delta
	add r3, r5						; LOW(tPasarProxCol) += delta
	adc r4, r0						; HIGH(tPasarProxCol) += carry

	inc r22							; columna ++
	cpi r22, 128					
	brmi dibujar_columna			; columna < 128 => dibujar
									
									; si columna >= 128, tendrías que pasar a la siguiente fila, 
									; pero sólo si acabas de terminar con el primer espejo

	cpi r16, 1						; si es el segundo espejo del par el que acaba de terminar,
	breq wait_for_interruption		; esperá a la interrupción (hiciste muy rápido)

									; si es el primero
	inc r21							; fila ++
	clr r22							; columna = 0
	inc r16							; flag = 1
	jmp dibujar_columna				; dibujar

wait_for_interruption:
	cbi PORTB, 0					; dejo de pintar
	jmp wait_for_interruption

;---------- definicion de interrupciones ----------
sensor:

	; obtengo el valor actual del timer y actualizo
	lds r1, TCNT1L
	lds r2, TCNT1H

	; reseteo el timer
	call reset_timer
	
	//r3:r4 contiene todo el tiempo el momento en el cual tengo que empezar a dibujar la prox columna
	//se inicializa con r3=tiempo que tengo que estar pintando una columna
	//r5 contiene el tiempo a incrementar entre columnas
	clr r4 ; Parte alta de la suma de deltas de tiempo
	mov r3,r2 ; r3 se queda con el delta de tiempo entre columnas.Es la parte alta directamente porque es tiempo/256.
	mov r5, r3

	cpi r16, 1
	breq check_last_col
	inc r21					; corrige nro de fila si no llego a pintar el segundo espejo

check_last_col:
	clr r16					; limpio flag que indica si llego a pasar al segundo espejo
	inc r21					; incremento el nro de fila
	cpi r21, 8				
	brmi continue			; si fila < 8 => seguir
	clr r21					; si la fila == 8 => fila = 0
	
continue:
	
	cpi r17, 1
	breq continue2
	inc r17
	clr r21

	

continue2:
	sei
	jmp dibujar_lado
	; reti ausente, acordarse de habilitar las interrupciones