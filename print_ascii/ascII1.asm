.MODEL SMALL
.STACK 100H
.DATA
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BL, 'a'        ; ����ĸ'a'��ʼ
    MOV CX, 2          ; ���ѭ����2��
    
OUTER_LOOP:
    PUSH CX            ; �������ѭ��������
    MOV CX, 13         ; �ڲ�ѭ����ÿ��13���ַ�
    
INNER_LOOP:
    ; �����ǰ�ַ�
    MOV DL, BL
    MOV AH, 02H
    INT 21H
    
    ; ����ո�
    MOV DL, ' '
    INT 21H
    
    INC BL             ; ָ����һ���ַ�
    LOOP INNER_LOOP    ; �ڲ�ѭ��
    
    ; �������
    MOV DL, 0DH        ; �س�
    INT 21H
    MOV DL, 0AH        ; ����
    INT 21H
    
    POP CX             ; �ָ����ѭ��������
    LOOP OUTER_LOOP    ; ���ѭ��
    
    ; �������
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN               ; ���ENDָ�ָ��������ڵ