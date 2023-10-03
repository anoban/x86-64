; a dummy programme

    .CODE				; start of code section
    
    option casemap:none	; use the identifiers as they are, w/o automatically making them upper case
    
    public asmproc		; make procedure accessible to others (akin to C's extern definitions)
    asmproc	PROC		; procedure start
		ret				; return the control to caller.
	asmproc ENDP		; procedure end
    
END		; programme end
    