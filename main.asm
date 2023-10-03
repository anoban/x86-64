; ml64.exe .\main.asm /link /subsystem:console /entry:main
; or
; ml64.exe .\main.asm /link /subsystem:console msvcrt.lib

	option casemap:none
	
.data
.code

	externdef getchar:proc
	main proc
		sub rsp, 56
		call getchar
		add rsp, 56
		ret
	main endp
end