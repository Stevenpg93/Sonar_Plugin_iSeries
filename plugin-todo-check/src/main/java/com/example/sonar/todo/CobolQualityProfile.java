package com.example.sonar.todo;

import org.sonar.api.server.profile.BuiltInQualityProfilesDefinition;

/**
 * Define el perfil de calidad built-in para COBOL.
 * SonarQube requiere que cada lenguaje tenga al menos un perfil de calidad.
 */
public class CobolQualityProfile implements BuiltInQualityProfilesDefinition {
  
  @Override
  public void define(Context context) {
    // Crear el perfil "Sonar way" para COBOL
    NewBuiltInQualityProfile profile = context.createBuiltInQualityProfile(
      "Sonar way",  // Nombre del perfil
      CobolLanguage.KEY  // Lenguaje COBOL
    );
    
    profile.setDefault(true);  // Establecer como perfil por defecto
    
    // Activar la regla de POLA para COBOL
    profile.activateRule(
      TodoRulesDefinition.REPOSITORY_KEY + "-" + CobolLanguage.KEY,
      "pola-comment"
    );
    
    profile.done();
  }
}
