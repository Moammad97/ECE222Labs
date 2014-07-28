                                                                                                                                         ; ECE-222 Lab ... Winter 2014 term 
; Lab 3 sample code 
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R9, =LED_BASE_ADR	; R9 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports
				MOV 		R3, #0xB0000000	
				STR 		R3, [R9, #0x20] 	; Turn off three LEDs on port 1  
				MOV 		R3, #0x0000007C
				STR 		R3, [R9, #0x40] 	; Turn off five LEDs on port 2 
				; This line initializes R10 to a 16-bit non-zero value. 
				MOV			R10, #0xABCD		; Seed for the random number generator 
				BL 			RandomNum			; Generate the random number
				MOV			R2, R10				; Coping the value from R10 to R2 to do the right amount of delays; I have to copy to R2 because I will use this register to set the amount of delays in other parts of the code
				BL			DELAY				; Calls DELAY to turn on the LED after that random amount of time
				MOV			R3, #0xA0000000		; Value to turn on LED P2.29
				STR			R3, [R9, #0x20]		; Turn on LED P2.29
				MOV			R7, #0x0000			; Cleaning R7 to use it as a counter. (It would be the time counter, will register how much time the person took to press the button)
				MOV			R2, #0x0001			; Putting 01 into R2 to do the right 0.1mS delay (each time I do the loop, I have to increment 0.1mS. So, R2(01) is the amount of times I have to do the DELAY)
				LDR			R5, =FIO2PIN1		; FIO2PIN1 = 0x2009 C055 Putting the memory location into R5 monitor the button	(I have to 
LOOP_INC		ADD			R7, R7, #1			; Increment the counter
				BL			DELAY				; Calls the DELAY subroutine
			; Monitor the status of INTO push button
				LDR			R6, [R5, #0x0]		; Coping the value of the status of the button to R6
				ANDS		R6, R6, #0x00000004	; Checking the bit 2 (bit 2 = P2.10)
				BNE			LOOP_INC			; Go back to the begin of the loop ; If the result is 0, the bit 2 is 0, so the button was pressed
loop			MOV			R8, #4				; This register will be used to check if I displayed all the 4 bytes
				MOV			R4, R7				; Coping the result of the counter into R4 to not lose its value (we cannot lose the value of R7)
NEXT_BYTE		MOV			R0, #0x00			; R0 will be used to send the bits to the function DISPLAY_NUM
				MOV			R1, #8				; R1 will be used to check how many bits is in the register that I will display (8 bits to pass 1 byte each time to the DISPLAY_NUM)
TRANSFER_BYTE	LSRS		R4, R4, #1			; Get the least significant bit of R4... 
				RRX			R0, R0				; ...and put it in the most significant bit of R0 (this way I can send the least significant byte first)
				SUBS		R1, R1, #1			; Check how many bits I passed to R0
				BGT			TRANSFER_BYTE
				BL			DISPLAY_NUM
				MOV			R2, #0x4E20			; Putting 10000 into R2 to do the right 0.1mS delay
				BL			DELAY
				SUBS		R8, R8, #1			; Checking how many bytes I passed to the DISPLAY_NUM
				BGT			NEXT_BYTE
				MOV			R2, #0xC350			; Putting 50000 into R2 to do the right 0.1mS delay
				BL			DELAY
				B loop

;
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

; R10 holds a random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R10 MUST be initialized to a non-zero 16-bit value at the start of the program
; R10 can be read anywhere in the code but must only be written to by this subroutine
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R10, #0x8000
				AND			R2, R10, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R10, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R10, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R10, #1
				ORR			R10, R10, R3
				
				LDMFD		R13!,{R1, R2, R3, R15}

;
;		Delay 0.1ms (100us) * R2 times
; 		aim for better than 10% accuracy
		; code to generate a delay of 0.1mS * R2 times
DELAY			STMFD		R13!,{R2, R3, R14}
				MOV			R3, #0x83  ; decrement this value to have a delay of 0.1mS 
				MUL			R3, R3, R2 ; R2 sets the amount of delay I wanna do, since I know that R3 can generate a delay of 0.1mS
LOOP1			SUBS		R3, R3, #1 ; decrement counter R3
				BNE			LOOP1
				LDMFD		R13!,{R2, R3, R15}
				
				ALIGN 

LED_BASE_ADR	EQU 	0x2009C000 		; Base address of the memory that controls the LEDs 
FIO2PIN1		EQU		0x2009C055		; FIO2PIN1 = 0x2009 C055
PINSEL3			EQU 	0x4002C00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 		; Address of Pin Select Register 4 for P2[15:0]
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
;	FIOPIN  - register to read and write pins
;	FIOSET  - register to set I/O pins to 1 by writing a 1
;	FIOCLR  - register to clr I/O pins to 0 by writing a 1


;1- If a 32-bit register is counting the number of 10’ths of milliseconds, 
;what is the maximum amount of time which can be encoded in 8 bits, 16-bits, 24-bits and 32-bits?
;The maximum amount of time encoded in 8 bits would be
;0.1mS * FF = 0.1mS * 255 = 25.5mS
;The maximum amount of time encoded in 16 bits would be
;0.1mS * FFFF = 0.1mS * 65535 = 6553.5mS = 6.5535S
;The maximum amount of time encoded in 24 bits would be
;0.1mS * FFFFFF = 0.1mS * 16777215 = 1677721.5mS = 1677.7215S
;The maximum amount of time encoded in 32 bits would be
;0.1mS * FFFFFFFF = 0.1mS * 4294967295 = 429496729.5mS = 429496.7295S

;2- Considering typical human reaction time, which size would be the best for this task (8, 16, 24, or 32 bits)?
; The best size would be 16 bits, since a typical human reaction is around some seconds (usually it's faster than 6.5 seconds)



				END 
				