# Descripcion: Implementacon del juego Snake
# Nombres:Yerimar Manzo 14-10611 Jonathan Bautista 16-10109

.data

#Dimensiones

D: .word 0x10008000 	#Direccion a partir de la cual empieza el simulador
M: .word 32		#Columnas
N: .word 32		#Filas
S: .word 2		#Refrescamiento

#Colores

CPared: .word	0xCCCCFF
SCCabeza: .word	0x006633
SCCola: .word  0x009900
CManzanas: .word 0xFF3333
Negro: .word 0x000000
Rosa: .word 0xCC0066

#Stats

Puntuacion: .word 0
Aumentopuntos: .word 10
SVelocidad: .word 200
Metas: .word 100 , 250 , 500
DireccionActual: .word 119
Inicio: .word 0

#Mensajes
Espacio: .space 5

MPerdida: .asciiz "Usted ha perdido... Su puntuacion fue: "
MQuit: .asciiz "Gracias por jugar! Su puntuacion fue: "
MVictoria: .asciiz "Usted ha ganado! Felicitaciones! La maxima puntuacion es: "
MConsultaN: .asciiz "Por favor, indique el valor de N: "				#Mensaje para consultar N (Altura)
MConsultaM: .asciiz "Por favor, indique el valor de M: "				#Mensaje para consultar M (Ancho)
MConsultaS: .asciiz "Por favor, indique el valor de S: "				#Mensaje para consultar S (Refrescamiento)
MConsultaD: .asciiz "Por favor, indique el valor de D: "				#Mensaje para consultar D (Direccion inicio)
MConsultaV: .asciiz "Por favor, indique el valor de V: "				#Mensaje para consultar V (Velocidad serpiente)

#Serpiente

SCabezaX: .word 16
SCabezaY: .word 16
SColaX: .word 16
SColaY: .word 20
LSerpiente: .word 0

#Manzana

ManzanaX: .word
ManzanaY: .word

.text

main:

###################################################
#******************Customizacion******************#
###################################################
	
Customizacion_Consulta:
	la $a0, MConsultaN
	la $a1, Espacio
	li $a2, 5
	
	li $v0, 54
	syscall
	
	
	
###################################################
#********************Pintando********************#
###################################################

#----------------------x-------------------------#
		#Pintar borde
#----------------------x-------------------------#

PintarIz:
	li $t0, 0		#Iniciamos el contador
	lw $t1, N		#Cargamos la altura en $t1
PintarIz_loop:
	move $a0, $t0
	li $a1, 0		#La coordenada X no cambiara durante el coloreado, permaneciendo en la primera columna
	jal AlinearDireccion
	move $a0, $v0
	lw $a1, CPared		#Cargamos el color de la pared e $a1
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	add $t0, $t0, 1
	
	bne $t0 , $t1, PintarIz_loop	#Seguiremos ciclando, hasta que alcancemos el limite de las dimensiones en Y
	
	
PintarDer:
	li $t0, 0		#Iniciamos el contador
	lw $t1, N		#Cargamos la altura en $t1
PintarDer_loop:
	move $a0, $t0
	lw $a1, M		#Cargamos el ancho, ya que debemos ubicarnos en la ultima columna
	add $a1, $a1, -1	#Evitamos que se salga del borde
	jal AlinearDireccion	#La coordenada X coincidira con la ultima column y no cambiara durante el coloreado del borde derecho
	move $a0, $v0
	lw $a1, CPared		#Cargamos el color de la pared e $a1
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	add $t0, $t0, 1
	
	bne $t0, $t1 , PintarDer_loop		#Seguiremos ciclando, hasta que alcancemos el limite de las dimensiones en Y
	
		
PintarArr:
	li $t0, 0		#Iniciamos el contador
	lw $t1, M		#Cargamos el ancho en $t1
PintarArr_loop:
	move $a1,$t0
	li $a0 , 0		#La coordenada Y no cambiara durante el coloreado, permaneciendo en la primera fila
	jal AlinearDireccion
	move $a0, $v0
	lw $a1, CPared		#Cargamos el color de la pared e $a1
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	add $t0, $t0, 1
	
	bne $t0, $t1 , PintarArr_loop		#Seguiremos ciclando, hasta que alcancemos el limite de las dimensiones en X
	
	
