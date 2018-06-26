
;; socket specific flags
AF_INET        equ 2
SOCK_STREAM    equ 1
INADDR_ANY	equ 0	; /usr/include/linux/in.h

;; syscalls
__NR_exit	equ 1
__NR_read       equ 3
__NR_write      equ 4
__NR_close	equ 6

;;see http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
;;also https://filippo.io/linux-syscall-table/
SYS_SOCKET      equ 41
SYS_BIND        equ 49
SYS_LISTEN      equ 50
SYS_ACCEPT      equ 43
SYS_READ        equ 0



        socket_args dd AF_INET, SOCK_STREAM, 0

section .data
        ;; HTTP response
        ;; https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html
	http_hello	db "HTTP/1.1 200 OK", 0xD, \
                        "Server: FB", 0xD,0xA, \
                        "Content-Length: 13", 0xD,0xA, \
                        "Connection: close",0xD,0xA, \
                        "Content-Type: text/html",0xD,0xA,0xD,0xA, \
                        "hello, world!",0xD,0xA

section .text
	global	_start


;; In 64 bits, parameters for Linux system call are passed using registers.
;; rax is for the syscall number.
;; rdi, rsi, rdx ... are used for passing parameters (in order).
;; -> see https://msdn.microsoft.com/en-us/library/9z1stfyw.aspx

_start:
	;; socket(AF_INET, SOCK_STREAM, 0)
        mov     rdi, AF_INET
        mov     rsi, SOCK_STREAM
	mov     rax, SYS_SOCKET     ;c.f. /usr/src/linux/net/socket.c
        syscall

        ;; 'bind' syscall.
	;; building the sockaddr_in struct, by pushing its
        ;; values on the top of the stack, which is pointed by %rsp
	push    0			; INADDR_ANY = 0 (uint32_t)
	push    WORD 0xae10	; 4270
	push    WORD 2		; AF_INET = 2 (unsigned short int)

        ;; preparing bind() arguments
        mov     rdi, rax        ; socket filedescriptor
	mov     rsi, rsp	; struct pointer on previous created
                                ; structure
        mov     rdx, 16         ; struct length
	mov     eax, SYS_BIND
        syscall

	;; call	'listen' system call.
        ;; file descritor is already in
        ;; %rdi. %rsi is the backlog argument. 20 is fine.
        mov     rsi, 0
	mov     eax, SYS_LISTEN
        syscall

_accept_loop:
        ;; entering accept loop

        
        ;; call 'accept' system call
        mov       rax, SYS_ACCEPT
        mov       rsi, 0          ; NULL, unused
        mov       rdx, 0          ; size = 0
        syscall

        ;; backup main socket/fd in register r8
        mov       r8, rdi
        ;; shorts execution
        jmp _write


_exit:
	;; exit syscall
	mov     rax, 60
	mov     rdi, 0
	syscall


_write:
        ;; first, read and discard any received data. This step
        ;; is needed because of HTTP design (query/response)
        
        mov     rdi, rax
        ;; rdi now contains the client's
        ;; file descriptor.
	;; read syscall
	mov     rax, SYS_READ
	;; length of message
	mov     rdx, 4096
	syscall

        
	;; write syscall
	mov     rax, 1
	;;mov	rdi, 1
	;; message address
	mov     rsi, http_hello
	;; length of message
	mov     rdx, 109
	;; call write syscall
	syscall

        ;; shutdown socket
        ;; & cleanup code
        
        mov     rax, 48
        mov     rsi, 0
        ;; call shutdown syscall (48)
        syscall

        mov     rax, 3
        ;; call close syscall (3)
        syscall

        ;; restore saved filedescriptor
        mov     rdi, r8
        ;; go back and accept other TCP connexions
        jmp _accept_loop
