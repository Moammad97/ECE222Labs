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
START_AGAIN		MOV			R6, 0x00			; R6 will be my counter
INC				ADD			R6, R6, #1			; Incrementing the counter
				SUBS		R5, R6, #0xFF		; Checking if the counter achieved FF
				MOV			R4, R6				; Coping the value from R6 in R4. This way I don't lose the data of my counter. I will use R4 later to display my bits
				BEQ			START_AGAIN
;BUTTON_PRESSED	MOV			R8, #4
;NEXT_BYTE		MOV			R0, #0x00
				MOV			R0, #0x00
				MOV			R1, #8				; It will be used to check how many bits I passed to R0 (8 bits to send 1 byte)
TRANSFER_BYTE	LSRS		R4, R4, #1			; Transfering the least significant bit of R4... 
				RRX			R0, R0				; ...to the most significant position of R0
				SUBS		R1, R1, #1			; Checking how many bits I passed
				BGT			TRANSFER_BYTE
				BL			DISPLAY_NUM
				MOV			R2, #1000			; Putting 10000 into R2 to do the right 0.1mS delay
				BL			DELAY				; Calling the DELAY
				B			INC
				

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

				END 
				