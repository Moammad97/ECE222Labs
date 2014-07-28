;*-------------------------------------------------------------------
;* Name:    	lab_4_program.s 
;* Purpose: 	A sample style for lab-4
;* Term:		Winter 2014
;*-------------------------------------------------------------------
	THUMB 							; Declare THUMB instruction set 
	AREA 	My_code, CODE, READONLY 
	EXPORT 	__MAIN 					; Label __MAIN is used externally 
	EXPORT 	EINT3_IRQHandler 		; The ISR will be known to the startup_LPC17xx.s program 

	ENTRY 

__MAIN
			LDR		R10, =ISER0
			LDR		R1, [R10]
			ORR		R1, R1, #0x200000		; Setting bit 21 of ISER0
			STR		R1, [R10]					; Storing the right value into ISER0 in order to enable EINT3
			MOV		R6, #0x1				; Using R6 as a flag. if the button wasn't pressed, R6=1. If the button is pressed, R6=0
			LDR		R10, =IO2IntEnf
			LDR		R1, [R10]
			ORR		R1, R1, #0x400
			STR		R1, [R10]
		; The following lines are similar to previous labs.
		; They just turn off all LEDs 
			LDR		R10, =LED_BASE_ADR		; R10 is a  pointer to the base address for the LEDs
			MOV 	R3, #0xB0000000			; Turn off three LEDs on port 1  
			STR 	R3, [r10, #0x20]
			MOV 	R3, #0x0000007C
			STR 	R3, [R10, #0x40] 		; Turn off five LEDs on port 2 
			
			MOV		R2, #0x9C4
			MOV		R3, #0x00000004
			STR		R3, [R10, #0x40]

		; This line is very important in your main program
		; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
			MOV		R11, #0xABCD			; Init the random number generator with a non-zero number
			BL 		RNG  
			MOV		R9, #2500
			UDIV	R11, R11, R9
LOOP1		BL		DELAY
		;FAZER UM LOAD EM R3
			LDR		R3, [R10, #0x20]		; Getting the value of port 1
			EOR		R3, R3, #0xB0000000		; Turning on/off port 1
			STR		R3, [R10, #0x20]
			LDR		R3, [R10, #0x40]		; Getting the value of port 2
			EOR		R3, R3, #0x0000007C		; Turning on/off port 2
			STR		R3, [R10, #40]
			SUBS	R11, R11, #1
			BNE		LOOP1
			MOV 	R3, #0xB0000000			; Turn off three LEDs on port 1  
			STR 	R3, [r10, #0x20]
			MOV 	R3, #0x0000007C
			STR 	R3, [R10, #0x40] 		; Turn off five LEDs on port 2
			MOV		R4, #0x00
			MOV		R5, #0x00
			MOV		R2, #1
LOOP2		BL		DELAY
			TST		R6, #0x1
			BEQ		STOP_COUNT
			ADD		R4, R4, #1
			ADD		R5, R5, #1
			TEQ		R5, #1000
			BNE		LOOP2
			MOV		R5, #0x00
			LDR		R3, [R10, #0x20]		; Getting the value of port 1
			EOR		R3, #0xB0000000
			STR		R3, [R10, #0x20]
			LDR		R3, [R10, #0x40]		; Getting the value of port 2
			EOR		R3, #0x0000007C
			STR		R3, [R10, #0x40]
			BL		LOOP2
STOP_COUNT	MOV		R8, #4				; This register will be used to check if I displayed all the 4 bytes
			MOV		R4, R7				; Coping the result of the counter into R4 to not lose its value (we cannot lose the value of R7)
NEXT_BYTE	MOV		R0, #0x00			; R0 will be used to send the bits to the function DISPLAY_NUM
			MOV		R1, #8				; R1 will be used to check how many bits is in the register that I will display (8 bits to pass 1 byte each time to the DISPLAY_NUM)
TRANSFER_B  LSRS	R4, R4, #1			; Get the least significant bit of R4... 
			RRX		R0, R0				; ...and put it in the most significant bit of R0 (this way I can send the least significant byte first)
			SUBS	R1, R1, #1			; Check how many bits I passed to R0
			BGT		TRANSFER_B
			BL		DISPLAY_NUM
			MOV		R2, #0x4E20			; Putting 10000 into R2 to do the right 0.1mS delay
			BL		DELAY
			SUBS	R8, R8, #1			; Checking how many bytes I passed to the DISPLAY_NUM
			BGT		NEXT_BYTE
			MOV		R2, #0xC350			; Putting 50000 into R2 to do the right 0.1mS delay
			BL		DELAY
			B 		STOP_COUNT

				
				
		;
		; Your main program can appear here 
		;
				
				
				
;*------------------------------------------------------------------- 
; Subroutine RNG ... Generates a pseudo-Random Number in R11 
;*------------------------------------------------------------------- 
; R11 holds a random number as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program
; R11 can be read anywhere in the code but must only be written to by this subroutine
RNG 			
	STMFD		R13!,{R1-R3, R14} 	; Random Number Generator 
	AND			R1, R11, #0x8000
	AND			R2, R11, #0x2000
	LSL			R2, #2
	EOR			R3, R1, R2
	AND			R1, R11, #0x1000
	LSL			R1, #3
	EOR			R3, R3, R1
	AND			R1, R11, #0x0400
	LSL			R1, #5
	EOR			R3, R3, R1			; The new bit to go into the LSB is present
	LSR			R3, #15
	LSL			R11, #1
	ORR			R11, R11, R3
	LDMFD		R13!,{R1-R3, R15}

;*------------------------------------------------------------------- 
; Subroutine DELAY ... Causes a delay of 1ms * Rn times
;*------------------------------------------------------------------- 
; 		aim for better than 10% accuracy	
DELAY			STMFD		R13!,{R2, R3, R14}
				MOV			R3, #0x83  ; decrement this value to have a delay of 0.1mS 
				MUL			R3, R3, R2 ; R2 sets the amount of delay I wanna do, since I know that R3 can generate a delay of 0.1mS
LOOP_D			SUBS		R3, R3, #1 ; decrement counter R3
				BNE			LOOP_D
				LDMFD		R13!,{R2, R3, R15}
	

;*------------------------------------------------------------------- 
; Interrupt Service Routine (ISR) for EINT3_IRQHandler 
;*------------------------------------------------------------------- 
; This ISR handles the interrupt triggered when the INT0 push-button is pressed 
; with the assumption that the interrupt activation is done in the main program
EINT3_IRQHandler 	PROC 
	;STMFD 		... 				; Use this command if you need it  
	;LDMFD 		... 				; Use this command if you used STMFD (otherwise use BX LR)
		MOV		R6, #0x00			; Cleaning the flag. if R6=0, the button was pressed.
		LDR		R10, =IO2IntEnf
		LDR		R1, [R10]
		EOR		R1, R1, #0x400
		STR		R1, [R10]
		BX		LR
		ENDP
	
	ALIGN 

;*------------------------------------------------------------------- 
; Routine to display the one byte trhough the LEDs 
;*------------------------------------------------------------------- 
; GUIDE: Display the number in R3 onto the 8 LEDs
; MARINA: Display the number in R4 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R0 - R12, R14}
; Usefull commaands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations
				MOV			R1, #0xFFFFFFFF		; It will be used to invert the bits  
				MOV			R5, #5				; It will be used to check the number of bits I passed to another register
				MOV			R6, #0x00			; It will be used to store the right value to turn on the required LEDS of port P1
				MOV			R7, #0x00			; It will be used to store the right value to turn on the required LEDS of port P2
				EOR			R0, R0, R1			; Inverting the bits: bits 0 turn into 1 and bits 1 turn into 0 (because the led turns on with 0, not with 1)
				RBIT		R0, R0				; Invert the order of the bits 
				LSRS		R0, R0, #1			; Putting the bits 5, 6, 7 into bits 28, 29, 31 to turn on the LEDS. (actually it's the bit 7 that was in R4. The bit 7 of R4 become the bit 32 in R0 and then bit 1 after the RBIT)
				RRX			R6, R6				; 
				LSRS		R0, R0, #1			;
				RRX			R6, R6				;
				LSR			R6, R6, #1			; Putting a 0 in the bit 30. It was necessary to set correctly the data to put in the LED address
				LSRS		R0, R0, #1			; Putting the bits 5, 6, 7 into bits 28, 29, 31 to turn on the LEDS
				RRX			R6, R6				; Now R6 has the right value to turn on LEDS P1.28, P1.29 and P1.31
AGAIN			LSRS		R0, R0, #1			; Putting the bits 4,3,2,1,0 into into R7 to turn on the LEDS P2.2, P2.3, P2.4, P2.5, P2.6  (Actually these bits had these position in the register R4. After the bit 0 become the bit 25 in R0 and then bit 7 after the RBIT)
				RRX			R7, R7
				SUBS		R5, R5, #1			; Checking how many bits I put in R7
				BGT			AGAIN
				LSR			R7, R7, #25			; Shifting 25 times. This way the bits that I moved to R7 can be in the right bit position (first bit that I moved will be in the bit 2). 
				STR 		R6, [R9, #0x20] 	; Turn off three LEDs on port 1  
				STR 		R7, [R9, #0x40] 	; Turn off five LEDs on port 2
				LDMFD		R13!,{R0 - R12, R15}

;*-------------------------------------------------------------------
; Below is a list of useful registers with their respective memory addresses.
;*------------------------------------------------------------------- 
LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002C00C 		; Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 		; Pin Select Register 4 for P2[15:0]
FIO1DIR			EQU		0x2009C020 		; Fast Input Output Direction Register for Port 1 
FIO2DIR			EQU		0x2009C040 		; Fast Input Output Direction Register for Port 2 
FIO1SET			EQU		0x2009C038 		; Fast Input Output Set Register for Port 1 
FIO2SET			EQU		0x2009C058 		; Fast Input Output Set Register for Port 2 
FIO1CLR			EQU		0x2009C03C 		; Fast Input Output Clear Register for Port 1 
FIO2CLR			EQU		0x2009C05C 		; Fast Input Output Clear Register for Port 2 
IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 

	ALIGN 
	END 
