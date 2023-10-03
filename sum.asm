;	ml64.exe .\exitproc.asm /link /subsystem:console /entry:main kernel32.lib legacy_stdio_definitions.lib ucrt.lib

option casemap:none

.data

	fmt 	byte "Sum of %llu and %llu is %llu", 10, 0
	num0 	qword 123
	num1 	qword 234
	
.code
	; needs legacy_stdio_definitions.lib to be linked
	externdef printf_s:proc
	externdef exit:proc
	
	main proc
		sub rsp, 56	
		
		; summation part
		mov r9, num0
		add r9, num1
		; summation end
		
		lea rcx, fmt
		mov rdx, num0
		mov r8, num1
		; sum is alrady there in r9                                                                                          
		call printf_s
		add rsp, 56
		
		; exit with 0
		; without this the program will exit with a non 0 exit code! yikes!
		mov rcx, 0
		call exit
		ret
	main endp

end