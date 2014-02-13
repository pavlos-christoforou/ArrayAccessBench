format ELF64

section '.text' executable

 public main

 extrn malloc
 extrn free
 extrn clock

NUM_RECORDS = (50 * 1000 * 1000)
TRADE_SIZE = 8 + 8 + 8 +4 +4 +8 +1  ;; add seven to this to get structs equivalent in layout to C's
ARRAY_BYTES = NUM_RECORDS * TRADE_SIZE
NUM_RUNS = 5
B = 66 ; 1000010
S = 83 ; 1010011
INIT_BUY_COST = 0
INIT_SELL_COST = 0
CLOCKS_PER_SEC = 1000000
CLOCKS_PER_MSEC = CLOCKS_PER_SEC/1000

 main:
	mov	rdi, ARRAY_BYTES	;malloc the array in which to store the trades
	call	malloc
	mov	[ArrayStart], rax
	mov	r15, rax		;store &(trades[0]) in r15

	mov	r14, NUM_RUNS		;prepare the run counter

doRun:
	sub	r14, 1			;reduce run counter by one

	call	clock			;rax = current clock in ticks
	mov	r8, rax			;store clock in r8
	xor	rax,rax			;clear rax

	mov	r11, S			;store S in r11 for later use in cmov instruction
	xor	r12, r12		;clear r12
	mov	rcx, r15		;rcx = &(trades[0])
	add	rcx, ARRAY_BYTES	;rcx = &(trades[NUM_RECORDS])
	mov	rbx, NUM_RECORDS	;rbx = NUM_RECORDS

initTrades:
	sub	rcx, TRADE_SIZE		;rcx = &(trades[NUM_RECORDS - number of trades initialised])
	sub	rbx, 1			;rbx -= 1
	mov 	qword	[rcx], rbx 	;tradeId = rbx
	mov	qword	[rcx+8], 1 	;clientId = 1
	mov	dword	[rcx+16], 123 	;venueCode = 123
	mov	dword	[rcx+20], 321	;instrumentCode = 123
	mov	qword	[rcx+24], rbx	;price = rbx
	mov	qword	[rcx+32], rbx	;quantity = rbx
	mov	byte	r12b, B		;r12b = B
	and		rbx, 1		;if rbx is an even number, this will be zero
	cmovnz		r12, r11	;if it's not zero, move S into r12
	mov	byte	[rcx+40], r12b 	;side = r12
	cmp	rcx, r15		;if rcs != &(trades[0]), continue looping
	jne	initTrades

	mov 	r9,	INIT_BUY_COST	;buyCost = 0
	mov 	r10,	INIT_SELL_COST	;sellCost = 0

	xor	r12, r12		;clear r12 for later use
	mov	rcx, r15		;rcx = &(trades[0])
	add	rcx, ARRAY_BYTES	;rcx = &(trades[NUM_RECORDS])

