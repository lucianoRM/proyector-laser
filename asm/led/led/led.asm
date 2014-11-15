/*
 * led.asm
 *
 *  Created: 09/09/2014 19:21:39
 *   Author: Carlos
 */ 


 .include "m328Pdef.inc"

 ldi r16, 0xff;
 //ldi r16, 0x0;

 out DDRC, r16;
 out PORTC, r16;