PintarAba:
	li $t0, 0		#Iniciamos el contador
	lw $t1, M		#Cargamos el ancho en $t1
PintarAba_loop:
	move $a1,$t0
	lw $a0, N		#Cargamos la altura, ya que debemos ubicarnos en la ultima fila
	add $a0, $a0, -1
	jal AlinearDireccion
	move $a0, $v0
	lw $a1, CPared		#Cargamos el color de la pared e $a1
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	add $t0, $t0, 1
	
	bne $t0, $t1, PintarAba_loop		#Seguiremos ciclando, hasta que alcancemos el limite de las dimensiones en X
	

#----------------------x-------------------------#
	#Pintar Serpiente en posicion inicial
#----------------------x-------------------------#

PintarCabeza:
	lw $a0, SCabezaY		#Cargamos las coordenadas X y Y de la cabeza, para pasarlas como argumentos
	lw $a1 ,SCabezaX
	jal AlinearDireccion		#Buscamos una direccion alineada con los argumentos guardados
	move $a0, $v0
	li $a1, 5			#Cargamos en $a1 el tamano inicial de la serpiente (5)
	
	addiu $sp, $sp, -12  		#Prologo
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	addiu $fp , $sp,12
	
	jal list_crear			#Creamos nuestra lista, con posicion inicial igual a la dir de la cabeza
	move $a2, $v0			#Movemos a $a2 la dir del header de la lista
	sw $a2, LSerpiente		#Guardamos la dir del header en LSerpiente
	
	lw $a0, 4($sp)			#Epilogo
	lw $ra, 8($sp)
	lw $fp, 12($sp)
	addiu $sp , $sp, 12
			
	lw $a1, SCCabeza		#Cargamos en $a1 el color de la cabeza
	jal Colorear			#Con la dir en $a0 y el color en $a1 como argumentos, procedemos a colorearla celda


PintarMedio:					#Ciclo para pintar seccion del medio (3 caracteres)
	li $t0, 1
PintarMedio_loop:
	lw $a0, SCabezaY		#Cargamos las coordenadas X y Y de la cabeza, para pasarlas como argumentos
	lw $a1, SCabezaX
	add $a0, $a0, $t0		#Aumentaremos la coordenada Y de la cabeza, ya que iremos recorriendo el cuerpo en vertical
	jal AlinearDireccion		#Buscamos una direccion alineada con los argumentos guardados
	move $a0, $v0
	lw $a1, SCCola				#Cargamos el color de la cola en $a1
	jal Colorear				#Con la dir en $a0 y el color en $a1 como argumentos, podemos proceder a colorear la celda
	add $t0, $t0, 1
	bne $t0, 4, PintarMedio_loop		#Seguimos ciclando hasta que el contador llegue a 4
	
	
PintarCola:
	lw $a0, SColaY				#Cargamos las coordenadas X y Y de la cola, para pasarlas como argumentos
	lw $a1, SColaX
	jal AlinearDireccion			#Buscamos una direccion alineada con los argumentos guardados
	move $a0,$v0
	lw $a1, SCCola				#Cargamos el color de la cola en $a1
	jal Colorear				#Con la dir en $a0 y el color en $a1 como argumentos, podemos proceder a colorear la celda

#----------------------x-------------------------#
	#Ubicar Manzana en posicion inicial
#----------------------x-------------------------#

UbicarManzana:
	li $v0, 42
	li $a1 ,30			#Limite superior de manera de que no quede en el borde der (O proximamente, en el borde sup)
	addiu $a0, $a0, 1		#Ya que no podemos determinar el limite inferior, debemos asegurar que nunca quede en el borde iz.Ademas, no tomamos en consideracion valores neg
	sw $a0, ManzanaX		#Asignamos el num random a la coordenada X de la manzana
	syscall				#Llamamos nuevamente para generar numero random para la cordenada Y
	addiu $a0, $a0, 1		#Mismo caso anterior, aseguramos que no quede en el borde inferior
	sw $a0, ManzanaY
	
	
