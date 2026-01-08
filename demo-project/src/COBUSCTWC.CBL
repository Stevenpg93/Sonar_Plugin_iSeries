      *****************************************************************
      * COBUSCTWC - Programa de ejemplo COBOL
      * Sistema: Demo SonarQube Plugin
      * Descripción: Consulta de usuarios y transacciones
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBUSCTWC.
       AUTHOR. EQUIPO-DESARROLLO.
       DATE-WRITTEN. 15/12/2025.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT USUARIO-FILE ASSIGN TO USUARIOS
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS USU-ID
               FILE STATUS IS WS-FILE-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD  USUARIO-FILE.
       01  USUARIO-RECORD.
           05  USU-ID              PIC 9(10).
           05  USU-NOMBRE          PIC X(50).
           05  USU-DOCUMENTO       PIC X(20).
      * POLA: Agregar campo USU-EMAIL para notificaciones
           05  USU-ESTADO          PIC X(01).
               88  USU-ACTIVO      VALUE 'A'.
               88  USU-INACTIVO    VALUE 'I'.
           05  USU-FECHA-ALTA      PIC 9(08).
       
       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC X(02).
           88  WS-FILE-OK          VALUE '00'.
           88  WS-FILE-EOF         VALUE '10'.
           88  WS-FILE-NOT-FOUND   VALUE '23'.
       
       01  WS-CONTADORES.
           05  WS-TOTAL-USUARIOS   PIC 9(05) VALUE ZEROS.
           05  WS-USUARIOS-ACTIVOS PIC 9(05) VALUE ZEROS.
      *> POLA: Implementar contador de usuarios bloqueados
       
       01  WS-VARIABLES-TRABAJO.
           05  WS-USUARIO-ID       PIC 9(10).
           05  WS-RESPUESTA        PIC X(01).
           05  WS-MENSAJE          PIC X(80).
       
       PROCEDURE DIVISION.
       MAIN-PROCESS.
           PERFORM INICIALIZAR
           PERFORM PROCESAR-USUARIOS
           PERFORM FINALIZAR
           STOP RUN.
       
       INICIALIZAR.
      * POLA: Agregar validación de parámetros de entrada
           DISPLAY "*** INICIO PROGRAMA COBUSCTWC ***"
           OPEN INPUT USUARIO-FILE
           IF NOT WS-FILE-OK
               DISPLAY "ERROR AL ABRIR ARCHIVO DE USUARIOS"
               DISPLAY "STATUS: " WS-FILE-STATUS
               STOP RUN
           END-IF.
       
       PROCESAR-USUARIOS.
           PERFORM UNTIL WS-FILE-EOF
               READ USUARIO-FILE
                   AT END
                       SET WS-FILE-EOF TO TRUE
                   NOT AT END
                       PERFORM ANALIZAR-USUARIO
               END-READ
           END-PERFORM
           PERFORM MOSTRAR-ESTADISTICAS.
       
       ANALIZAR-USUARIO.
           ADD 1 TO WS-TOTAL-USUARIOS
           IF USU-ACTIVO
               ADD 1 TO WS-USUARIOS-ACTIVOS
               PERFORM VALIDAR-DATOS-USUARIO
      * POLA Verificar transacciones pendientes del usuario
           ELSE
               DISPLAY "Usuario inactivo: " USU-ID
           END-IF.
       
       VALIDAR-DATOS-USUARIO.
      *> POLA: Validar formato de documento según tipo
           IF USU-DOCUMENTO = SPACES
               DISPLAY "ADVERTENCIA: Usuario " USU-ID 
                       " sin documento"
           END-IF
           
           IF USU-NOMBRE = SPACES
               DISPLAY "ERROR: Usuario " USU-ID " sin nombre"
           END-IF.
       
       MOSTRAR-ESTADISTICAS.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "ESTADÍSTICAS DEL PROCESO"
           DISPLAY "========================================="
           DISPLAY "Total usuarios procesados: " 
                   WS-TOTAL-USUARIOS
           DISPLAY "Usuarios activos: " WS-USUARIOS-ACTIVOS
           DISPLAY "=========================================".
       
       FINALIZAR.
           CLOSE USUARIO-FILE
           DISPLAY "*** FIN PROGRAMA COBUSCTWC ***".
