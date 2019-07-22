; NOMBRE DEL PROYECTO: Proyecto de estructura del computador
; DESCRIPCIÓN: DADA UNA MATRIZ CUADRADA DE N MAX 10, MOSTRAR POR FILAS, IMPRIMIR EN ZIGZAG Y TRANSPONERLA 
; AUTOR: Rolando Andrade
; FECHA: 2 de Julio
; PASOS PARA COMPILAR EN VISUAL STUDIO 2012
	;-En el explorador de soluciones, click derecho en el proyecto generado(No la solución,no el archivo,sino el proyecto).
	;-Click en personalizaciones de compilación.
	;-Seleccionar masm y darle aceptar.
	;-En el explorador de soluciones, click derecho en el archivo assemblyCode.asm
	;-Click en propiedades.
	;-Excluir de la compilación = NO
	;-Tipo de elemento Microsft Micro Assembler.
	;- Si da un error de LINK
		;--En el explorador de soluciones, click derecho en el proyecto generado
		;--Click en propiedades.
		;--Vinculador>Sistema>Subsistema>SYSTEM CONSOLE

.386
.model flat,stdcall
.stack 4096

;FUNCIONES DE LA WIN32API

SetConsoleCursorPosition PROTO : DWORD, : DWORD
Sleep PROTO : DWORD
SetConsoleTextAttribute PROTO : DWORD, : DWORD
STD_INPUT_HANDLE EQU -10          
STD_ERROR_HANDLE EQU -11             
STD_OUTPUT_HANDLE EQU -12            
ExitProcess PROTO : DWORD
ReadConsoleA PROTO : DWORD, : DWORD, : DWORD, : DWORD, : DWORD
WriteConsoleA PROTO : DWORD, : DWORD, : DWORD, : DWORD, : DWORD
GetStdHandle PROTO : DWORD

