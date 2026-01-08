package com.example.sonar.todo;

import org.sonar.api.config.Configuration;
import org.sonar.api.resources.AbstractLanguage;

/**
 * Define el lenguaje COBOL para SonarQube.
 * Permite que archivos .CBL, .cbl, .COB, .cob sean reconocidos como COBOL.
 */
public class CobolLanguage extends AbstractLanguage {
  
  public static final String KEY = "cobol";
  public static final String NAME = "COBOL";
  
  // Sufijos de archivo por defecto
  public static final String DEFAULT_FILE_SUFFIXES = ".cbl,.CBL,.cob,.COB";
  
  // Propiedad de configuración para sufijos personalizados
  public static final String FILE_SUFFIXES_KEY = "sonar.cobol.file.suffixes";
  
  private final Configuration configuration;
  
  public CobolLanguage(Configuration configuration) {
    super(KEY, NAME);
    this.configuration = configuration;
  }
  
  @Override
  public String[] getFileSuffixes() {
    String[] suffixes = configuration.getStringArray(FILE_SUFFIXES_KEY);
    if (suffixes == null || suffixes.length == 0) {
      suffixes = DEFAULT_FILE_SUFFIXES.split(",");
    }
    return suffixes;
  }
}
