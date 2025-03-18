BITS 16
ORG 0x7C00

start:
    call seleccionar_letra    ; Elegir una letra aleatoria
    call print_string         ; Mostrar la letra en pantalla

    mov si, buffer            ; Apuntar al buffer para entrada del usuario
    call leer_teclado         ; Leer lo que escribe el usuario

    mov si, buffer            ; Apuntar a la entrada del usuario
    mov di, [respuesta]       ; Obtener la dirección correcta de la respuesta
    call comparar             ; Comparar entrada vs. respuesta

    cmp al, 1                 ; ¿Coincide?
    je correcto
    call print_incorrecto
    jmp repetir

correcto:
    inc byte [puntaje]        ; Aumentar el puntaje si es correcto
    call print_correcto

repetir:
    call print_puntaje        ; Mostrar el puntaje
    jmp start                 ; Reiniciar con una nueva letra aleatoria

; ---------------------- Funciones ---------------------- ;

seleccionar_letra:
    mov ah, 0x00              ; Obtener tiempo del reloj BIOS
    int 0x1A                  ; DX = Contador de tiempo
    and dl, 0x0F              ; Limitar valores entre 0 y 15 (16 letras)

    movzx bx, dl              ; Convertir DL a índice

    lea si, letras            ; Apuntar a la tabla de letras
    mov al, [si + bx]         ; Seleccionar letra aleatoria
    mov [letra], al           ; Guardarla en la variable "letra"

    lea si, palabras          ; Apuntar a la tabla de palabras fonéticas
    shl bx, 1                 ; Multiplicar BX por 2 (cada dirección ocupa 2 bytes)
    add si, bx                ; Sumar el desplazamiento
    mov si, [si]              ; Obtener la dirección de la palabra fonética
    mov [respuesta], si       ; Guardarla en "respuesta"

    ret;

print_puntaje:
    mov si, msg_puntaje       ; Mostrar "Puntaje: "
    call print_texto

    mov al, [puntaje]         ; Obtener el puntaje
    add al, '0'               ; Convertir a ASCII
    mov ah, 0x0E
    int 0x10                  ; Imprimir el puntaje en pantalla

    int 0x10
    ret

print_string:
    mov si, letra             ; Cargar la letra seleccionada
    call print_char           ; Imprimirla
    mov si, msg_pedir         ; Mensaje "Deletree: "
    call print_texto
    ret

print_texto:
    mov ah, 0x0E
    .loop:
        lodsb
        test al, al
        jz done
        int 0x10
        jmp .loop
    done:
        ret

print_char:
    mov ah, 0x0E
    mov al, [si]
    int 0x10
    ret

leer_teclado:
    mov si, buffer
    .lee:
        mov ah, 0x00
        int 0x16

        cmp al, 27      ; ¿Presionó ESC?
        je salir

        cmp al, 13        ; ¿Presionó Enter?
        je fin_lectura
        mov [si], al
        inc si
        mov ah, 0x0E
        int 0x10
        jmp .lee

    salir:
        mov si, msg_salir
        call print_texto
        mov ax, 0x5307
        mov bx, 0x0001
        mov cx, 0x0003
        int 0x15         ; Apagar el sistema

    fin_lectura:
        mov byte [si], 0  ; Finalizar la cadena con un 0
        ret

comparar:
    .loop:
        mov al, [si]      ; Cargar carácter de entrada
        mov bl, [di]      ; Cargar carácter esperado
        cmp al, bl        ; Comparar
        jne fallo
        test al, al
        jz exito
        inc si
        inc di
        jmp .loop
    fallo:
        mov al, 0
        ret
    exito:
        mov al, 1
        ret

print_correcto:
    mov si, msg_correcto
    call print_texto
    ret

print_incorrecto:
    mov si, msg_incorrecto
    call print_texto
    ret

; ---------------------- Datos ---------------------- ;
puntaje db 0              ; Contador de puntaje
letra db 0                ; Variable para la letra seleccionada
respuesta dw 0            ; Dirección de la respuesta fonética

letras db "ABCDEFGHIJKLMNOPQRSTUVWXYZ"  ; Tabla de letras

palabras dw alfa, bravo, charlie, delta, echo, foxtrot, golf, hotel
         dw india, juliet, kilo, lima, mike, november, oscar, papa

alfa db "Alfa", 0
bravo db "Bravo", 0
charlie db "Charlie", 0
delta db "Delta", 0
echo db "Echo", 0
foxtrot db "Foxtrot", 0
golf db "Golf", 0
hotel db "Hotel", 0
india db "India", 0
juliet db "Juliet", 0
kilo db "Kilo", 0
lima db "Lima", 0
mike db "Mike", 0
november db "November", 0
oscar db "Oscar", 0
papa db "Papa", 0


msg_pedir db " Deletree: ", 0
msg_correcto db " Correcto! ", 0
msg_incorrecto db " Incorrecto! ", 0
msg_puntaje db " Puntaje: ", 0
msg_salir db " Saliendo... ", 0


buffer times 20 db 0  ; Buffer para la entrada del usuario

times 510-($-$$) db 0
dw 0xAA55