#----------------------x-------------------------#
	#Pintar Manzana en posicion inicial
#----------------------x-------------------------#
	
PintarManzana:
	lw $a0, ManzanaX		#Cargamos las coordenadas X y Y de la manzana, para pasarlas como argumentos
	lw $a1, ManzanaY

	jal AlinearDireccion		#Buscamos una direccion alineada con los argumentos guardados
	move $a0, $v0
	
	lw $t0, ($a0)			#Chequeamos si colisiona con la serpiente
	bnez $t0, UbicarManzana		#Si la dir dada es diferente a 0, quiere decir que choca con la serpiente (ya que ya nos aseguramos de que no ocurriera con las paredes)
					#Por lo tanto, buscamos una nueva direccion.
	lw $a1, CManzanas		#Cargamos en $a1 el color de la manzana
	
	jal Colorear			#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda (manzana)
	
	lw $s0, Inicio
	bnez $s0, ChequearColisiones_fin
	
	
###################################################
#********************Logica***********************#
###################################################

	li $a0, 1			#Cargamos 1 en $a0
	sw $a0, Inicio			#Cambiamos el valor de Inicio, para indicar que ya no estamos en el proceso de inicializacion del juego
main_game:


	jal ChequearInput		#Saltamos a chequear si hubo un input o no
	
	
	move $a0, $v0			#Movemos a $a0 la nueva o misma coord Y,dependiendo de si hubo un cambio de orientacio o no.	
	move $a1, $v1			#Movemos a $a1 la nueva o misma coord X,dependiendo de si hubo un cambio de orientacio o no.
	
	jal Mover_accion		#Saltamos a la funcion de movimiento
	jal Frame			#Saltamos al tiempo de espera de refrescamiento
	
	b main_game			#Empezamos nuevamente el ciclo del juego
		
########COSAS POR HACER#############
#0)Customizacion de dimensiones	
  
#7)Excepciones

#Extra
#1)Chequear Milestone
#2)Obstaculos
#3)Portales
#----------------------x-------------------------#
		#Funciones de finalizacion 
#----------------------x-------------------------#
FinJuego_Perdida:
	
	la $a0, MPerdida	#En caso de haber perdido, cargamos en $a0 la direccion del mensaje de perdida
	
FinJuego_Puntuacion:

	lw $a1, Puntuacion	#Cargamos la puntuacion final en $a1
	li $v0, 56		#Imprimimos mensaje correspondiente y puntuacion final
	syscall
	
	li $v0, 10		#Llamada a finalizar el programa
	syscall
	
FinJuego_Quit:
	la $a0, MQuit		#En caso de haber renunciado, cargamos en $a0 la direccion del mensaje de perdida
	b FinJuego_Puntuacion

FinJuego_Victoria:
	
	la $a0, MVictoria	#En caso de haber perdido, cargamos en $a0 la direccion del mensaje de perdida
	b FinJuego_Puntuacion
	
#----------------------x-------------------------#
		#Chequear inputs
#----------------------x-------------------------#

ChequearInput:

	addiu $sp, $sp, -8	#Prologo
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp , $sp, 8
	
	lui $a0, 0xffff		#Nos ubicamos en la direccion del control register
	lw $t0, 0($a0)
	andi $t0, $t0, 0x1					#Hacemos una mascara, con el fin de saber el valor del ultimo bit del register, quien indicara si esta listo o no
	beqz $t0, ChequearInput_fin_DireccionActual		#Si $t0 es igual a 0, significa que no hay ningun input nuevo, por lo que saltamos a proceso encargado de continuar la orientacion actual
	lw $v0, 4($a0)						#Si $t0 es dif de 0, cargamos el nuevo input en $v0
	move $a0, $v0						#Movemos el nuevo input para pasar como argumento
		
