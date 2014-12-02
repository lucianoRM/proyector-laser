






//la cadena y las letras van en orden normal!
cadena:
	.dw 8					; len(text) --- max = 8176
	.dw letra_exclamacion	;0 padding para los offsets!
	.dw letra_espacio			;1 padding para los offsets!
	.dw letra_a					;2
	.dw letra_espacio
	.dw letra_b			;3
	.dw letra_espacio
	.dw letra_c					;4
	.dw letra_espacio
	/*.dw letra_d			;5
	.dw letra_espacio
	.dw letra_e					;6
	.dw letra_espacio
	.dw letra_f			;7
	.dw letra_espacio
	.dw letra_g					;8
	.dw letra_espacio
	.dw letra_h			;9
	.dw letra_espacio
	.dw letra_i					;10
	.dw letra_espacio
	.dw letra_j			;11
	.dw letra_espacio
	.dw letra_l			;12
	.dw letra_espacio
	.dw letra_m			;9
	.dw letra_espacio
	.dw letra_n					;10
	.dw letra_espacio
	.dw letra_o			;11
	.dw letra_espacio
	.dw letra_p			;12
	.dw letra_espacio
	.dw letra_q			;13
	.dw letra_espacio
	.dw letra_r		;14
	.dw letra_espacio
	.dw letra_s			;15
	.dw letra_espacio
	.dw letra_t			;15
	.dw letra_espacio
	.dw letra_u			;15
	.dw letra_espacio
	.dw letra_v			;15
	.dw letra_espacio
	.dw letra_x			;15
	.dw letra_espacio
	.dw letra_y			;15
	.dw letra_espacio
	.dw letra_z			;15
	.dw letra_espacio
	*/
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
letra_m:
	.db 0b11000011, 0b11100111, 0b11011011, 0b11011011, 0b11000011, 0b11000011, 0b11000011, 0b11000011
letra_n:
	.db 0b10000001, 0b11000001, 0b10100001, 0b10010001, 0b10001001, 0b10000101, 0b10000011, 0b10000001
letra_o:
	.db 0b11111111, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11111111
letra_p:
	.db 0b11111100, 0b10000010, 0b10000001, 0b10000010, 0b11111100, 0b10000000, 0b10000000, 0b10000000
letra_q:
	.db 0b01111000, 0b11000110, 0b11000110, 0b11000110, 0b11000110, 0b11000110, 0b01111110, 0b00000011
letra_r:
	.db 0b11111100, 0b10000010, 0b10000001, 0b10000010, 0b11111100, 0b11100000, 0b10001100, 0b10000011
letra_s:
	.db 0b11111111,	0b11000000, 0b11000000, 0b11111111, 0b11111111, 0b00000011, 0b00000011, 0b11111111
letra_t:
	.db 0b11111111, 0b11111111, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000
letra_u:
	.db 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b11000011, 0b01000010, 0b00111100
letra_v:
	.db 0b11000011, 0b11000011, 0b11000011, 0b01100110, 0b01100110, 0b01100110, 0b00111100, 0b00011000
letra_x:
	.db 0b11000011, 0b01100110, 0b00111100, 0b00011000, 0b00011000, 0b00111100, 0b01100110, 0b11000011
letra_y:
	.db 0b11000011, 0b01100110, 0b00111100, 0b00011000, 0b00011000, 0b00011000, 0b00011000, 0b00011000
letra_z:
	.db 0b11111111, 0b00000011, 0b00000110, 0b00001100, 0b01111110, 0b00110000, 0b01100000, 0b11111111
letra_exclamacion:
	.db 0b00111100, 0b00111100, 0b00000000, 0b00000000, 0b00111100, 0b00111100, 0b00111100, 0b00111100
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
preparar_dibujar:
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
	lpm r12, Z+				; r8 = count(letras)
	lpm r13, Z+

	mov r14, r12
	mov r15, r13
	lsl r14
	rol r15
	lsl r14
	rol r15
	lsl r14
	rol r15

	clr r0
	ldi r24, 128			; 128 - 95 = 33
	add r14, r24
	adc r15, r0

	mov r10, r30
	mov r11, r31

	ret

rutina_dibujar:
	mov r30, r10
	mov r31, r11
	//Z = &(&letra_a_imprimir)

		//r28:r29 = columna
		mov r28, r22
		clr r29
		
		//r28:r29 = columna + offsetColumna
		add r28, r25
		adc r29, r26

		mov r24, r28
		
		//divido por 8 pixeles que tiene cada letra
		//r28:r29 = (columna + offsetColumna) / 8 = offsetLetra
		lsr r29
		ror r28
		lsr r29
		ror r28
		lsr r29
		ror r28

		//cant_letras < 32 => offsetColumna < 256 y columna < 128 => (offsetColumna+columna)/8 < 48
		//puedo usar solo la parte baja = r28
		
		//if offsetLetra >= cant_letras => offsetLetra -= cant_letras
		cp r29, r13
		brmi noOverflowOffset
		brne overflowOffset
		cp r28, r12
		brmi noOverflowOffset
		overflowOffset:
		sub r28, r12
		sbc r29, r13
		
		noOverflowOffset:

		//r28 = offsetLetraEnWords = offsetLetra * 2
		lsl r28
		rol r29

		//Z += offsetLetraEnWords
		add r30, r28
		adc r31, r29

	//r28:r29 = &letra_a_imprimir
		lpm r28, Z+				; r28 <- LOW(&letra_a_imprimir)
		lpm r29, Z+				; r29 <- HIGH(&letra_a_imprimir)
		;direccionamiento a word => direccionamiento a byte
		lsl r28
		rol r29

	//Z = &letra_a_imprimir
	mov r30,r28
	mov r31,r29

	//Z = &fila_letra_a_imprimir = &letra_a_imprimir + fila
	clr r0
	add r30,r21
	adc r31,r0

	//r27 = fila_letra_a_imprimir
	lpm r27, Z

	//bit = r27[columna mod 8 + offsetColumna mod 8]
	ldi r31, 0b00000111
	/*mov r24, r22
	and r24, r31
	mov r28, r25
	and r28, r31
	add r24, r28*/

	and r24, r31

	cpi r24, 8
	brmi noMod2
	subi r24, 8
	noMod2:
	loop:	tst r24
			breq obtener_bit
			dec r24
			lsl r27
			jmp loop
	obtener_bit:
			clr r0
			sbrc r27, 7
			inc r0
	jmp vuelta