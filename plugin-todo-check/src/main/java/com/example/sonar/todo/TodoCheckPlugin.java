package com.example.sonar.todo;

import org.sonar.api.Plugin;

public class TodoCheckPlugin implements Plugin {
  @Override
  public void define(Context context) {
    // Registrar el lenguaje COBOL
    context.addExtension(CobolLanguage.class);
    
    // Registrar el perfil de calidad para COBOL
    context.addExtension(CobolQualityProfile.class);
    
    // Registrar las reglas y el sensor
    context.addExtensions(
      TodoRulesDefinition.class,
      TodoSensor.class
    );
  }
}