ChequearInput_fin:
	
	addiu $sp, $sp, -12 	#Prologo
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	addiu $fp , $sp, 12
	
	jal ObtenerCodigo	#Obtenemos el codigo del input en cuestion

	lw $a0, 4($sp)		#Epilogo
	lw $ra, 8($sp)
	lw $fp, 12($sp)
	addiu $sp , $sp, 12

	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra
	
ChequearInput_fin_DireccionActual:
	lw $a0, DireccionActual		#Cargamos en $a0 la direccion actual
	b ChequearInput_fin		#Procedemos a terminar el chequeo del input
	
#----------------------x-------------------------#
		#Movimientos
#----------------------x-------------------------#

Mover_accion:
	addiu $sp, $sp, -8	#Prologo
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp , $sp, 8
	
	move $t0, $a0		#Muevo a $t0 la coord en Y a donde voy
	move $t1, $a1		#Muevo a $t1 la coord X a donde voy
	
	lw $s0, SCabezaY	#Cargamos en $s0 la coord inicial en Y de la cabeza
	lw $s1, SCabezaX	#Cargamos en $s1 la coord inicial en X de la cabeza
	add $t2, $s0, $t0	#Sumo a la coord Y de la cabeza el cambio a realizar
	add $t3, $s1, $t1	#Sumo a la coord X de la cabeza el cambio a realizar
	sw $t2, SCabezaY	#Guardo la nueva coord Y que tendra la cabeza
	sw $t3, SCabezaX	#Guardo la nueva coord X que tendra la cabeza
	move $a0, $t2
	move $a1, $t3
	
	addiu $sp, $sp, -8	#Prologo
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp , $sp, 8
	
	jal AlinearDireccion	#Buscamos una direccion alineada con los argumentos guardados
	move $a0, $v0		#Movemos a $a0 nuestra nueva direccion, ya alineada
	
	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	addiu $sp, $sp, -20	#Prologo
	sw $fp, 20($sp)
	sw $ra,16($sp)
	sw $a0, 12($sp)
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	addiu $fp , $sp, 20
	
	jal ChequearColisiones	#Chequemoas la direccion obtenida, pasandola como argumento, para confirmar el curso de acciones a continuacion
	
	lw $t1, 4($sp)		#Epilogo
	lw $t0, 8($sp)
	lw $a0, 12($sp)
	lw $ra,16($sp)		
	lw $fp, 20($sp)
	addiu $sp, $sp , 20
	
	lw $s0 , LSerpiente	#Cargamos en $s0, el header de la lista
	lw $s1, ($s0)		#Cargamos la direccion del primero nodo (cabeza)
	lw $s2, 4($s0)		#Cargamos el tamano de la lista, para crear nuestro contador
	
	lw $s3, ($s1)		#Cargamos la direccion vieja del primer nodo/cabeza de la serpiente en $s3	
	sw $a0, ($s1)		#Actualizamos la dir de la cabeza con la direccion nueva
	
	lw $a1, SCCabeza	
	
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	
	add $s2, $s2, -1	#Restamos 1 al contador
	
	lw $s1, 4($s1)		#Cargamos en $s1 la dir del siguiente nodo
	move $a0, $s3		#Movemos a $a0, la dir vieja de la cabeza, que sera la dir nueva del siguiente nodo
			
Mover_accion_loop:
	beq $s2, 1,  Mover_accion_fin	#Cuando termine de actualizar las direcciones del cuerpo, procedera a actualizar a la cola
	lw $s3, ($s1)			#Cargamos la direccion vieja del nodo actual de la serpiente en $s3	
	sw $a0, ($s1)
	
	lw $a1, SCCola
	
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda
	move $a0, $s3		#Movemos a $a0 la direccion vieja del noo actual, que sera la nueva del proximo nodo
	
	lw $s1, 4($s1)		#Cargamos en $s1 la dir del siguiente nodo
	add $s2, $s2, -1	#Restamos 1 al contador
	b Mover_accion_loop

