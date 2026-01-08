package com.example.sonar.todo;

import org.sonar.api.rule.RuleKey;
import org.sonar.api.rule.Severity;
import org.sonar.api.rules.RuleType;
import org.sonar.api.server.rule.RulesDefinition;

public class TodoRulesDefinition implements RulesDefinition {
  public static final String REPOSITORY_KEY = "todo-check";
  // Soportamos múltiples lenguajes
  public static final String RPGLE_LANGUAGE_KEY = "rpgle";
  public static final String COBOL_LANGUAGE_KEY = "cobol";
  public static final RuleKey TODO_RULE_KEY = RuleKey.of(REPOSITORY_KEY, "pola-comment");

  @Override
  public void define(Context context) {
    // Crear repositorio para RPGLE
    createRepository(context, RPGLE_LANGUAGE_KEY);
    // Crear repositorio para COBOL
    createRepository(context, COBOL_LANGUAGE_KEY);
  }

  private void createRepository(Context context, String languageKey) {
    NewRepository repository = context
      .createRepository(REPOSITORY_KEY + "-" + languageKey, languageKey)
      .setName("POLA Check Rules " + languageKey.toUpperCase());

    NewRule polaRule = repository
      .createRule("pola-comment")
      .setName("Evitar comentarios POLA")
      .setHtmlDescription(
        "<p>Los comentarios <code>POLA</code> indican trabajo incompleto o pendiente que debe abordarse.</p>" +
        "<h2>¿Por qué es esto un problema?</h2>" +
        "<p>Los comentarios POLA pueden acumularse y perderse en el código, indicando:</p>" +
        "<ul>" +
        "  <li>Funcionalidad incompleta que podría causar errores</li>" +
        "  <li>Optimizaciones pendientes que afectan el rendimiento</li>" +
        "  <li>Deuda técnica que aumenta con el tiempo</li>" +
        "</ul>" +
        "<h2>¿Cómo solucionarlo?</h2>" +
        "<p>Considera estas alternativas:</p>" +
        "<ol>" +
        "  <li>Completa la tarea pendiente inmediatamente</li>" +
        "  <li>Crea un ticket/issue en tu sistema de seguimiento</li>" +
        "  <li>Elimina el comentario si ya no es relevante</li>" +
        "  <li>Si es necesario mantenerlo, documenta por qué y cuándo se abordará</li>" +
        "</ol>"
      )
      .setSeverity(Severity.MINOR)
      .setType(RuleType.CODE_SMELL)
      // Tags para categorización (mejora la búsqueda y filtrado)
      .addTags("bad-practice", "convention", "pitfall")
      // Gap description para estimación de esfuerzo
      .setGapDescription("Revisa y resuelve el comentario POLA");
    
    // Función de remediación: tiempo constante por issue (deuda técnica cuantificable)
    polaRule.setDebtRemediationFunction(
      polaRule.debtRemediationFunctions().constantPerIssue("5min")
    );

    repository.done();
  }
}
