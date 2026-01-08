package com.example.sonar.todo;

import java.io.IOException;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.sonar.api.batch.fs.FileSystem;
import org.sonar.api.batch.fs.FilePredicates;
import org.sonar.api.batch.fs.InputFile;
import org.sonar.api.batch.fs.InputFile.Type;
import org.sonar.api.batch.sensor.Sensor;
import org.sonar.api.batch.sensor.SensorContext;
import org.sonar.api.batch.sensor.SensorDescriptor;
import org.sonar.api.batch.sensor.issue.NewIssue;
import org.sonar.api.batch.sensor.issue.NewIssueLocation;
import org.sonar.api.rule.RuleKey;
import org.sonar.api.utils.log.Logger;
import org.sonar.api.utils.log.Loggers;

public class TodoSensor implements Sensor {
  private static final Logger LOG = Loggers.get(TodoSensor.class);
  
  // Patrón regex mejorado para detectar POLA en comentarios
  // COBOL: * POLA (en columna 7), *> POLA (comentario libre)
  private static final Pattern TODO_PATTERN = Pattern.compile(
    "(?://|/\\*\\*?|\\*>?|#)\\s*POLA\\b",
    Pattern.CASE_INSENSITIVE
  );

  @Override
  public void describe(SensorDescriptor descriptor) {
    descriptor
      .name("POLA Check Sensor")
      // NO especificar lenguaje para que funcione con todos
      // Solo ejecutar en archivos de tipo MAIN (no TEST)
      .onlyOnFileType(Type.MAIN);
  }

  @Override
  public void execute(SensorContext context) {
    FileSystem fileSystem = context.fileSystem();
    FilePredicates predicates = fileSystem.predicates();

    // Buscar archivos RPGLE y COBOL
    Iterable<InputFile> inputFiles = fileSystem.inputFiles(
      predicates.and(
        predicates.or(
          predicates.hasLanguage(TodoRulesDefinition.RPGLE_LANGUAGE_KEY),
          predicates.hasLanguage(TodoRulesDefinition.COBOL_LANGUAGE_KEY)
        ),
        predicates.hasType(Type.MAIN)
      )
    );

    int totalIssues = 0;
    int filesAnalyzed = 0;
    
    for (InputFile inputFile : inputFiles) {
      try {
        filesAnalyzed++;
        String[] lines = inputFile.contents().split("\\R", -1);
        
        for (int i = 0; i < lines.length; i++) {
          Matcher matcher = TODO_PATTERN.matcher(lines[i]);
          if (matcher.find()) {
            createIssue(context, inputFile, i + 1, lines[i].trim());
            totalIssues++;
          }
        }
      } catch (IOException e) {
        LOG.warn("No se pudo leer el archivo: {}. Razón: {}", 
                 inputFile.filename(), e.getMessage());
      }
    }
    
    LOG.info("POLA Check: Analizados {} archivos, encontrados {} POLAs", 
             filesAnalyzed, totalIssues);
  }

  private static void createIssue(SensorContext context, InputFile inputFile, 
                                  int line, String lineContent) {
    String language = inputFile.language();
    RuleKey ruleKey = RuleKey.of(
      TodoRulesDefinition.REPOSITORY_KEY + "-" + language, 
      "pola-comment"
    );

    NewIssue newIssue = context.newIssue().forRule(ruleKey);
    
    // Extraer el contenido del POLA para un mensaje más informativo
    String todoMessage = extractTodoMessage(lineContent);
    String message = todoMessage.isEmpty() 
      ? "Se encontró POLA: elimina o justifica esta marca."
      : "Se encontró POLA: " + todoMessage;

    NewIssueLocation location = newIssue
      .newLocation()
      .on(inputFile)
      .at(inputFile.selectLine(line))
      .message(message);

    newIssue.at(location);
    newIssue.save();
  }
  
  /**
   * Extrae el texto después del POLA para proporcionar contexto
   */
  private static String extractTodoMessage(String lineContent) {
    int todoIndex = lineContent.toUpperCase().indexOf("POLA");
    if (todoIndex >= 0) {
      String afterTodo = lineContent.substring(todoIndex + 4).trim();
      // Remover caracteres comunes de comentarios al inicio
      afterTodo = afterTodo.replaceFirst("^[:;\\-\\s]+", "");
      // Limitar longitud para no saturar el mensaje
      if (afterTodo.length() > 80) {
        afterTodo = afterTodo.substring(0, 77) + "...";
      }
      return afterTodo;
    }
    return "";
  }
}
