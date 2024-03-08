; extern void sum_f32_array_asm(
;     _Inout_updates_all_(size) float* const restrict z,
;     _In_reads_(size) const float* restrict const x,
;     _In_reads_(size) const float* restrict const y,
;     _In_ const size_t size
; );

.data 
	nfloatszmm equ 16	; a 512 bits wide zmm register can hold 16 32 bit floats.
	
.code
	sum_f32_array_asm proc
	
	xor rax, rax	; rax, initialized to 0, will be our loop counter.
					; xor => `are not equal to`, so passing the same operands will always result in 0 (false), because they will always be equal.
					; xor reg, reg is often used to clear registers. It can be an alternative to mov reg, 0
					; and is often viewed as faster than mov instructions.

sumloop:				; the label for the array sum loop.	
	
	cmp r9, nfloatszmm	; if/when the array size is less than 16, i.e if size < 16.
						; r9 will receive the size parameter.
	jb  residues		; jump to label `residues`, where we add the floats individually.
	
	vmovups zmm0, zmmword ptr [rdx + rax * 4]	; rdx will receive the address of x, the pointer is 512 bits wide, hence the x 4.
												; rax, our loop counter will serve as a 16 byte stride.
												
												; NOTE: 512 bits = 32 bits x 16, but we multiply by 4 instead of 16.
												
	vmovups zmm1, zmmword ptr [r8 + rax * 4]	; r8 will receive the address of y.										
	vaddps  zmm2, zmm0, zmm1					; add zmm0 and zmm1 and store the result in zmm2.
	vmovups zmmword ptr [rcx + rax * 4], zmm2	; save the result to z, passed in rcx.
	add 	rax, nfloatszmm						; increment the loop counter.
	
	jmp sumloop									; loop over.
	
residues:	
	cmp rax, r9									; if the loop counter has reached the end of array. 
												; remember r9 is the regeister that received the size parameter.
	jae exit									; jump to label `exit`											

	; sum the remainders
	vmovss 	xmm0, real4 ptr [rdx + rax * 4]		; ss (single scalar) not ps (packed scalars)
	vmovss	xmm1, real4 ptr [r8 + rax * 4]
	vaddss	xmm2, xmm0, xmm1					; addition.
	vmovss	real4 ptr [rcx + rax * 4], xmm2		; store the sum.
	inc rax										; increment the loop counter by 1.
	
	jmp residues								; loop over.

exit:
	vzeroupper									; clear the upper bits of the zmm registers.
	ret
		
	sum_f32_array_asm endp
	end
	
; doesn't work :(	