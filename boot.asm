[BITS 16]    ; 16 bits archtecture system
[ORG 0x7C00] ; organize in 0x7C00 (MBR: MASTER BOOT RECORD) the bios find our code here 


;first hello world's method
call hello_world
call jump_line   

; second hello world's method
call create_string_pointer
call print_string
call jump_line

; three hello_world's method
call create_buffer_pointer
; get user input 
call read_string
; print user input 
call create_echolog_string_pointer
call print_string
call create_stringbuf_pointer
call print_string

jmp $              		; jmp $ to lock program and not execute rotines below

hello_world:
	mov AH, 0eh         ; 0eh is the bio function to print chars
						; bios functions stay in AH register
	mov AL, 48h			; character to print stay in AL register
						; 48h is "H" in ASCII
						; AH (8 BITS) + AL (8 BITS) = AX (16 BITS)
			
	int 10h				; video's interruption
	
	mov AL, 65h			; e
	int 10h
	mov AL, 6Ch			; l
	int 10h
	mov AL, 6Ch			; l
	int 10h
	mov AL, 6Fh			; o
	int 10h
	mov AL, 20h			; ' '
	int 10h
	mov AL, 74h			; t
	int 10h
	mov AL, 68h			; h
	int 10h
	mov AL, 69h			; i
	int 10h
	mov AL, 61h			; a
	int 10h
	mov AL, 67h			; g
	int 10h
	mov AL, 51h			; O
	int 10h
	mov AL, 53h			; S
	int 10h
	ret

jump_line: 				; like \n
		mov AH, 0Eh
		mov AL, 0Ah     ; \n new line character
		int 10h
		mov AL, 0Dh		; carry character (go to init of line; first column)
		int 10h
		ret

create_string_pointer:
	mov SI, hello		; SI is origin register, that saves a reference to hello
	; SI = Source Index
	ret
	
create_buffer_pointer:
	mov DI, buffer 		; DI is DESTINY register
	; DI = Destiny Index
	ret
	
create_echolog_string_pointer:
	mov SI, echo_log
	ret
	
create_stringbuf_pointer: 
	mov SI, buffer 
	ret
	

print_string:
	mov AH, 0eh
	mov AL, [SI]       ; [] gets first character. in this case, the 'w'
	print_character:   ; subroutine
		int 10h
		inc SI		   ; increments +1 to reference
		mov AL, [SI]
		cmp AL, 0 	   ; 0 is in the end of string. cmp to compare
		jne print_character   ; jne is 'Jump if Not Equals'
	ret
	
delete_one_char_of_input: ; this routine replace character by space and add other backspace
	mov AH, 0eh
	mov AL, 20h
	int 10h
	mov AL, 08h
	int 10h
	jmp read_string
	ret

read_string:
	mov AH, 00h 	   ; 00h is bios function + ..
	int 16h			   ; .. 16h interruption = read user character
	;; whenever user type a character, it's save in AL register
	mov AH, 0eh
	int 10h 			; print the user's input
	mov [DI], AL 		; saves input in DI
	inc DI
	
	cmp AL, 08h		   ; compare backspace character
	je delete_one_char_of_input ; jump if equals
	
	cmp AL, 0dh			; compare the input with enter
	jne read_string     ; jump to read_string if is not equal
	
	call jump_line
	ret

hello db "welcome to thiagOS.", 0 	; string
echo_log db "your input: ", 0
;buffer db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; instead of, make this:
buffer times 0 db 0 ; buffer to save user input

times 510 - ($-$$) db 0 ; bootloader has to have 512 bytes
						; 510 bytes + signature
						; ($-$$) fill 510 times db 0
						; result: 510 bytes filled with 0
dw 0xAA55				; signature to, if not have an OS,
						; is not loaded. 
						; this signature that loads the OS to memory