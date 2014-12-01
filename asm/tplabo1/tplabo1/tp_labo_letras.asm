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
	/*
	.dw letra_a					;2
	.dw letra_espacio
	.dw letra_b			;3
	.dw letra_espacio
	.dw letra_c					;4
	.dw letra_espacio
	.dw letra_d			;5
	.dw letra_espacio
	.dw letra_e					;6
	.dw letra_espacio
	.dw letra_f			;7
	.dw letra_espacio
	.dw letra_g					;8
	.dw letra_espacio
	*/
	.dw letra_h			;9
	.dw letra_espacio
	.dw letra_i					;10
	.dw letra_espacio
	.dw letra_j			;11
	.dw letra_espacio
	.dw letra_l			;12
	.dw letra_espacio
	.dw letra_o			;13
	.dw letra_espacio
	.dw letra_s			;14
	.dw letra_espacio
	.dw letra_t			;15
	.dw letra_espacio
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
	.db 0b11111111,	0b11111111, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11111111, 0b11111111
letra_d:
	.db 0b11111100, 0b10000010, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b10000010, 0b11111100
letra_e:
	.db 0b11111111, 0b11111111, 0b10000000, 0b11111000, 0b11111000, 0b10000000, 0b11111111, 0b11111111
letra_f:
	.db 0b11111111, 0b11111111, 0b10000000, 0b11111000, 0b11111000, 0b10000000, 0b10000000, 0b10000000
letra_g:
	.db 0b11111111, 0b11111111, 0b10000000, 0b11111111, 0b11111111, 0b10000111, 0b11111111, 0b11111111
letra_h:
	.db 0b11000011, 0b11000011, 0b11000011, 0b11111111, 0b11111111, 0b11000011, 0b11000011, 0b11000011
letra_i:
	.db 0b11111111, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b11111111
letra_j:
	.db 0b00001110, 0b00001110, 0b00001110, 0b00001110, 0b00001110, 0b00001110, 0b00001110, 0b11111100
letra_l:
	.db 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11000000, 0b11111111, 0b11111111
letra_o:
	.db 0b11111111, 0b11111111, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11111111, 0b11111111
letra_s:
	.db 0b11111111,	0b11000000, 0b11000000, 0b11111111, 0b11111111, 0b00000011, 0b00000011, 0b11111111
letra_t:
	.db 0b11111111, 0b11111111, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000
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
	; Como se imprime de derecha a izquierda, cuando nos piden la columna 0 en realidad nos piden la 127
	; Y cuando nos piden la columna 127 en realidad nos piden la 0


	; Se shiftea uno hacia la izquierda para multiplicar por 2
	; El direccionamiento de las etiquetas es a Word, o sea a 2 bytes
	; En cambio, lpm utiliza direccionamiento a byte

	;Z = &cadena
	ldi ZH, high(cadena<<1)
	ldi ZL, low(cadena<<1)
	
	//r0 = count(letras)
	//Z = &(letras[0])
	lpm r8, Z+				; r8 = count(letras)
	
	lpm r0, Z+


	//TODO offsetColumna
	//Z += floor(offsetColumna / 8) + floor(columna / 8)
	//Z = &(&letra_a_imprimir)
		//r7 = 2*floor(columna/8) ;cada registro ocupa 2 bytes y cada letra tiene 8 pixeles de ancho
		mov r28, r24
		add r28, r25
		lsr r28
		lsr r28
		lsr r28
		lsl r28
		cpi r28, 32		; if r28 >= cant_letras * 2
		brmi noMod
		subi r28, 32	; r28 -= 32
		noMod:
		//Z += 2*floor(columna/8)
		clr r0
		add r30, r28
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
	mov r28, r25
	and r28, r31
	add r24, r28
	cpi r24, 8
	brmi noMod2
	subi r24, 8
	noMod2:
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