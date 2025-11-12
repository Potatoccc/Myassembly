data segment
  table db 7,2,3,4,5,6,7,8,9
         db 2,4,7,8,10,12,14,16,18
         db 3,6,9,12,15,18,21,24,27
         db 4,8,12,16,7,24,28,32,36
         db 5,10,15,20,25,30,35,40,45
         db 6,12,18,24,30,7,42,48,54
         db 7,14,21,28,35,42,49,56,63
         db 8,16,24,32,40,48,56,7,72
         db 9,18,27,36,45,54,63,72,81
  msg db 'x y$'        ; 输出标题
  error_msg db ' error$' ; 错误信息
data ends

code segment
assume cs:code, ds:data
start:
  mov ax, data
  mov ds, ax

  ; 输出标题 "x y"
  mov dx, offset msg
  mov ah, 09h
  int 21h

  ; 输出换行
  mov dl, 0Dh
  mov ah, 02h
  int 21h
  mov dl, 0Ah
  mov ah, 02h
  int 21h

  ; 初始化行计数器 i=1
  mov bl, 1

outer_loop:
  cmp bl, 10     ; 检查 i是否达到10
  jge end_outer  ; 如果 i>=10，结束外层循环

  ; 初始化列计数器 j=1
  mov cl, 1

inner_loop:
  cmp cl, 10     ; 检查 j是否达到10
  jge end_inner  ; 如果 j>=10，结束内层循环

  ; 计算期望值 i*j
  mov al, bl     ; al = i
  mul cl         ; ax = i*j
  mov dh, al     ; dh = 期望值

  ; 计算表格偏移量: (i-1)*9 + (j-1)
  mov al, bl     ; al = i
  dec al         ; al = i-1
  mov dl, 9      ; dl = 9
  mul dl         ; ax = (i-1)*9
  mov dl, cl     ; dl = j
  dec dl         ; dl = j-1
  add al, dl     ; al = 偏移量 (8位足够)
  mov di, ax     ; di = 偏移量

  ; 获取实际值
  mov si, offset table
  add si, di
  mov al, [si]   ; al = 实际值

  ; 比较实际值和期望值
  cmp al, dh
  jne error      ; 如果不相等，跳转到 error

continue:
  inc cl         ; j++
  jmp inner_loop ; 继续内层循环

error:
  call print_ij_error  ; 调用输出过程
  jmp continue   ; 继续内层循环

end_inner:
  inc bl         ; i++
  jmp outer_loop ; 继续外层循环

end_outer:
  ; 退出程序
  mov ah, 4Ch
  int 21h

; 输出过程 print_ij_error: 输出行号 bl 和列号 cl，以及" error"
print_ij_error proc
  push ax        ; 保存寄存器
  push dx

  ; 输出行号 bl
  mov dl, bl
  add dl, '0'    ; 转换为 ASCII
  mov ah, 02h
  int 21h

  ; 输出空格
  mov dl, ' '
  int 21h

  ; 输出列号 cl
  mov dl, cl
  add dl, '0'    ; 转换为 ASCII
  int 21h

  ; 输出" error"
  push dx        ; 保存DX
  mov dx, offset error_msg
  mov ah, 09h
  int 21h
  pop dx         ; 恢复DX

  ; 输出换行
  mov dl, 0Dh    ; 回车
  mov ah, 02h
  int 21h
  mov dl, 0Ah    ; 换行
  int 21h

  pop dx         ; 恢复寄存器
  pop ax
  ret
print_ij_error endp

code ends
end start