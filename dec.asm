DATA SEGMENT
    DEC_PROMPT DB 'Please input a Dec number (0-255):', 0DH, 0AH, '$'
    HEX_PROMPT DB 'The Hex number:', 0DH, 0AH, '$'
    NEWLINE DB 0DH, 0AH, '$'
    DEC_BUFFER DB 4, 0, 4 DUP(0)
    HEX_BUFFER DB 3 DUP(0), '$'  ; 确保以'$'结尾
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX
    
    ; 显示输入提示
    MOV AH, 09H
    MOV DX, OFFSET DEC_PROMPT
    INT 21H
    
    ; 读取10进制输入
    MOV AH, 0AH
    MOV DX, OFFSET DEC_BUFFER
    INT 21H
    
    ; 输出换行
    MOV AH, 09H
    MOV DX, OFFSET NEWLINE
    INT 21H
    
    ; 转换10进制到16进制
    CALL DEC_TO_HEX
    
    ; 显示结果提示
    MOV AH, 09H
    MOV DX, OFFSET HEX_PROMPT
    INT 21H
    
    ; 显示16进制结果
    CALL DISPLAY_HEX
    
    ; 程序结束
    MOV AH, 4CH
    INT 21H

DEC_TO_HEX PROC
    ; 清零所有寄存器
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    
    ; 获取输入字符数
    MOV CL, [DEC_BUFFER+1]
    CMP CL, 0
    JE DONE
    
    ; 指向输入开始
    MOV SI, OFFSET DEC_BUFFER+2
    
CONVERT_LOOP:
    MOV BL, [SI]
    CMP BL, 0DH
    JE DONE
    
    ; 验证字符是否为数字
    CMP BL, '0'
    JB DONE
    CMP BL, '9'
    JA DONE
    
    SUB BL, '0'
    
    ; AX = AX * 10 + BX
    MOV DX, 10
    MUL DX
    ADD AX, BX
    
    INC SI
    LOOP CONVERT_LOOP
    
DONE:
    RET
DEC_TO_HEX ENDP

DISPLAY_HEX PROC
    ; 保存结果到BX
    MOV BX, AX
    
    ; 初始化输出缓冲区
    MOV DI, OFFSET HEX_BUFFER
    MOV BYTE PTR [DI], '0'
    MOV BYTE PTR [DI+1], '0'
    MOV BYTE PTR [DI+2], '$'
    
    ; 处理高4位
    MOV AL, BL
    MOV CL, 4
    SHR AL, CL
    CMP AL, 10
    JB DIGIT1
    ADD AL, 'A' - 10
    JMP STORE1
DIGIT1:
    ADD AL, '0'
STORE1:
    MOV [DI], AL
    
    ; 处理低4位
    MOV AL, BL
    AND AL, 0FH
    CMP AL, 10
    JB DIGIT2
    ADD AL, 'A' - 10
    JMP STORE2
DIGIT2:
    ADD AL, '0'
STORE2:
    MOV [DI+1], AL
    
    ; 显示结果
    MOV AH, 09H
    MOV DX, OFFSET HEX_BUFFER
    INT 21H
    
    RET
DISPLAY_HEX ENDP

CODE ENDS
END START