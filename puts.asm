option casemap:none

.data
	_name sbyte "Anoban", 0	; null terminated char array in masm
	
.code 
	externdef puts:proc
	
	call_puts proc
	sub rsp, 56
	lea rcx, _name
	call puts		; call the C std puts()
	add rsp, 56
	ret
	call_puts endp
	
	main proc
	call call_puts
	ret
	main endp

end