;		; ======================================================================
		;								 Leitura de um botão				   	|
		; MCU: PIC16F628A	Clock: 4Mz											|
		; ======================================================================
		
		list p=p16f628a
		
		#include <p16f628a.inc>			; endereços de memória
		
		;============================= FUSE BITS CONFIG =============================
		__config _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CP_OFF & _CPD_OFF
		
		; ============================= Memory bank selection ======================
		#define		bank0	bcf		STATUS,RP0
		#define		bank1	bsf		STATUS,RP0
		
		; ============================= Hardware Mapping ===========================
		#define 	output 			PORTB,RB1
		#define 	input 			PORTB.RB0
		
		; ============================= General Purpose Registers  =================
			cblock		H'20'
				W_TEMP			
				STATUS_TEMP
				
				bounce_count
				control_loop
				
				first_button
				last_button
			endc			
		; ============================= Reset Vector =============================
			org			H'0000'
			goto start
		
		; ============================= Interrupt Vector =========================
			org 		H'0004'
			
			; -------------- Context Saving ----------------
			movwf		W_TEMP							  	
			swapf 		STATUS,w							
			
			bank0											
			movwf 		STATUS_TEMP							
		
		external_interrupt:	
			; --------------  Interrupt Flag test ----------
			btfss		INTCON,INTF							
			goto 		exit_isr							
			
			bcf 		INTCON,INTF							
			
			; -------------- Button Trigger Test -----------
			movf 		PORTB,w								
			movwf		first_button 						
			
			call 		debouncing							
															
			
			movf 		PORTB,w 							
			xorwf		first_button, last_button			
															
			
			btfss		last_button,0						
															
															
		
			comf 		output								
			
			goto 		exit_isr							
			
			; -------------- context recovery ----------------
		exit_isr:
		
			swapf 		STATUS_TEMP,w				
		
			movwf 		STATUS 						
		
			swapf 		W_TEMP,f 					
			swapf 		W_TEMP,w  					
													
			
			retfie									
		
		
		; ============================= Init Registers ===========================
		start:
			bank1									
			
			movlw		H'FD'						
			movwf		TRISB						
			
			bsf 		OPTION_REG,6				
													
			
			bank0									
			
			movlw 		H'90'						
			movwf		INTCON						
			
			movlw 	H'07'							
			movwf 	CMCON							
													
			
			bcf			output						
		
		; ============================= Função Main ============================= 
		main:		
			goto main
			
			
		; ============================= Debouncing de 100 ms =====================
		debouncing:
		
			movlw 		H'64'					; 100d
			movwf 		control_loop			
			
		aux1:
		
			movlw 		H'FA'			
			movwf		bounce_count			
			
		aux2:
			nop									
			
			decfsz		bounce_count			
			goto		aux2					
			
			decfsz 		control_loop			
			goto 		aux1					
			
			return								
			
			end									