Mover_accion_fin:

	lw $s3, ($s1)		#Cargamos la direccion vieja de la cola de la serpiente en $s3	
	sw $a0, ($s1)		#Actualizamos la direccion de la cola
	
	lw $a1, SCCola
	
	jal Colorear		#Con la direccion en $a0 y el color en $a1 como argumentos, procedemos a colorear la celda (manzana)
	move $a0, $s3		#Movemos a $a0 la direccion vieja de la cola, que sera ahora el espacio vacio
	
	lw $a1, Negro		#Cargamos en $a1 el color a utilizar
	
	jal Colorear		#Con la dir en $a0 y el color en $a1 como argumentos, podemos proceder a colorear la celda
		
	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra

#----------------------x-------------------------#
		#Chequear Colisiones
#----------------------x-------------------------#

ChequearColisiones:

	addiu $sp, $sp, -16	#Prologo
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	addiu $fp , $sp, 16

	lw $s0, ($a0)					#Cargamos en $t0 el contenido de la direccion a verificar
	beqz $s0, ChequearColisiones_fin		#Verificamos si el espacio a moverse esta vacio
	lw $s1, SCCola					#Cargamos en $t1 el color de la cola.
	beq $s0, $s1, FinJuego_Perdida			#Verificamos si la cabeza colisiono con el cuerpo. De ser asi, salta a FinJuego
	lw $s1, CPared					#Cargamos en $t1 el color de  las paredes.
	beq $s0, $s1, FinJuego_Perdida			#Verificamos si la cabeza colisiono con una pared. De ser asi, salta a FinJuego
	lw $s1, CManzanas				#Cargamos en $t1 el color de las manzanas.
	beq $s0, $s1, IncrementarPuntuacion		#Verificamos si la cabeza colisiono con una manzana. De ser asi, salta a IncPuntuacion
	
ChequearColisiones_fin:

	lw $s1, 4($sp)		#Epilogo
	lw $s0, 8($sp)
	lw $ra, 12($sp)
	lw $fp, 16($sp)
	addiu $sp, $sp , 16
	
	jr $ra

#----------------------x-------------------------#
		#Actualizacion
#----------------------x-------------------------#
	
Frame:
	lw $s0, LSerpiente	#Cargo la dir de la lista en $s0
	lw $s1, 4($s0)		#Cargo el largo de la serpiente en $s1
	lw $s0, N		#Cargo en $s0 y en $s2 las dimensiones del tablero de juego
	lw $s2, M
	add $s0, $s0, -2	#Resto el borde, para solo trabajar con el area de juego
	add $s2, $s2, -2
	
	mul $s0, $s2, $s0			#Si el largo de la serpiente es igual al area de juego, procedemos a la secuencia de victoria. En caso contrario, seguimos.
	beq $s1 , $s0, FinJuego_Victoria
	
	lw $a0, SVelocidad	#Cargamos en #a0 el tiempo de sleep a utilizar en el syscall
	li $v0, 32		#Indicamos el codigo correspondiente para el syscall
	syscall			#Hacemos la llamada al sistema para ejecutar el sleep
	jr $ra

#######################x##########################
		#Funciones de ayuda
#######################x##########################

#----------------------x-------------------------#
		#Alineacion
#----------------------x-------------------------#

AlinearDireccion:
	lw $v0 , M		#Cargar el ancho de la pantalla en $v0
	mul $v0, $v0, $a0	#Nos movemos por el tablero, desplazandonos casilla por casilla hasta conseguir la fila deseada (Posicion y)
	add $v0, $v0, $a1	#Sumamos la coordenada x, para ubicarnos en la columna deseada (Posicion x)
	mul $v0, $v0, 4		#Finalmente, multiplicamos por 4 para obtener la casilla en cuestion, que cumple con ambas coordenadas
	add $v0, $v0, $gp	#Ahora,guardamos la direccion deseada, tomando a $gp como referencia
	jr $ra

#----------------------x-------------------------#
		#Coloreo
#----------------------x-------------------------#	
	
Colorear:
	sw $a1, ($a0)		#Colocamos el color en el pixel
	jr $ra
#----------------------x-------------------------#
		#Incremento de puntuacion
