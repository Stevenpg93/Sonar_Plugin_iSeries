      *****************************************************************
      * PROCESO - Procesamiento batch de transacciones
      * Función: Procesar transacciones diarias del banco
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROCESO.
       AUTHOR. EQUIPO-CORE-BANKING.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANSACCION-FILE ASSIGN TO TRANSAC
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  TRANSACCION-FILE.
       01  TRANSACCION-RECORD.
           05  TRX-ID              PIC 9(15).
           05  TRX-FECHA           PIC 9(08).
           05  TRX-TIPO            PIC X(03).
      *> POLA: Agregar TRX-CANAL (WEB, APP, CAJERO)
           05  TRX-MONTO           PIC S9(11)V99 COMP-3.
           05  TRX-CUENTA-ORIGEN   PIC 9(12).
           05  TRX-CUENTA-DESTINO  PIC 9(12).
       
       WORKING-STORAGE SECTION.
       01  WS-EOF                  PIC X VALUE 'N'.
           88  EOF                 VALUE 'Y'.
       01  WS-CONTADOR             PIC 9(07) VALUE ZERO.
       01  WS-TOTAL-MONTO          PIC S9(13)V99 COMP-3 VALUE ZERO.
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INICIALIZAR
           PERFORM PROCESAR-ARCHIVO
               UNTIL EOF
           PERFORM FINALIZAR
           STOP RUN.
       
       INICIALIZAR.
           OPEN INPUT TRANSACCION-FILE
           DISPLAY "*** INICIO PROCESO BATCH ***"
      * POLA: Registrar fecha y hora de inicio en log
           .
       
       PROCESAR-ARCHIVO.
           READ TRANSACCION-FILE
               AT END
                   SET EOF TO TRUE
               NOT AT END
                   PERFORM VALIDAR-TRANSACCION
           END-READ.
       
       VALIDAR-TRANSACCION.
           ADD 1 TO WS-CONTADOR
           
           IF TRX-MONTO > 0
               ADD TRX-MONTO TO WS-TOTAL-MONTO
               PERFORM APLICAR-TRANSACCION
           ELSE
      * POLA Enviar alerta de monto inválido
               DISPLAY "Advertencia: TRX " TRX-ID " con monto cero"
           END-IF.
       
       APLICAR-TRANSACCION.
      *> POLA: Implementar rollback en caso de error
           DISPLAY "Procesando TRX: " TRX-ID.
       
       FINALIZAR.
           CLOSE TRANSACCION-FILE
           DISPLAY "Transacciones procesadas: " WS-CONTADOR
           DISPLAY "Monto total: " WS-TOTAL-MONTO
           DISPLAY "*** FIN PROCESO BATCH ***".
