/*
 * tp_labo_letras.asm
 *
 *  Created: 14/11/2014 17:48:56
 *   Author: Carlos
 */ 

cadena:
	.db 8, 0x00				; len(text)
	.dw letra_a
	.dw letra_b
	.dw letra_a
	.dw letra_b
	.dw letra_a
	.dw letra_b
	.dw letra_a
	.dw letra_b
	clr r0
letra_espacio:
	.db 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
letra_a:
	.db 0b00011000, 0b00100100, 0b01000010, 0b01000010, 0b01111110, 0b01000010, 0b01000010, 0b01000010
letra_b:
	.db 0b01111100, 0b01000010, 0b01000010, 0b01111110, 0b01111110, 0b01000010, 0b01000010, 0b01111100
letra_c:
	.db 0b00111110, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b00111110

/*
function dibujar (fila, columna, offsetColumna) {
	
	dir(*letra) = primer_ptr + floor(offsetColumna / 8) + floor(columna / 8)
	byte_letra = dir(letra) + fila
	bit = byte_letra[columna mod 8 + offsetColumna mod 8]

}
*/

//r0 = bit on/off para el laser
//r1 = fila, r2 = columna, r3 = offsetColumna
//utiliza r0:r6 r28:r31
rutina_dibujar:
	; Se shiftea uno hacia la izquierda para multiplicar por 2
	; El direccionamiento de las etiquetas es a Word, o sea a 2 bytes
	; En cambio, lpm utiliza direccionamiento a byte

	;Z = &cadena
	ldi ZH, high(cadena<<1)
	ldi ZL, low(cadena<<1)
	
	//r0 = count(letras)
	//Z = &(letras[0])
	lpm r4, Z+				; r4 = count(letras)
	inc ZL					; padding

	//TODO offsetColumna
	//Z += floor(offsetColumna / 8) + floor(columna / 8)
	//Z = &(&letra_a_imprimir)
		//r5 = 2*floor(columna/8) ;cada registro ocupa 2 bytes y cada letra tiene 8 pixeles de ancho
		mov r5, r2
		lsr r5
		lsr r5
		//Z += 2*floor(columna/8)
		clr r0
		add r30, r5
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
	add r30,r1
	adc r31,r0

	//r6 = fila_letra_a_imprimir
	lpm r6, Z

	//TODO DIBUJAR POSTA
	//bit = r6[columna mod 8 + offsetColumna mod 8]
	ldi r31, 0b00000111
	and r2, r31
	loop:	tst r2
			breq obtener_bit
			dec r2
			lsl r6
			jmp loop
	obtener_bit:
			clr r0
			sbrc r6, 7
			inc r0
	//jmp vuelta