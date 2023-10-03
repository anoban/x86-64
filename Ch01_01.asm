;   void static inline __stdcall sum_f32_array_avx512(
;      _Inout_ float* const restrict z, const _In_ float* restrict const x, const _In_ float* restrict const y, const _In_ size_t size
;  )

.data 
	nfloatszmm equ 16	; a 512 bits wide zmm register can hold 16 32 bit floats.
	
.code
	arraysum_avx512 proc
	
	xor rax, rax	; rax, initialized to 0, will be our loop counter.

sumloop:			; the label for the array sum loop.	
					; r9 will receive the size parameter, copy that value to r10.
					
	cmp r9, nfloatszmm	; if the array size is less than 16, i.e if size < 16
	jb  residues		; jump to label residues.
	
	vmovups zmm0, zmmword ptr [rdx + rax * 4]	; rdx will receive the address of x, the pointer is 512 bits wide, hence the x 4.
												; rax, our loop counter will serve as a 16 byte stride.
	vmovups zmm1, zmmword ptr [r8 + rax * 4]	; r8 will receive the address of y.										
	vaddps  zmm2, zmm0, zmm1					; add zmm0 and zmm1 and store the result in zmm2.
	vmovups zmmword ptr [rcx + rax * 4], zmm2	; save the result to z, passed in rcx.
	add 	rax, nfloatszmm						; increment the loop counter.
	jmp sumloop									; loop over.
	
residues:	


exit:
	vxeroupper									; clear the upper bits of the zmm registers.
	ret
		
	arraysum_avx512 endp
	end
	