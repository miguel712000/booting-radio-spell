BITS 16
ORG 0x7C00

start:
    call seleccionar_letra    ; Generar letra aleatoria
    call print_string         ; Mostrar la letra en pantalla

    mov si, buffer            ; Leer entrada del usuario
    call leer_teclado

    mov si, buffer            ; Comparar con la respuesta correcta
    mov di, [respuesta]       ; Obtener dirección de la respuesta almacenada
    call comparar

    cmp al, 1                 ; Verificar si la respuesta es correcta
    je correcto
    call print_incorrecto
    jmp repetir

correcto:
    inc byte [puntaje]        ; Incrementar puntaje si es correcto
    call print_correcto

repetir:
    call print_puntaje        ; Mostrar puntaje actualizado
    jmp start                 ; Reiniciar juego

; ---------------------- Funciones ---------------------- ;

seleccionar_letra:
    mov ah, 0x00              ; Obtener tiempo del reloj BIOS
    int 0x1A                  ; Guarda el tiempo en DX
    and dl, 0x0F              ; Limitar valores entre 0 y 15 (16 letras)

    movzx bx, dl              ; Convertir a índice dentro del rango válido
    lea si, letras
    mov al, [si + bx]         ; Seleccionar letra
    mov [letra], al           ; Guardar la letra seleccionada

    lea si, palabras          ; Obtener la palabra fonética correspondiente
    shl bx, 1                 ; Multiplicar BX por 2 (cada dirección ocupa 2 bytes)
    add si, bx                ; Sumar el desplazamiento a SI
    mov si, [si]              ; Cargar la dirección de la palabra fonética en SI
    mov [respuesta], si       ; Guardar dirección en `respuesta`

    ret

print_puntaje:
    mov si, msg_puntaje  
    call print_texto

    mov al, [puntaje]  
    add al, '0'          ; Convertir el número a ASCII ('0' - '9')
    cmp al, '9'          ; Si el puntaje es mayor a '9', fijarlo en '9'
    jbe .imprime
    mov al, '9'          ; Mantenerlo en '9' si excede el límite

    .imprime:
        mov ah, 0x0E     ; BIOS: imprimir carácter en pantalla
        int 0x10             
        mov si, msg_nueva_linea
        call print_texto
        ret

print_string:
    mov si, msg_linea_divisoria
    call print_texto
    mov si, letra            
    call print_char          
    mov si, msg_pedir        
    call print_texto
    mov si, msg_nueva_linea
    call print_texto
    ret

print_texto:
    mov ah, 0x0E
.loop:
    lodsb                  ; Cargar siguiente carácter en AL
    test al, al            ; Verificar si es un carácter nulo (fin de cadena)
    jz done
    int 0x10               ; Imprimir carácter en pantalla
    jmp .loop
done:
    ret

print_char:
    mov ah, 0x0E
    mov al, [si]           ; Cargar carácter desde la dirección SI
    int 0x10
    mov al, ' '            ; Agregar espacio después de la letra
    int 0x10
    ret

leer_teclado:
    mov si, buffer
.lee:
    mov ah, 0x00
    int 0x16               ; BIOS: leer tecla presionada

    cmp al, 27             ; ESC → Salir del programa
    je salir

    cmp al, 13             ; ENTER → Finalizar entrada del usuario
    je fin_lectura

    mov [si], al           ; Guardar carácter ingresado en el buffer
    inc si                 ; Avanzar en el buffer
    mov ah, 0x0E           ; BIOS: imprimir carácter en pantalla
    int 0x10
    jmp .lee               ; Seguir leyendo teclas

salir:
    mov si, msg_salir
    call print_texto
    mov ax, 0x5307         ; Solicitar apagado con APM (Advanced Power Management)
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15               ; BIOS: Ejecutar llamada para apagar sistema

fin_lectura:
    mov byte [si], 0       ; Finalizar cadena con un carácter nulo
    ret

comparar:
.loop:
    mov al, [si]           ; Cargar carácter de la entrada
    mov bl, [di]           ; Cargar carácter de la respuesta correcta
    cmp al, bl             ; Comparar ambos caracteres
    jne fallo
    test al, al            ; Verificar si se llegó al final de la cadena
    jz exito
    inc si
    inc di
    jmp .loop
fallo:
    mov al, 0              ; Indicar que la respuesta es incorrecta
    ret
exito:
    mov al, 1              ; Indicar que la respuesta es correcta
    ret

print_correcto:
    mov si, msg_nueva_linea
    call print_texto
    mov si, msg_correcto
    call print_texto
    mov si, msg_nueva_linea
    call print_texto
    ret

print_incorrecto:
    mov si, msg_nueva_linea
    call print_texto
    mov si, msg_incorrecto
    call print_texto
    mov si, msg_nueva_linea
    call print_texto
    ret

; ---------------------- Datos ---------------------- ;

puntaje db 0              ; Contador de puntaje del usuario
letra db 0                ; Letra seleccionada al azar
respuesta dw 0            ; Dirección de la respuesta fonética almacenada

letras db "ABCDEFGHIJKLMNOP"  

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

msg_pedir db "Deletree: ", 0
msg_correcto db "Correcto! ", 0
msg_incorrecto db "Incorrecto! ", 0
msg_puntaje db "Puntaje: ", 0
msg_salir db "Saliendo... ", 0
msg_nueva_linea db 0x0D, 0x0A, 0
msg_linea_divisoria db "---------",0x0D, 0x0A, 0

buffer times 20 db 0  ; Espacio reservado para la entrada del usuario

times 510-($-$$) db 0
dw 0xAA55            ; Firma de arranque (Boot Signature)
