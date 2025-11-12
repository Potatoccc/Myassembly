.model small
.stack 100h

.data
    prompt db 'The 9mu19 table:', 0Dh, 0Ah, '$'
    buffer db '0x0=00  $'   ; 输出缓冲区

.code
start:
    mov ax, @data
    mov ds, ax
    
    ; 输出提示字符串
    mov ah, 09h
    mov dx, offset prompt
    int 21h

    ; 初始化外层循环计数器（被乘数从9到1）
    mov cl, 9

outer_loop:
    ; 初始化内层循环计数器（乘数从1到当前被乘数）
    mov bl, 1

inner_loop:
    ; 设置过程参数：AL=被乘数，BL=乘数
    mov al, cl
    call print_mul_item
    inc bl
    cmp bl, cl
    jle inner_loop   ; 如果乘数 ≤ 被乘数，继续内层循环

    ; 输出换行
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    dec cl
    jnz outer_loop   ; 继续外层循环直到被乘数为0

    ; 程序结束
    mov ax, 4C00h
    int 21h

; 过程：输出乘法项
; 输入：AL = 被乘数, BL = 乘数
print_mul_item proc
    ; 保存寄存器
    push ax
    push bx
    push cx
    push dx

    ; 保存参数值
    mov ch, al   ; 保存被乘数
    mov dh, bl   ; 保存乘数

    ; 转换被乘数为字符并存入缓冲区
    add al, '0'
    mov [buffer], al

    ; 转换乘数为字符并存入缓冲区
    mov al, bl
    add al, '0'
    mov [buffer+2], al

    ; 计算乘积：被乘数 * 乘数
    mov al, ch
    mul dh       ; AX = AL * DH

    ; 将乘积转换为十位和个位
    mov cl, 10
    div cl       ; AL = 商（十位），AH = 余数（个位）

    ; 处理十位数字
    cmp al, 0
    jne ten_digit
    mov al, ' '   ; 十位为0，输出空格
    jmp store_ten
ten_digit:
    add al, '0'
store_ten:
    mov [buffer+4], al

    ; 处理个位数字
    mov al, ah
    add al, '0'
    mov [buffer+5], al

    ; 输出缓冲区字符串
    mov ah, 09h
    mov dx, offset buffer
    int 21h

    ; 恢复寄存器
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_mul_item endp

end start