#----------------------x-------------------------#

IncrementarPuntuacion:
	
	lw $s0, Aumentopuntos	#Cargo los puntos a aumentar en $s0
	lw $s1, Puntuacion	#Cargo en $s1, la puntuacion actual
	add $s1, $s1, $s0	#Actualizo la puntuacion, sumando la puntuacion actual + los puntos a aumentar
	#chequear metas
	sw $s1, Puntuacion	#Guardo la nueva puntuacion como puntuacion actual.
	
	lw $s0, LSerpiente		#Cargamos la dir de la lista en $s0
	lw $s1, DireccionActual		#Cargamos en $s1 la direccion actual
	lw $s2, 8($s0)			#Buscamos la direccion actual de la cola
	
	beq $s1, 119 , IncrementarCola_W	#Verificamos la direccion actual de la serpiente para saber cuanto aumentar/disminuir para agregar correctamente
	beq $s1, 115 , IncrementarCola_A	#el nuevo nodo (aumentar longitud)
	beq $s1, 97 , IncrementarCola_S
	beq $s1, 100 , IncrementarCola_D 
	
IncrementarCola_W:
	lw $t0, ($s2)		#Valor actual de la cola
	add $t0, $t0, 128	#Aumentamos/disminuimos lo suficiente como para quedar en la direccion contraria
	
	b IncrementarCola_Fin
	
IncrementarCola_A:
	lw $t0, ($s2)		#Valor actual de la cola
	add $t0, $t0, 4		#Aumentamos/disminuimos lo suficiente como para quedar en la direccion contraria
	
	b IncrementarCola_Fin
	
IncrementarCola_S:

	lw $t0, ($s2)		#Valor actual de la cola
	add $t0, $t0, -128	#Aumentamos/disminuimos lo suficiente como para quedar en la direccion contraria
	
	b IncrementarCola_Fin
	
IncrementarCola_D:

	lw $t0, ($s2)		#Valor actual de la cola
	add $t0, $t0, -4	#Aumentamos/disminuimos lo suficiente como para quedar en la direccion contraria
	
IncrementarCola_Fin:

	move $a0, $s0
	move $a1, $t0
	
	addiu $sp, $sp, -12 	#Prologo
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	sw $t0, 4($sp)
	addiu $fp , $sp, 12
	
	jal list_insertar	#Con la direccion de la lista y el valor del nuevo nodo (direccion) como argumentos, procedemos a insertar el nodo en la lista
	
	lw $t0, 4($sp)		#Epilogo
	lw $ra, 8($sp)
	lw $fp, 12($sp)
	addiu $sp , $sp, 12
	
	move $a0, $t0			#Cargamos en $a0 la dir del nuevo nodo
	lw $a1, SCCola			#Cargams en $a1 el color de la cola para pasar como argumento
					
	jal Colorear			#Con la dir en $a0 y el color en $a1 como argumentos, procedemos a colorearla celda
		
	b UbicarManzana
	
#----------------------x-------------------------#
		#Obtencion de codigos
#----------------------x-------------------------#

ObtenerCodigo:

	addiu $sp, $sp, -8	#Prologo
	sw $fp, 8($sp)
	sw $ra, 4($sp)
	addiu $fp , $sp, 8
	
	move $t0, $a0
	
ObtenerCodigo_Comparacion:		#Verificamos el asciiz del input recibido

	beq $t0, 119, ObtenerCodigo_W
	beq $t0, 115, ObtenerCodigo_S
	beq $t0, 97, ObtenerCodigo_A
	beq $t0, 100, ObtenerCodigo_D
	beq $t0, 112, ObtenerCodigo_P
	beq $t0, 113, FinJuego_Quit
	
ObtenerCodigo_SeguirIgual:		#Si no es ninguno de los inputs validos, la serpiente seguira igual, ignorando el input
	lw $t0, DireccionActual		#Cargaremos en $t0 la dir actual
	b ObtenerCodigo_Comparacion	#Volveremos a comparar, ahora sabiendo que el codigo sera la misma direccion actual
	
	
