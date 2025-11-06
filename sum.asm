.model small
.stack 100h

.data
    prompt db 'Enter a number (1-100): $'
    buffer db 6
    db 0
    db 6 dup(0)
    result_msg db 0Dh, 0Ah, 'Sum: $'

.code
start:
    mov ax, @data
    mov ds, ax

    ; 显示提示信息
    mov ah, 09h
    mov dx, offset prompt
    int 21h

    ; 读取输入字符串
    mov ah, 0Ah
    mov dx, offset buffer
    int 21h

    ; 转换输入字符串为数字 - 使用DI保存结果
    mov si, offset buffer+2
    xor di, di          ; 使用DI存储输入的数字
    mov bx, 10
    mov cx, 0           ; 临时使用CX
convert_input:
    mov cl, [si]
    cmp cl, 0Dh
    je convert_done
    sub cl, '0'
    mov ax, di          ; 将当前值移到AX进行乘法
    mul bx
    mov di, ax          ; 结果存回DI
    add di, cx          ; 加上新数字
    inc si
    jmp convert_input

convert_done:
    ; 现在DI中有输入的数字n
    ; 计算1到n的和 - 使用SI存储和
    mov cx, di          ; n在CX中
    xor si, si          ; 使用SI存储和，初始为0
    mov bx, 1           ; 当前数字
sum_loop:
    add si, bx
    inc bx
    cmp bx, cx
    jle sum_loop

    ; 输出结果消息
    mov ah, 09h
    mov dx, offset result_msg
    int 21h

    ; 将和从SI移动到AX进行输出
    mov ax, si
    call print_ax_dec

    ; 退出程序
    mov ah, 4ch
    int 21h

; 子程序：打印AX中的十进制数
print_ax_dec proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0
    mov bx, 10
div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz div_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_ax_dec endp

end start