DATA SEGMENT
    HEX_PROMPT DB 'Please input a Hex number:', 0DH, 0AH, '$'  ; 16进制输入提示
    DEC_PROMPT DB 'The Dec number:', 0DH, 0AH, '$'             ; 10进制输出提示
    NEWLINE DB 0DH, 0AH, '$'                                   ; 换行符
    HEX_BUFFER DB 5, 0, 5 DUP(0)                              ; 16进制输入缓冲区，初始化为0
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA               ; 加载数据段地址到AX
    MOV DS, AX                 ; 设置数据段寄存器
    
    ; 显示输入提示
    MOV AH, 09H                ; DOS功能09H - 显示字符串
    LEA DX, HEX_PROMPT         ; 加载提示字符串地址
    INT 21H                    ; 调用DOS中断
    
    ; 读取16进制输入
    MOV AH, 0AH                ; DOS功能0AH - 缓冲输入
    LEA DX, HEX_BUFFER         ; 加载输入缓冲区地址
    INT 21H                    ; 调用DOS中断
    
    ; 输出换行
    MOV AH, 09H                ; DOS功能09H - 显示字符串
    LEA DX, NEWLINE            ; 加载换行符地址
    INT 21H                    ; 调用DOS中断
    
    ; 调用16进制转10进制子程序
    CALL HEX_TO_DEC            ; 调用转换函数
    PUSH AX                    ; 保存转换结果，防止被后续INT 21H调用破坏
    
    ; 显示结果提示
    MOV AH, 09H                ; DOS功能09H - 显示字符串
    LEA DX, DEC_PROMPT         ; 加载结果提示地址
    INT 21H                    ; 调用DOS中断
    
    ; 恢复转换结果并显示
    POP AX                     ; 恢复转换结果
    CALL DISPLAY_DECIMAL       ; 调用显示函数
    
    ; 程序结束
    MOV AH, 4CH                ; DOS功能4CH - 程序终止
    INT 21H                    ; 调用DOS中断

; 16进制转10进制子程序
; 输入：无
; 输出：AX = 转换后的十进制值
HEX_TO_DEC PROC
    ; 清零所有主要寄存器
    XOR AX, AX                 ; 清零AX - 结果寄存器
    XOR BX, BX                 ; 清零BX - 字符处理寄存器
    XOR CX, CX                 ; 清零CX - 计数器寄存器
    XOR DX, DX                 ; 清零DX - 通用寄存器
    
    MOV SI, OFFSET HEX_BUFFER + 2 ; 使用OFFSET确保SI正确指向输入字符串开始
    
NEXT_CHAR:
    MOV BL, [SI]               ; 读取当前字符到BL
    CMP BL, 0DH                ; 检查是否是回车符（输入结束）
    JE CONVERT_DONE            ; 如果是回车符，转换完成
    CMP BL, 0                  ; 检查是否是空字符
    JE CONVERT_DONE            ; 如果是空字符，转换完成
    
    CALL CHAR_TO_VALUE         ; 将字符转换为数值
    
    ; 将当前结果左移4位（乘以16）并加上新数值
    MOV CL, 4                  ; 设置移位次数为4
    SHL AX, CL                 ; AX = AX * 16
    ADD AL, BL                 ; 加上当前字符的数值
    
    INC SI                     ; 移动到下一个字符
    JMP NEXT_CHAR              ; 继续处理下一个字符
    
CONVERT_DONE:
    RET                        ; 返回，结果在AX中
HEX_TO_DEC ENDP

; 字符转数值子程序
; 输入：BL = ASCII字符
; 输出：BL = 对应的数值（0-15）
CHAR_TO_VALUE PROC
    CMP BL, '0'                ; 检查是否小于'0'
    JB INVALID_CHAR            ; 如果小于，无效字符
    CMP BL, '9'                ; 检查是否大于'9'
    JA CHECK_UPPER             ; 如果大于，检查大写字母
    SUB BL, '0'                ; '0'-'9' 转 0-9
    JMP VALID_CHAR             ; 跳转到有效字符处理

CHECK_UPPER:
    CMP BL, 'A'                ; 检查是否小于'A'
    JB INVALID_CHAR            ; 如果小于，无效字符
    CMP BL, 'F'                ; 检查是否大于'F'
    JA CHECK_LOWER             ; 如果大于，检查小写字母
    SUB BL, 'A'                ; 减去'A'的ASCII值
    ADD BL, 10                 ; 加上10得到10-15
    JMP VALID_CHAR             ; 跳转到有效字符处理

CHECK_LOWER:
    CMP BL, 'a'                ; 检查是否小于'a'
    JB INVALID_CHAR            ; 如果小于，无效字符
    CMP BL, 'f'                ; 检查是否大于'f'
    JA INVALID_CHAR            ; 如果大于，无效字符
    SUB BL, 'a'                ; 减去'a'的ASCII值
    ADD BL, 10                 ; 加上10得到10-15

VALID_CHAR:
    RET                        ; 返回

INVALID_CHAR:
    MOV BL, 0                  ; 无效字符设为0
    RET                        ; 返回
CHAR_TO_VALUE ENDP

; 显示10进制数字程序
; 输入：AX = 要显示的十进制值
; 输出：无（直接显示到屏幕）
DISPLAY_DECIMAL PROC
    ; 保存所有使用的寄存器
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 10                 ; 除数为10
    XOR CX, CX                 ; 清零CX - 数字位数计数器
    
    ; 特殊情况处理：如果AX为0，直接显示'0'
    CMP AX, 0                  ; 检查结果是否为0
    JNE DIV_LOOP               ; 如果不为0，进行正常转换
    
    ; 处理结果为0的情况
    MOV DL, '0'                ; 要显示的字符'0'
    MOV AH, 02H                ; DOS功能02H - 显示字符
    INT 21H                    ; 显示字符
    JMP DISPLAY_DONE           ; 跳转到结束
    
DIV_LOOP:
    XOR DX, DX                 ; 清零DX - 被除数高位
    DIV BX                     ; AX ÷ 10，商在AX，余数在DX
    PUSH DX                    ; 保存余数（当前位数）
    INC CX                     ; 位数计数加1
    CMP AX, 0                  ; 检查商是否为0
    JNE DIV_LOOP               ; 如果不为0，继续除法
    
    MOV AH, 02H                ; DOS功能02H - 显示字符
    
PRINT_LOOP:
    POP DX                     ; 取出保存的数字（从高位到低位）
    ADD DL, '0'                ; 转换为ASCII字符
    INT 21H                    ; 显示字符
    LOOP PRINT_LOOP            ; 继续显示直到所有数字显示完
    
DISPLAY_DONE:
    ; 恢复所有使用的寄存器
    POP DX
    POP CX
    POP BX
    POP AX
    RET                        ; 返回
DISPLAY_DECIMAL ENDP

CODE ENDS
END START