;*----------------------------------------------------------------------------
;* Name:    Lab_2_program.s
;* Purpose: Template code for using subroutines to implement Morse code 
;* Author: 	Rasoul Keshavarzi 
;*----------------------------------------------------------------------------*/

				THUMB 						; Declare THUMB instruction set 
                AREA 		My_code, CODE, READONLY 
                EXPORT 		__MAIN 			; Label __MAIN is used externally q
				ENTRY 
__MAIN
; The following lines are similar to Lab-1.  
; They just turn off all LEDs 
				MOV 		R2, #0xC000
				MOV 		R3, #0xB0000000	; Turn off three LEDs on port 1  
				MOV 		R4, #0x0
				MOVT 		R4, #0x2009
				ADD 		R4, R4, R2 		; 0x2009C000 
				STR 		R3, [R4, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R4, #0x40] ; Turn off five LEDs on port 2 
				
				MOV			R1, #0x0		; R1 is the OFFSET and counter of the 5 characters
MAIN_LOOP		CMP			R1, #5			; Check R1 to discover if the 5 characters were processed
				BEQ			DOTS_AND_R1		; insert 4 dots LED OFF and do R1=0 to restart the program
RESTART_PROGRAM	LDR 		R0, =InputChar	; getting the address InputChar (address of my input/"MARIN"
				LDRB 		R2, [R0, R1]	; Reading a character of the InputChar. R1 is the OFFSET
				SUB			R2, R2, #0x41	; Finding the OFFSET (to discover the position of the character in the MORSE table)
				LSL			R2, R2, #1		; Multiply R2 by 2 to find the correct OFFSET (1/2 word)
				LDR			R3, =Morse_LUT  ; getting the address Morse_LUT
				LDRH		R0, [R3, R2]	; Placing the Morse pattern into R0
				BL			CHAR2MORSE		; Go to the routine that turns the LED ON and OFF according to the Morse code
				ADD			R1, R1, #1		; Fixing the OFFSET and counter
				; insert 3 dots of LED OFF
				B 		MAIN_LOOP

DOTS_AND_R1		BL			LED_OFF
				MOV			R11, #4 ; adding 4 dots of led off to my delay
				BL			DELAY
				MOV			R1, #0x0 ; initial value of R1 to set the OFFSET correctly
				B			RESTART_PROGRAM

LED_ON 		   	
				STMFD 		R13!, {R0, R1, R7, R8, R14}	; I'm saving all registers and the link register
				LDR			R0, =LED_ADR		; loading the address of the port/LED
				MOV    		R1, #0xA0000000  	; moving the value to turn the LED off into R1
				STR     	R1, [R0]  			; Turns off the LED
				LDMFD 		R13!, {R0, R1, R7, R8, R15}

LED_OFF 		   	 		   	
				STMFD 		R13!, {R0, R1, R7, R8, R14}	; I'm saving all registers and the link register
				LDR			R0, =LED_ADR		; loading the address of the port/LED
				MOV    		R1, #0xB0000000  	; moving the value to turn the LED off into R1
				STR     	R1, [R0]  			; Turns off the LED
				LDMFD 		R13!, {R0, R1, R7, R8, R15}

DELAY			STMFD 		R13!, {R1, R11, R14}	; I'm saving all registers and the link register
				MOV    		R1, #0xFA20  		; Setting the counter
				MOVT		R1, #0x000F			; Setting the counter
				MUL 		R1, R1, R11			; R11 is how many delays I wanna do (use it with R11 = 1, 3, 4)
Loop1			SUBS		R1, R1, #1			; Decrement counter
				BGT			Loop1
				LDMFD 		R13!, {R1, R11, R15}

CHAR2MORSE		STMFD 		R13!, {R0-R11, R14}	; I'm saving all registers and the link register
				MOV			R1, #0xF		; R1 is a counter
				;I have to remove the zeros before the first 1, so:
				MOV			R10, #0x0		; Cleaning the register. It will be used to save the number of LSL I will do.
				MOV			R5, #0x00		
				MOV			R11, #0x1 		; setting the parameter of my DELAY
GO_BACK			ANDS		R5, R0, #0x8000 ; to analyze the bit 15 (half word)
				BNE			SKIP			; if the MSbit is 1, we can skip one part of the code
				LSL			R0, R0, #1
				SUB			R1, R1, #1
				ADD			R10, R10, #1	; The number I did LSL. I will use this number to do the correct number of LSL to check the R1'th bit
				B			GO_BACK
SKIP			MOV 		R7, #0x0		; Cleanning the Flag
LOOP_BIT		ADDS		R1, R1, #0x0	; Setting setting the flags to discover if the counter is smaller than 0
				BLT			ADD_3_DOTS
				MOV			R9, #0x1		; Forming the value to check the R1'th bit
				LSL			R9, R9, R10		; Forming the value to check the R1'th bit
				LSL			R9, R9, R1		; Forming the value to check the R1'th bit
				ANDS		R8, R0, R9		; Check the R1'th bit. R0 has the morse code. 
				BEQ			BIT_ZERO		; R1'th bit is zero => LED should be/get OFF
				BL			LED_ON			; Turn LED ON if R1'th bit is 1
				MOV			R7, #0x01		; Setting Flag to say that the LED is ON
RETURN			BL			DELAY
SKIP_ON			SUB			R1, R1, #1		; Decrement the counter
				B			LOOP_BIT		; Go back to analyze the other bits
BIT_ZERO		ADDS		R7, R7, #0		; Fixing flags to discover the value of R7
				BEQ			SKIP_ON			; Flag=0 => LED is OFF. Skip steps when LED is ON
				BL			LED_OFF
				B			RETURN
				
ADD_3_DOTS		BL			LED_OFF
				MOV			R11, #3 ; adding 3 dots of led off to my delay
				BL			DELAY
				B			EXIT_SUBR
				
EXIT_SUBR		LDMFD 		R13!, {R0-R11, R15}	; returning saved values
				
				ALIGN		
InputChar
				DCB 	"MARIN", 0					; The word to be sent to LED using Morse
				
				ALIGN
Morse_LUT 
				DCW 	0x17, 0x1D5, 0x75D, 0x75 	; A, B, C, D 
				DCW 	0x1, 0x15D, 0x1DD, 0x55 	; E, F, G, H 
				DCW 	0x5, 0x1777, 0x1D7, 0x175 	; I, J, K, L 
				DCW 	0x77, 0x1D, 0x777, 0x5DD 	; M, N, O, P 
				DCW 	0x1DD7, 0x5D, 0x15, 0x7 	; Q, R, S, T 
				DCW 	0x57, 0x157, 0x177, 0x757 	; U, V, W, X 
				DCW 	0x1D77, 0x775 				; Y, Z 
				DCW 	0

				ALIGN 
LED_ADR			EQU 	0x2009C020 		; Address of the memory that controls the LED 

				END



