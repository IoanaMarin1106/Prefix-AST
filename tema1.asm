%include "includes/io.inc"

extern getAST
extern freeAST

    ; Used tree structure
struc my_three
    data:   resd 1
    left:   resd 1
    right:  resd 1
endstruc

section .data  
    ; The vector used to store the prefixed Polish form
    parameters:  times 500 dq 0 

    ; Initialization of the tree structure   
three:
    istruc my_three
        at data, dd 0
        at left, dd 0
        at right, dd 0
    iend

section .bss
    ; At this address, the skel stores the root of the tree
    root: resd 1

section .text
global main


; Function for converting a string to a number

conversion:
    mov eax, 0           
    xor ebx, ebx
    xor edx, edx
    push edi

convert:
    xor ebx, ebx  

    ; Each byte of the string is extracted
    mov bl, byte [edi] 
    
    ; It is treated in case the number is negative
    cmp bl, '-' 
    je negative_number
    
    ; It checks if we have reached the end of the string
    test bl, bl 
    je done
    
    cmp bl, '0'
    jl not_digit
    
    cmp bl, '9' 
    jg not_digit
    
    ; If the analyzed byte is a number then its conversion is made
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc edi
    jmp convert
    
negative_number:
    inc edx 
    inc edi
    jmp convert
    
done: 
    pop edi
    cmp edx, 0
    jg negative
    ret
    
negative:
    NOT eax
    add eax, 1
    ret
    
not_digit:
    pop edi
    mov eax, -1
    ret


; Preorder tree function     
RLR:   
    push ebp
    mov ebp, esp
   
    ; The function parameter will be stored in ebx
    mov ebx, dword [ebp + 8] 
   
    ; It checks if it have reached null in the tree
    cmp ebx, 0
    jz end
   
    mov ecx, [ebx]    
    
    ; The eax and edx registers will contain ASCII codes 
    ; of the tree elements
    mov eax, [ecx]  
    mov edx, [ecx + 4]
   
   ; ecx will contain the index in the parameter vector
    mov ecx, dword [ebp + 12] 
   
    mov [parameters + 8 * ecx], eax  
    mov [parameters + 8 * ecx + 4], edx
   
   ; Go to the next index, more precisely to the next elements in "parameters"
    inc ecx 
  
   
   ; We call the function for the left subtree
left_call:

    ; We extract the parameter from the stack
    mov ebx, [ebp + 8]
    
    push ecx
    push dword [ebx + left]
    call RLR
    add esp, 4
 
   ; We call the function for the right subtree
right_call:  

    ; We extract the parameter from the stack
    mov ebx, [ebp + 8]
    
    push ecx
    push dword [ebx + right]
    call RLR
    add esp, 4  
      
end:  
   leave 
   ret
   
     
main:
    mov ebp, esp; for correct debugging

    push ebp
    mov ebp, esp
    
    ; Read the tree and write to the address indicated above
    call getAST
    mov [root], eax
    
    mov [three], eax  
    
    ; We scroll through the tree in preorder and build the vector "parameters"
    ; by keeping its number of elements in the ecx register
    
    xor ecx, ecx
    push ecx
    push dword [three]
    call RLR
    
    ; We keep a copy of the number of elements of the "parameters" vector
    ; in ebx register
    xor ebx, ebx
    mov ebx, ecx 
    
    ; We set the edi register to point to the starting address of the "parameters" vector
    mov edi, parameters  
     
    ; We set the edi register to point to the ending address of the vector "parameters"
start:  
    add edi, 8
    dec ecx
    cmp ecx, 0
    jg start
    
    ; From now edi will point to the end of the "parameters" vector
    sub edi, 8 
    
    ; We restore the number of elements in the vector
    mov ecx, ebx 

   ; Solving the prefixed Polish form
solving_polish_form:

    ; The esi register will store each element of the vector "parameters"
    mov esi, [edi]
    
    ; We check if we have an operand or an operator
    ; If it is operand we pushed the operand into the stack
    ; If it is an operator, we remove the last two values from the stack and perform the operation
    
    cmp esi, '+'
    jz addition
    
    cmp esi, "-"
    jz substraction
    
    cmp esi, "*"
    jz multiplication
    
    cmp esi, "/"
    jz division
      
    ; If it is a number, its conversion will be done,
    ; it will be pushed into the stack and the stack will be restored    
    push edi
    call conversion
    add esp, 4
    
    ; The result of the conversion will be stored in eax
    mov ebx, eax  
    push ebx
   
    jmp continue
    
addition:
    xor eax, eax
    xor ebx, ebx
    
    pop eax
    pop ebx
    add eax, ebx
    push eax
    jmp continue
    
substraction: 
    xor ebx, ebx
    xor eax, eax
    
    pop eax
    pop ebx
    sub eax, ebx
    push eax
    jmp continue
      
multiplication:
    xor ebx, ebx
    xor eax, eax
    
    pop eax
    pop ebx
    imul ebx
    push eax
    jmp continue
    
division:
    xor ebx, ebx
    xor eax, eax
    
    pop eax
    pop ebx
    cdq
    idiv ebx
    push eax
    jmp continue
   
continue: 
 
    ; Go to the next element in the "parameters" vector
    ; and the calculation algorithm is resumed
    sub edi, 8
    dec ecx
    cmp ecx, 0
    jg solving_polish_form
 
    ; The final result will be removed from the stack and stored in the eax register
    pop eax
    PRINT_DEC 4, eax
    
    ; The allocated memory for the tree is released
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret

