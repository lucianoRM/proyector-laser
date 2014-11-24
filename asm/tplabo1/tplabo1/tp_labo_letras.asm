/*
 * tp_labo_letras.asm
 *
 *  Created: 14/11/2014 17:48:56
 *   Author: Carlos
 */ 

//la cadena y las letras van en orden normal!
cadena:
	.db 16, 0x00				; len(text)
	.dw letra_espacio			;0 padding para los offsets!
	.dw letra_espacio			;1 padding para los offsets!
	.dw letra_h					;2
	.dw letra_espacio			;3
	.dw letra_o					;4
	.dw letra_espacio			;5
	.dw letra_l					;6
	.dw letra_espacio			;7
	.dw letra_a					;8
	.dw letra_espacio			;9
	.dw letra_espacio			;10
	.dw letra_espacio			;11
	.dw letra_espacio			;12
	.dw letra_espacio			;13
	.dw letra_espacio			;14
	.dw letra_espacio			;15
	//clr r0
letra_impar:
	.db 0b00000000, 0b11111111, 0b00000000, 0b11111111, 0b00000000, 0b11111111, 0b00000000, 0b11111111
letra_par:
	.db 0b11111111, 0b00000000, 0b11111111, 0b00000000, 0b11111111, 0b00000000, 0b11111111, 0b00000000
letra_espacio:
	.db 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
letra_bloque:
	.db 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11111111
letra_a:
	.db 0b11111111, 0b11111111, 0b11000011, 0b11000011, 0b11111111, 0b11111111, 0b11000011, 0b11000011
letra_b:
	.db 0b11111111, 0b11000011, 0b11000011, 0b11111111, 0b11000011, 0b11000011, 0b11111111, 0b11111111
letra_c:
	.db 0b11111111, 0b11111111, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11111111, 0b11111111
letra_h:
	.db 0b11000011, 0b11000011, 0b11000011, 0b11111111, 0b11111111, 0b11000011, 0b11000011, 0b11000011
letra_o:
	.db 0b11111111, 0b11111111, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11111111, 0b11111111
letra_l:
	.db 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11111111, 0b11111111
letra_exclamacion:
	.db 0b00111100, 0b00111100, 0b00111100, 0b00111100, 0b00000000, 0b00000000, 0b00111100, 0b00111100
letra_punteada:
	.db 0b10101010, 0b10101010, 0b10101010, 0b10101010, 0b10101010, 0b10101010, 0b10101010, 0b10101010

/*
function dibujar (fila, columna, offsetColumna) {
	
	dir(*letra) = primer_ptr + floor(offsetColumna / 8) + floor(columna / 8)
	byte_letra = dir(letra) + fila
	bit = byte_letra[columna mod 8 + offsetColumna mod 8]

}
*/

//r0 = bit on/off para el laser
//r23 = fila, r24 = columna, r25 = offsetColumna
//utiliza r0, r8, r7, r23, r24, r25, r28, r29, r30, r31
rutina_dibujar:
	; Se shiftea uno hacia la izquierda para multiplicar por 2
	; El direccionamiento de las etiquetas es a Word, o sea a 2 bytes
	; En cambio, lpm utiliza direccionamiento a byte

	;Z = &cadena
	ldi ZH, high(cadena<<1)
	ldi ZL, low(cadena<<1)
	
	//r0 = count(letras)
	//Z = &(letras[0])
	lpm r8, Z+				; r8 = count(letras)
	lsl r8
	lsl r8
	lsl r8					; r8 = ancho en pixeles del texto
	
	lpm r0, Z+


	//TODO offsetColumna
	//Z += floor(offsetColumna / 8) + floor(columna / 8)
	//Z = &(&letra_a_imprimir)
		//r7 = 2*floor(columna/8) ;cada registro ocupa 2 bytes y cada letra tiene 8 pixeles de ancho
		mov r7, r24
		lsr r7
		lsr r7
		lsr r7
		lsl r7
		//r0 = 2*floor(offsetColumna / 8)
		mov r0, r25
		lsr r0
		lsr r0
		lsr r0
		lsl r0
		add r7, r0
		//if r7 > cant_pixeles => r7 -= cant_pixeles
		cp r7, r8
		brmi loadZ
		sub r7, r8
		//Z += 2*floor(columna/8) + 2*floor(offsetColumna/8)
loadZ:
		clr r0
		add r30, r7
		adc r31, r0

	//r28:r29 = &letra_a_imprimir
		lpm r28, Z+				; r28 <- LOW(&letra_a_imprimir)
		lpm r29, Z+				; r29 <- HIGH(&letra_a_imprimir)
		//r28:r29 = &letra_a_imprimir ;direccionamiento a word => direccionamiento a byte
		lsl r28
		lsl r29

	//Z = &letra_a_imprimir
	mov r30,r28
	mov r31,r29

	//Z = &fila_letra_a_imprimir = &letra_a_imprimir + fila
	clr r0
	add r30,r23
	adc r31,r0

	//r8 = fila_letra_a_imprimir
	lpm r8, Z

	//TODO offsetColumna
	//bit = r8[columna mod 8 + offsetColumna mod 8]
	ldi r31, 0b00000111
	and r24, r31
	mov r0, r25
	and r0, r31
	add r24, r0
	cp r24, r8
	brmi loop
	sub r24, r8
	loop:	tst r24
			breq obtener_bit
			dec r24
			lsl r8
			jmp loop
	obtener_bit:
			clr r0
			sbrc r8, 7
			inc r0
	jmp vuelta