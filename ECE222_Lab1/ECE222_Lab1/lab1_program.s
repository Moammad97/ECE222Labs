;----------------------------------------------------------------------------
; Name: Lab_1_program.s
; Purpose: This code flashes one LED at approximately 1 Hz frequency
; Author: Rasoul Keshavarzi
;----------------------------------------------------------------------------
	THUMB ; Declare THUMB instruction set
	AREA My_code, CODE, READONLY ;
	EXPORT __MAIN ; Label __MAIN is used externally q
	ENTRY
__MAIN
	; The following operations can be done in simpler methods. They are done in this
	; way to practice different memory addressing methods.
	; MOV #0xWXYZ writes the value 0xWXYZ into the lower word (16 bits) and clears the upper word
	; MOVT #0xPQRS writes the value 0xPQRS into the upper word
	MOV R6, #0x10000000 ;Move 0x10000000 into R6
	MOV R2, #0xC000 ; Move 0xC000 into R2
	MOV R4, #0x0 ; Initialize R4 register to 0 to build address
	MOVT R4, #0x2009 ; Assign 0x2009 to higher part of R4
	ADD R4, R4, R2 ; Add 0xC000 to R4 to get 0x2009C000
	MOV R3, #0x0000007C ; Move initial value for port P2 into R3
	STR R3, [R4, #0x40] ; Turns off five LEDs on port 2
	MOV R3, #0xB0000000 ; Move initial value for port P1 into R3
	STR R3, [R4, #0x20] ; Turns off three LEDs on Port 1
	MOV R2, #0x20 ; Put Port 1 offset into register R2
	MOV R0, #0xFFFF ; Initialize R0 for countdown
	LSL R0, R0, #3 ;Left shift to increase the counter and, consequently, make the led toggling slower
Loop2
Loop1
	SUBS R0, #1 ; Decrement R0 and set N,Z,V,C status bits
	BGT Loop1
	LDR	R5, [R4, #0x20] ;Load R5 with the address 0x2009C020 
	EOR	R5, R5, R6 ;XOR between R5 and R6 and put the result in R5. Toggling bit 28. R6 initialized in the first line ; I changed the   STR R3, [R4, R2]   by the following line
	STR R5, [R4, R2] ; Toggle the bit 28 or port 1
	MOV	R0, #0xFFFF ; Initialize R0 for countdown
	LSL R0, R0, #3 ;Left shift to increase the counter and, consequently, make the led toggling slower
	B Loop2 ; Keeps the LED flashing forever!
	END