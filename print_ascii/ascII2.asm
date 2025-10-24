.MODEL SMALL
.STACK 100H
.DATA
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    MOV BL, 'a'       
    MOV CX, 2         
    
OUTER_LOOP:
    PUSH CX           
    MOV CX, 13         
    
INNER_LOOP:

    MOV DL, BL
    MOV AH, 02H
    INT 21H
    
    MOV DL, ' '
    INT 21H
    
    INC BL    

    DEC CX
    JNZ INNER_LOOP     

    MOV DL, 0DH    
    INT 21H
    MOV DL, 0AH      
    INT 21H
    
    POP CX         
    DEC CX
    JNZ OUTER_LOOP   
    

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN         