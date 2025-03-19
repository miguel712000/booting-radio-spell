# Booting Radio Spell

Este proyecto implementa un bootloader en ensamblador x86 para practicar el alfabeto fonético militar. Se ejecuta desde el sector de arranque de un disco y muestra letras aleatorias que el usuario debe deletrear.

## Archivos incluidos

- `2019061555-tarea1.asm` - Código fuente en ensamblador.
- `2019061555-tarea1.bin` - Archivo binario compilado.
- `2019061555-tarea1.pdf` - Documentación del proyecto.

## Herramientas utilizadas

- NASM - Ensamblador.
- QEMU - Emulador para pruebas.
- Linux (Ubuntu) - Sistema de desarrollo.
- GitHub - Control de versiones.

## Compilación y ejecución

Compilar el código ensamblador:
```bash
nasm -f bin 2019061555-tarea1.asm -o 2019061555-tarea1.bin
```

Ejecutar en QEMU:
```bash
qemu-system-x86_64 -drive format=raw,file=2019061555-tarea1.bin
```

Grabar en una USB:
```bash
sudo dd if=2019061555-tarea1.bin of=/dev/sdX bs=512 count=1
```
Reemplazar `/dev/sdX` con la unidad correcta.

## Problemas conocidos

- Funciona en QEMU, pero algunas BIOS modernas pueden impedir el arranque en MBR.
- Se intentó habilitar Legacy Boot y desactivar Secure Boot, pero persistieron problemas en hardware real.
- Se verificó la firma `55AA` en el MBR con `hexdump`.

## Documentación
La documentación en formato IEEE está en `2019061555-tarea1.pdf`.

## Repositorio
El código y la documentación están en:
[https://github.com/miguel712000/booting-radio-spell](https://github.com/miguel712000/booting-radio-spell)
