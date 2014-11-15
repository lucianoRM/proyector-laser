/*
 * tp_labo_letras.asm
 *
 *  Created: 14/11/2014 17:48:56
 *   Author: Carlos
 */ 

cadena:
	.db 2, 0x00				; len(text)
	.dw letra_espacio
	.dw letra_a

letra_espacio:
	.db 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
letra_a:
	.db 0b00011000, 0b00100100, 0b01000010, 0b01000010, 0b01111110, 0b01000010, 0b01000010, 0b01000010
letra_b:
	.db 0b01111100, 0b01000010, 0b01000010, 0b01111110, 0b01111110, 0b01000010, 0b01000010, 0b01111100
letra_c:
	.db 0b00111110, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b01000000, 0b00111110

main:
	; Se shiftea uno hacia la izquierda para multiplicar por 2
	; El direccionamiento de las etiquetas es a Word, o sea a 2 bytes
	; En cambio, lpm utiliza direccionamiento a byte

	ldi ZH, high(cadena<<1)
	ldi ZL, low(cadena<<1)
	
	lpm r0, Z+				; len(text)
	inc ZL					; padding

	; for

		lpm r28, Z+				; r26 <- LOW(*letra_a)
		lpm r29, Z+				; r27 <- HIGH(*letra_a)

		mov r26, r30			; r26 <- LOW(dir_actual)
		mov r27, r31			; r27 <- HIGH(dir_actual)

		mov r30, r28			; LOW(Z) = LOW(*letra_a)
		mov r31, r29			; HIGH(Z) = HIGH(*letra_a)
		lsl r30					; LOW(*letra_a)<<1
		lsl r31					; HIGH(*letra_a)<<1

		; for row in letra
			lpm r1, Z				; r1 = letra_a[0]

		mov r30, r26
		mov r31, r27

	jmp main

/*

global lenCadena = INT;

function dibujar (fila, columna, offsetColumna) {
	
	dir(*letra) = primer_ptr + floor(offsetColumna / 8) + floor(columna / 8)
	byte_letra = dir(letra) + fila
	bit = byte_letra[columna mod 8 + offsetColumna mod 8]

}

*/