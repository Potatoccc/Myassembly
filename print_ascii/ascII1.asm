.MODEL SMALL
.STACK 100H
.DATA
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BL, 'a'        ; 从字母'a'开始
    MOV CX, 2          ; 外层循环：2行
    
OUTER_LOOP:
    PUSH CX            ; 保存外层循环计数器
    MOV CX, 13         ; 内层循环：每行13个字符
    
INNER_LOOP:
    ; 输出当前字符
    MOV DL, BL
    MOV AH, 02H
    INT 21H
    
    ; 输出空格
    MOV DL, ' '
    INT 21H
    
    INC BL             ; 指向下一个字符
    LOOP INNER_LOOP    ; 内层循环
    
    ; 输出换行
    MOV DL, 0DH        ; 回车
    INT 21H
    MOV DL, 0AH        ; 换行
    INT 21H
    
    POP CX             ; 恢复外层循环计数器
    LOOP OUTER_LOOP    ; 外层循环
    
    ; 程序结束
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN               ; 添加END指令，指定程序入口点