;VARIABLES
.data
consoleOutHandle dd ? 
consoleInHandle dd ? 
bytesWritten dd ?
buffer dd ? 
dimension dd 5
largo dd ?
cont dd 0;
mensaje db 13,10,3,3,3,3,3,3,3,3,3,3,"   Menu   ",3,3,3,3,3,3,3,3,3,3,13,10,3,"                            ",3,13,10
o1 db 3,"  1. Introducir dimension   ",3,13,10
o2 db 3,"  2. Mostrar                ",3,13,10
o3 db 3,"  3. Zig-Zag                ",3,13,10
o4 db 3,"  4. Transpuesta            ",3,13,10
o8 db 3,"  5. Zig-Zag vertical       ",3,13,10,3,"                            ",3,13,10
linea db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,13,10
o5 db 13,10,"   Opcion: ",?
null dd ?;
error db 13,10,13,10,"Mmmmm algo esta mal, intenta con otro valor",13,10,13,10,?
m1 db 13,10,"     Introducir dimension de la matriz [2-10]     ",13,10,13,10,"   Dimension: ",?
m2 db 13,10,"     Mostrar la matriz     ",13,10,13,10,?
m3 db 13,10,"     Mostrar matriz en Zig-Zag     ",13,10,13,10,?
m5 db 13,10,"     Mostrar matriz en Zig-Zag Vertical     ",13,10,13,10,?
m4 db 13,10,"Presione ENTER para continuar...",?
a1 db " 1  "," 2  "," 3  "," 4  "," 5  "," 6  "," 7  "," 8  "," 9  "," 10 "," 11 "," 12 "," 13 "," 14 "," 15 "," 16 "," 17 "," 18 "," 19 "," 20 "
a2 db " 21 "," 22 "," 23 "," 24 "," 25 "," 26 "," 27 "," 28 "," 29 "," 30 "," 31 "," 32 "," 33 "," 34 "," 35 "," 36 "," 37 "," 38 "," 39 "," 40 "
a3 db " 41 "," 42 "," 43 "," 44 "," 45 "," 46 "," 47 "," 48 "," 49 "," 50 "," 51 "," 52 "," 53 "," 54 "," 55 "," 56 "," 57 "," 58 "," 59 "," 60 "
a4 db " 61 "," 62 "," 63 "," 64 "," 65 "," 66 "," 67 "," 68 "," 69 "," 70 "," 71 "," 72 "," 73 "," 74 "," 75 "," 76 "," 77 "," 78 "," 79 "," 80 " 
a5 db " 81 "," 82 "," 83 "," 84 "," 85 "," 86 "," 87 "," 88 "," 89 "," 90 "," 91 "," 92 "," 93 "," 94 "," 95 "," 96 "," 97 "," 98 "," 99 "," 100"
auxd dd ?
audb db ?
iI dd ?
iJ dd ?
desp dd ?
salto db 13,10,?
vacio db "    ",?
elemento db ?
.code
	;MAIN
	main PROC uses esi
		CALL limpiar
		mov eax,0
		CALL menu
		CALL leer;
		CMP eax,0
		JE case0
		CMP eax,1
		JE case1
		CMP eax,2
		JE case2
		CMP eax,3
		JE case3
		CMP eax,4
		JE case4
		CMP eax,5
		JE case5
		;switch
			ningun:
				CALL msgerror;
				CALL main
			case0:
				INVOKE ExitProcess,0
			case1:
				;Introducir dimensiones
				CALL idimensiones
				CALL main;
			case2:
				;imprimir
				CALL mostrar;
				CALL pausa;
				CALL main;
			case3:
				;zig-zag
				CALL zigzag;
				CALL pausa;
				CALL main;
			case4:
				;traspuesta
				CALL transponer
				CALL pausa;
				CALL main;
			case5:
				;mostrar en zig zag vertical
				CALL zzVertical
				CALL pausa;
				CALL main;
		RET
	main ENDP

	;IMPRIMIR MENU

	menu PROC
		LEA EDX,mensaje;COLOCA EL OFFSET DEL TEXTO DEL MENU EN EDX
		CALL escribir;
		RET
	menu ENDP

	;ESCRIBIR UN TEXTO QUE SE ENCUENTRE A PARTIR DE LA DIRECCIÓN GUARDADA EN EL REGISTRO EDX

	escribir PROC
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE; Llama al manejador de win32, éste coloca la acción en eax. eax=7 para outputs por consola.
		mov consoleOutHandle, eax;
		CALL longitud
		pushad    
		INVOKE WriteConsoleA, consoleOutHandle, edx, largo, offset bytesWritten, 0
		popad
		RET
	escribir ENDP

	;ENTRADAS DE USUARIO

	leer PROC
		push buffer;
		INVOKE GetStdHandle,STD_INPUT_HANDLE
		MOV consoleInHandle, eax;
		INVOKE ReadConsoleA, consoleInHandle, offset buffer, 100,offset bytesWritten, 0
		MOV EAX,buffer;
		pop buffer;
		SUB EAX,658736; CONVIERTE EL RESULTADO A UN NUMERO ENTRE 1 Y 9
		CMP EAX,167977729; SE TRATA DE UN 10?
		JE diez
		RET
		diez:
			MOV EAX,10;
		RET
	leer ENDP

	;INTRODUCIR LAS DIMENSIONES DE LA MATRIZ

	idimensiones PROC
		CALL limpiar
		LEA EDX,m1;
		CALL escribir;
		CALL leer;
		CMP EAX,2
		JB fueradeaqui
		CMP EAX,10
		JA fueradeaqui
		MOV dimension,EAX;
		RET
		fueradeaqui:
			;SI NO ESTÁ ENTRE 2 Y 10 MANDA UN MENSAJE DE ERROR
			CALL msgerror
			CALL idimensiones
		RET
	idimensiones ENDP

	;MOSTRAR LA MATRIZ (DOS BUCLES)

	mostrar PROC
		CALL limpiar
		LEA EDX,m2
		CALL escribir
		MOV cont,0;
		LEA EDX,a1; ACCESO DIRECTO A LA MATRIZ
		bucleFilasM:
			MOV ECX,dimension;

			;BUCLE LOOP

			bucleColumnasM:
				push EDX;
				CALL imprimird
				pop EDX;
				ADD EDX,4
				;inc ECX;
				;CMP ECX,dimension
				;JB bucleColumnasM
				LOOP bucleColumnasM
			CALL saltoLinea
			inc cont;
			MOV ECX,cont;
			CMP ECX,dimension
			JB bucleFilasM;
		ret
	mostrar ENDP

	;IMPRIME LOS NÚMEROS DE LA MATRIZ

	imprimird PROC
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE; Llama al manejador de win32, éste coloca la acción en eax. eax=7 para outputs por consola.
		mov consoleOutHandle, eax; 
		pushad    
		INVOKE WriteConsoleA, consoleOutHandle, edx, 4, offset bytesWritten, 0
		popad
		RET
	imprimird ENDP

	;ESTABLECE UN SALTO DE LINEA

	saltoLinea PROC
		push EDX
		LEA EDX,salto
		CALL escribir
		pop EDX
		RET
	saltoLinea ENDP

	;IMPRIME LA MATRIZ EN ZIG-ZAG

	zigzag PROC
		CALL limpiar
		LEA EDX,m3
		CALL escribir
		MOV EAX,dimension
		MOV EBX, 2
		MUL EBX;            EAX es el doble de la dimension
		ADD EAX,1;          Se le suma uno pues el indexado lo empiezo en 1 y no en 0
		MOV auxd,EAX;       auxd es 2N+1
		MOV cont,2
		MOV desp,-1;        desplazamiento
		bucle2N1:
		;Recorre la matriz 2N VECES
			MOV EAX,dimension;   
			MOV iJ,EAX;			i=j=dimension
			MOV iI,EAX;
			MOV ECX,desp;      ECX se encarga del desplazamiento
			CMP ECX,1;         si no está aumentando está en el principio
			JNE bucleFilasZ
			MOV iI,1
			MOV iJ,1
			bucleFilasZ:
				;recorre las filas
				MOV EAX,dimension;
				MOV iJ,EAX;			estás en la última columna
				MOV ECX,desp
				CMP ECX,1
				JNE bucleColumnasZ
				MOV iJ,1
				bucleColumnasZ:
					MOV EAX, iI
					ADD EAX,iJ
					CMP EAX,cont
					JNE avanzabcZ
					CALL mostrarZ
					avanzabcZ:
					MOV ECX,iJ
					ADD ECX,desp
					CMP ECX,0
					JE salirbcZ
					CMP ECX,dimension
					JA salirbcZ
					MOV iJ,ECX;
					JMP bucleColumnasZ;
					salirbcZ:
			MOV ECX,iI
			ADD ECX,desp
			CMP ECX,0
			JE salirbfZ
			CMP ECX,dimension
			JA salirbfZ
			MOV iI,ECX;
			JMP bucleFilasZ;
			salirbfZ:
		CALL saltoLinea;
		INC cont
		NEG desp;
		MOV ECX,cont
		;cont<2N-1?
		CMP ECX,auxd
		JB bucle2N1
		RET
	zigzag ENDP

	;IMPRIME EL DIGITO QUE CUMPLIA LA CONDICION

	mostrarZ PROC
		MOV EAX,iI
		SUB EAX,1;
		MOV EBX,4
		MUL EBX
		MOV EBX,dimension
		MUL EBX
		MOV EBX,EAX
		MOV EAX,iJ
		SUB EAX,1
		MOV ECX,4
		MUL ECX
		MOV EDI,EAX
		LEA EDX,a1[EBX+EDI];ACCESO INDIRECTO CON REGISTO
		CALL imprimird
		RET
	mostrarZ ENDP

	;INTERCAMBIAR FILAS POR COLUMNAS

	transponer PROC
		MOV iI,0;
		bucleFilasT:
			MOV EAX,iI
			MOV iJ,EAX
			bucleColumnasT:
				MOV cont,0
				intercambia4veces:
					;HAY QUE RECORDAR QUE CADA NÚMERO ESTÁ COMPUESTO POR CUATRO ESPACIOS DE MEMORIA
					;POR ESO SE INTERCAMBIAN LOS CUATRO ESPACIOS
					PUSH ECX;
					MOV EAX,dimension
					MOV EDX,iI
					MUL EDX
					MOV EDX,4
					MUL EDX
					MOV ECX,EAX
					MOV EAX,iJ
					MOV EDI,4
					MUL EDI
					MOV EDI,EAX
					ADD EDI,cont
					MOV auxd,ECX
					MOV desp,EDI
					MOV BH,a1[ECX+EDI]
					MOV EAX,dimension
					MOV ECX,iJ
					MUL ECX
					MOV ECX,4
					MUL ECX
					MOV ECX,EAX
					MOV EAX,iI
					MOV EDI,4
					MUL EDI
					MOV EDI,EAX
					ADD EDI,cont
					MOV EAX,ECX
					MOV BL,a1[EAX+EDI]
					MOV a1[EAX+EDI],BH;
					MOV ECX,auxd
					MOV EDI,desp
					MOV a1[ECX+EDI],BL;
					POP ECX;
					INC cont;
					MOV ECX,cont
					CMP ECX,4
					JB intercambia4veces
				INC iJ;
				LEA EDX,a1
				MOV ECX, iJ
				CMP ECX,dimension
				JB bucleColumnasT
			INC iI
			MOV ECX,iI
			CMP ECX,dimension
			JB bucleFilasT
		RET;
	transponer ENDP

	;COLOREA LA PANTALLA DE BLANCO

	limpiar PROC
		INVOKE GetStdHandle, STD_OUTPUT_HANDLE; Llama al manejador de win32, éste coloca la acción en eax. eax=7 para outputs por consola.
		mov consoleOutHandle, eax; 
		INVOKE SetConsoleTextAttribute,consoleOutHandle,15*10h
		INVOKE SetConsoleCursorPosition,consoleOutHandle,0
		MOV iI,0
		bucleuno:
			MOV iJ,0
			bucledos:
				LEA EDX,vacio
				CALL imprimird
				INC iJ
				MOV ECX,iJ
				CMP ECX,80
				JB bucledos
			INC iI
			MOV ECX,iI
			CMP ECX,10
			JB bucleuno
			INVOKE SetConsoleCursorPosition,consoleOutHandle,0
			RET
	limpiar ENDP

	;ESPERA A QUE SE PRESIONE ENTER

	pausa PROC
		LEA EDX,m4
		CALL escribir
		CALL leer
		RET
	pausa ENDP

	;ESTABLECE LA LONGITUD DE UNA CADENA DE CARACTERES

	longitud PROC
		MOV ECX,EDX
		LEA EDX,[ECX+1]
		repite:
			MOV AL,[ECX]
			INC ECX
			TEST AL,AL
			JNE repite
			SUB ECX,EDX
			MOV largo,ECX
		RET
	longitud ENDP

	;IMPRIME MENSAJE DE ERROR

	msgerror PROC
		LEA EDX, error;
		CALL escribir;
		INVOKE Sleep,2000
		RET
	msgerror ENDP

	;IMPRIME EN ZIGZAG VERTICAL

	zzVertical PROC
		LEA EDX,m5
		CALL escribir
		CALL limpiar
		MOV desp,1
		MOV iI,1
		MOV iJ,1
		CALL saltoLinea;
		MOV ECX,dimension
		bucleCol:
			PUSH ECX
			MOV ECX, dimension
			bucleFil:
				PUSH ECX;
				CALL mostrarZ
				POP ECX;
				MOV EAX,iI
				ADD EAX,desp
				MOV iI,EAX
			LOOP bucleFil;
			CALL saltoLinea;
			POP ECX
			NEG desp
			MOV EAX,iI
			ADD EAX,desp
			MOV iI,EAX
			INC iJ
		LOOP bucleCol
		RET		
	zzVertical ENDP
END main