countCosts:
	sub	rcx, TRADE_SIZE		;rcx = &(trades[NUM_RECORDS - number of trades counted])

	mov	qword	rax, [rcx+24] 	; store price in rax
	mul	qword	[rcx + 32] 	; multiply price by quantity, storing result in RDX
	mov	byte	r12b, [rcx+40] 	; store side in r12

	and	r12, 1			;if r12 is B, this is zero, else if it is S, this is one
	jnz	addToSellCost		;if (trade->Side == 'B') {
	add	r9, rdx			;buyCost += trade->Price * trade->Quantity;
	xor	rdx, rdx		;clear rdx

addToSellCost:				;else if (trade->Side == 'S') {
	add	r10, rdx	;sellCost += trade->Price * trade->Quantity;
	cmp	rcx, r15	;compare rcx to &(trades[NUM_RECORDS])
	jne	countCosts	;loop if countdown has not reached start of array

	mov	[rsp], r9	;save buyCost in stack 
	mov	[rsp+8], r10	;save sellCost in stack

	xor	rax,rax		;clear rax  
	call 	clock		;store current time in tics in rax
	sub	rax, r8		;rax = endTime - startTime; 
	xor	rdx, rdx	;clear rdx
	mov	rbx, CLOCKS_PER_MSEC 
	div	rbx 		;convert elased tick time into milliseconds, store result in RAX 	
	mov	[rsp+16],rax	;store elapsed time in stack

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printTime]
	mov	rdx, 15		;size of printTime
	syscall  		;print "elapsed time = "
	mov	rax, [rsp+16]
	call	PRINTDEC	;print elapsed time

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printNL]
	mov	rdx, 1		;size of printNL
	syscall			;print newline

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printRun]
	mov	rdx, 9		;size of printRun
	syscall  		;print "Runnum = "
	mov	rax, r14
	call	PRINTDEC	;print runNum

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printNL]
	mov	rdx, 1		;size of printNL
	syscall			;print newline

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printBuy]
	mov	rdx, 10		;size of printBuy
	syscall  		;print "buyCost = "
	mov	qword	 rax, [rsp] 	
	call	PRINTDEC	;print buyCost

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printNL]
	mov	rdx, 1		;size of printNL
	syscall 		;print newline

	mov	rax, 1
	mov 	rdi, 1
	lea	rsi, [printSell]
	mov	rdx, 11		;size of printSell
	syscall  		;print "sellCost = "
	mov	qword	rax, [rsp+8]	
	call	PRINTDEC	;print sellCost

	mov	rax, 1		
	mov 	rdi, 1
	lea	rsi, [printNL]
	mov	rdx, 1		;size of printNL
	syscall  		;print newline

	cmp	r14, 0
	jnz	doRun		;if runcounter's not zero, run again

	mov	rdi, r15
	call	free		;free trade array

quit:
	mov 	rax,60
 	mov	rdi,0
 	syscall			;quit, returning zero


PRINTDEC:		;Number printing routine from stack overflow; http://stackoverflow.com/questions/17862664/printing-a-number-in-x86-64-assembly
 LEA R9, [NUMBER + 22] ; last character of buffer
 MOV R10, R9         ; copy the last character address
 MOV RBX, 10         ; base10 divisor

 DIV_BY_10:

 XOR RDX, RDX          ; zero rdx for div
 DIV RBX            ; rax:rdx = rax / rbx
 ADD RDX, 0x30      ; convert binary digit to ascii
 TEST RAX,RAX          ; if rax == 0 exit DIV_BY_10
 JZ LAST_REMAINDER
 MOV byte [R9], DL       ; save remainder
 SUB R9, 1               ; decrement the buffer address
 JMP DIV_BY_10

 LAST_REMAINDER:

 TEST DL, DL       ; if DL (last remainder) != 0 add it to the buffer
 JZ CHECK_BUFFER
 MOV byte [R9], DL       ; save remainder
 SUB R9, 1               ; decrement the buffer address

 CHECK_BUFFER:

 CMP R9, R10       ; if the buffer has data print it
 JNE PRINT_BUFFER 
 MOV byte [R9], '0' ; place the default zero into the empty buffer
 SUB R9, 1

 PRINT_BUFFER:

 ADD R9, 1          ; address of last digit saved to buffer
 SUB R10, R9        ; end address minus start address
 ADD R10, 1         ; R10 = length of number
 MOV RAX, 1         ; NR_write
 MOV RDI, 1         ;     stdout
 MOV RSI, R9        ;     number buffer address
 MOV RDX, R10       ;     string length
 SYSCALL

 RET

;getTime:

;	call clock
;	mov rax
;clock_t start, end;
;double elapsed;

;start = clock();
;... /* Do the work. */
;end = clock();
;elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;



section '.data' writeable

display_name	db	"DISPLAY",0
printBuy 	db	"buyCost = "
printSell 	db	"sellCost = "
printRun 	db	"runNum = "
printTime 	db	"elapsed time = "
printNL		db	0x0A

section '.bbs' writeable

ArrayStart	rq	1
time		rq	2

LETTER		rb	1
NUMBER		rb	23
