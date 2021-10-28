[org 0x7c00]

	jmp main
	
printChar:			;takes a character in al
	pusha
	mov ah, 0x0e
	int 0x10
	popa
	ret

	
printString:			;Takes in a pointer in bx
	pusha
pStrLoop:	
	mov al, [bx]
	cmp al, 0
	je pStrEnd
	call printChar
	inc bx
	jmp pStrLoop
pStrEnd:
	popa
	ret


convertHex:			;takes in bx pointer with hex address and cx pointer with string address
	pusha
	mov al, [bx]
	shr al, 0x4
	cmp al, 0x9
	jle convertNum1
convertAlpha1:	
	add al, 0x57		;converts it to a lowercase char
	jmp printCont1
convertNum1:
	add al, 0x30
printCont1:
	push bx
	mov bx, cx
	mov [bx], al		;save converted hex into string
	pop bx
	
	inc cx			;increment string pointer
	
	mov al, [bx] 		;now we do the other piece of the byte
	and al, 0xf

	cmp al, 0x9
	jle convertNum2
convertAlpha2:	
	add al, 0x57		;converts it to a lowercase char
	jmp printCont2
convertNum2:
	add al, 0x30
printCont2:
	push bx
	mov bx, cx
	mov [bx], al 		;save the last hex char
	pop bx
	popa
	ret


	

printBytes:			;Takes in a pointer in bx pointing to hex
	pusha
byteString:
	db '0x0000', 0		;get ourself a byte string to manipulate
	
	mov cx, byteString+2		;set up pointer for cx pointing at string to print from

	;; DEBUG PORTION
	mov al, [bx]
	call printChar
	mov al, [bx+1]
	call printChar
	ret
	;; DEBUG PORTION
	
	call convertHex
	inc bx
	add cx, 2


	call convertHex

	sub cx, 4
	mov bx, cx
	call printString
	popa
	ret

readNextSector:
	pusha
	mov ax, 0		;set ax later but this is to set es
	mov es, ax		;early before the other registers are set
	
	mov ah, 0x02		;set ah to read from boot sector
	mov al, 1
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, [diskNum]	;drivenumber

	mov bx, 0x7e00		;specifies the location 0x7e00 which is where the code will be loaded es*16+bx=start location so this is 0*16_0x7e00

	int 0x13		;do the read interrupt
	popa
	ret


string2:
	db 'LM', 0

diskNum:	
	db 0			;makes some room for our drive number
	
main:
	mov [diskNum], dl		;save our drive number
	call readNextSector		;please read our next sector which should be all a

	mov bx, string2
	call printBytes

	jmp $

	times 510-($-$$) db 0
	db 0x55, 0xaa
	times 512 db 'Z'