ObtenerCodigo_W:		#La serpiente va hacia arriba
	
	lw $s0 , DireccionActual			#Cargamos en $s0 la direccion actual
	beq $s0, 115, ObtenerCodigo_SeguirIgual		#Verificamos que la dirActual y el input recibido no sean contrarios, de manera de que no se atraviese a si misma
	
	li $s0, 119				#Cargamos en $s0 el codigo ascii/direccion actual
	sw $s0 , DireccionActual		#Actualizamos la direccion actual
	
	li $v0,	-1		#Cambio a ejecutar en la coordenada Y
	li $v1,	0		#Cambio a ejecutar en la coordenada X
	
	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra
	
ObtenerCodigo_S:		#La serpiente va hacia abajo

	lw $s0 , DireccionActual			#Cargamos en $s0 la direccion actual
	beq $s0, 119, ObtenerCodigo_SeguirIgual		#Verificamos que la dirActual y el input recibido no sean contrarios, de manera de que no se atraviese a si misma

	li $s0, 115		#Cargamos en $s0 el codigo ascii/direccion actual
	sw $s0, DireccionActual		#Actualizamos la direccion actual
	
	li $v0,	1		#Cambio a ejecutar en la coordenada Y
	li $v1,	0		#Cambio a ejecutar en la coordenada X
	
	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra
	
ObtenerCodigo_A:		#La serpiente va hacia la izquierda

	lw $s0 , DireccionActual			#Cargamos en $s0 la direccion actual
	beq $s0, 100, ObtenerCodigo_SeguirIgual		#Verificamos que la dirActual y el input recibido no sean contrarios, de manera de que no se atraviese a si misma
	
	li $s0, 97		#Cargamos en $s0 el codigo ascii/direccion actual
	sw $s0, DireccionActual		#Actualizamos la direccion actual
	
	li $v0,	0		#Cambio a ejecutar en la coordenada Y
	li $v1,	-1		#Cambio a ejecutar en la coordenada X

	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra
	
ObtenerCodigo_D:		#La serpiente va hacia la derecha

	lw $s0 , DireccionActual			#Cargamos en $s0 la direccion actual
	beq $s0, 97, ObtenerCodigo_SeguirIgual		#Verificamos que la dirActual y el input recibido no sean contrarios, de manera de que no se atraviese a si misma
	
	li $s0, 100		#Cargamos en $s0 el codigo ascii/direccion actual
	sw $s0, DireccionActual		#Actualizamos la direccion actual
	
	li $v0,	0		#Cambio a ejecutar en la coordenada Y
	li $v1,	1		#Cambio a ejecutar en la coordenada X

	lw $ra, 4($sp)		#Epilogo
	lw $fp, 8($sp)
	addiu $sp, $sp , 8
	
	jr $ra
	
ObtenerCodigo_P:

	lw $a0, SVelocidad	#Cargamos en $a0 la velocidad de actualizacion de nuestro juego
	li $v0, 32		#Indicamos el codigo correspondiente para el syscall
	syscall			#Hacemos la llamada al sistema para ejecutar el sleep
	
	lui $a3, 0xffff		#Nos ubicamos en la direccion del control register
	
ObtenerCodigo_P_loop:
	
	lw $t1, 0($a3)
	andi $t1, $t1, 0x1			#Hacemos una mascara, con el fin de saber el valor del ultimo bit del register, quien indicara si esta listo o no
	beqz $t1, ObtenerCodigo_P_loop		#Verificamos si se ha introducido algun nuevo input. De no ser asi, seguimos ciclando, en espera de alguna entrada
	
	lw $t2, 4($a3)				#Cargamos el nuevo input en $t2		
	bne $t2, 112, ObtenerCodigo_P_loop	#Si conseguimos un input, verificamos que sea una p, de manera de desactivar la pausa del juego. Si no, seguimos ciclando
	
	b ObtenerCodigo_SeguirIgual		#Al obtener una p, vamos al proceso que permite continuar el juego, manteniendo la orientacion actual de la serpiente


.include "TadLista.s"	
	
