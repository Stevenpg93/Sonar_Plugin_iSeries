      *****************************************************************
      * CONSULTA - Programa de consulta de información
      * Propósito: Consultar datos de clientes y productos
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONSULTA.
       AUTHOR. DESARROLLO-BANCOLOMBIA.
       DATE-WRITTEN. 15/12/2025.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENTE-FILE ASSIGN TO CLIENTES
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CLI-ID.
       
       DATA DIVISION.
       FILE SECTION.
       FD  CLIENTE-FILE.
       01  CLIENTE-RECORD.
           05  CLI-ID              PIC 9(10).
           05  CLI-NOMBRE          PIC X(60).
      * POLA: Añadir CLI-TELEFONO para contacto
           05  CLI-SALDO           PIC S9(13)V99 COMP-3.
           05  CLI-TIPO            PIC X(01).
               88  CLI-EMPRESARIAL VALUE 'E'.
               88  CLI-PERSONAL    VALUE 'P'.
       
       WORKING-STORAGE SECTION.
       01  WS-STATUS-CODE          PIC X(02).
       01  WS-CLIENTE-ID           PIC 9(10).
       01  WS-SALDO-FORMATO        PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       
      *> POLA: Implementar búsqueda por nombre parcial
       
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           DISPLAY "=== SISTEMA DE CONSULTA ==="
           PERFORM ABRIR-ARCHIVOS
           PERFORM PROCESAR-CONSULTA
           PERFORM CERRAR-ARCHIVOS
           STOP RUN.
       
       ABRIR-ARCHIVOS.
           OPEN INPUT CLIENTE-FILE
           IF WS-STATUS-CODE NOT = '00'
               DISPLAY "ERROR ABRIENDO ARCHIVO"
               STOP RUN
           END-IF.
       
       PROCESAR-CONSULTA.
      * POLA Agregar validación de usuario autorizado
           DISPLAY "Ingrese ID de cliente: "
           ACCEPT WS-CLIENTE-ID
           MOVE WS-CLIENTE-ID TO CLI-ID
           READ CLIENTE-FILE
               INVALID KEY
                   DISPLAY "Cliente no encontrado"
               NOT INVALID KEY
                   PERFORM MOSTRAR-CLIENTE
           END-READ.
       
       MOSTRAR-CLIENTE.
           DISPLAY "ID: " CLI-ID
           DISPLAY "Nombre: " CLI-NOMBRE
           MOVE CLI-SALDO TO WS-SALDO-FORMATO
           DISPLAY "Saldo: $" WS-SALDO-FORMATO
           IF CLI-EMPRESARIAL
               DISPLAY "Tipo: EMPRESARIAL"
           ELSE
               DISPLAY "Tipo: PERSONAL"
           END-IF.
       
       CERRAR-ARCHIVOS.
           CLOSE CLIENTE-FILE.
