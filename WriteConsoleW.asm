; invoke Win32's WriteConsoleW()

option casemap:none

.DATA
	
	STD_OUTPUT_HANDLE 	dword 	-11								; the macro STD_OUTPUT_HANDLE expands to ((DWORD) -11)
	UNICODE_STRING 		word 	L"Hello there! Anoban!\n", 0	; a unicode buffer.
	STDOUT_HANLDE		qword	?								; handle to standard output
	
.CODE
	
	externdef WriteConsoleW:proc
	
	main proc
		sub rsp, 56
	main endp
	
end