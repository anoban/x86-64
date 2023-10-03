option casemap:none

.data
	num_0 	qword 111111111
	num_1 	qword 222222222
	fmtStr 	byte "Sum of %llu and %llu is %llu", 10, 0
		
.code 
	
	externdef ExitProcess: proc		; Win32
	externdef printf_s: proc		; C stdio
	
	main proc	; start
	
	sub rsp, 56
	lea rcx, fmtStr
	mov rdx, num_0
	mov r8, num_1
	mov r9, rdx
	add r9, r8
	call printf_s
	mov rcx, 0
	add rsp, 56
	call ExitProcess
	
	main endp
	
end