library(logger)

# Formateador de logger con soporte para interpolación de variables {glue}
log_formatter(formatter_glue)

directorio_month <- file.path(directorio_cohorts, "month")
directorio_excluir_fechas <- file.path(directorio_month, "excluir_fechas")

ficheros <- list.files(
  path = directorio_month,
  pattern = "\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

ficheros_exc_fechas <- list.files(
  path = directorio_excluir_fechas,
  pattern = "\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

if (length(ficheros) == 0) {
  stop("¡ADVERTENCIA! No se encontraron ficheros .sql en el directorio: ", directorio_month)
}

ficheros_ordenados <- sort(ficheros)
ficheros_ordenados_exc_fechas <- sort(ficheros_exc_fechas)

# Diccionario descriptivo de los scripts en la carpeta month
nombres_scripts <- c(
  "15_cirugia_programada_cohort.sql"          = "Cirugía Programada (Cohorte)",
  "17_cirugia_oncologica_cohort.sql"          = "Cirugía Oncológica (Cohorte)",
  "19_cirugia_urgente_cohort.sql"             = "Cirugía Urgente (Cohorte)",
  "21_proceso_medico_cohort.sql"              = "Proceso Médico (Cohorte)",
  "23_complications_readmission.sql"          = "Complicaciones y Reingresos",
  "16_cirugia_programada_log_exclusion.sql"   = "Auditando exclusiones - Cirugía Programada",
  "18_cirugia_oncologica_log_exclusion.sql"   = "Auditando exclusiones - Cirugía Oncológica",
  "20_cirugia_urgente_log_exclusion.sql"      = "Auditando exclusiones - Cirugía Urgente",
  "22_proceso_medico_log_exclusion.sql"       = "Auditando exclusiones - Proceso Médico"
)

# Diccionario con el criterio de ventana temporal de Hb por cada tipo de proceso / fichero
criterios_hb_proceso <- c(
  "16_cirugia_programada_log_exclusion.sql" = "analítica de Hemoglobina entre 0 y 120 días antes de la fecha de intervención (Cirugía Programada)",
  "18_cirugia_oncologica_log_exclusion.sql" = "analítica de Hemoglobina entre 0 y 90 días antes de la fecha de intervención (Cirugía Oncológica)",
  "20_cirugia_urgente_log_exclusion.sql"    = "analítica de Hemoglobina entre 0 y 5 días antes de la fecha de intervención (Cirugía Urgente)",
  "22_proceso_medico_log_exclusion.sql"     = "analítica de Hemoglobina entre 0 y 5 días antes de la fecha de ingreso (Proceso Médico)"
)

log_info("==========================================================================")
log_info(" INICIO DEL PROCESAMIENTO DE COHORTES")
log_info("==========================================================================")

for (fichero_path in ficheros_ordenados) {
  
  nombre_fichero <- basename(fichero_path)
  script_desc <- nombres_scripts[[nombre_fichero]] %||% nombre_fichero
  
  log_info("--------------------------------------------------------------------------")
  log_info("[+] EJECUTANDO: {script_desc}")
  log_info("    Fichero: {nombre_fichero}")
  log_info("--------------------------------------------------------------------------")

  tryCatch({
    
    sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
    
    # Si es un script de log de exclusión, recuperamos el resultado directamente con dbGetQuery
    if (grepl("_log_exclusion\\.sql$", nombre_fichero)) {
      
      criterio_hb <- criterios_hb_proceso[[nombre_fichero]] %||% "analítica de Hemoglobina en el rango preoperatorio definido"
      log_info("  |--> Criterio aplicado: Se evalúa {criterio_hb}")
      
      # Ejecutar la consulta SELECT del archivo y obtener el data.frame directamente
      df_log <- dbGetQuery(con, sql_script)
      
      log_info("  |--> Desglose del número de registros excluidos por subcohorte:")
      
      for (i in seq_len(nrow(df_log))) {
        coh   <- df_log$cohort[i]
        n_ini <- format(df_log$n_registros_inicial[i], big.mark = ",")
        n_fin <- format(df_log$n_registros[i], big.mark = ",")
        n_exc <- format(df_log$registros_excluidos[i], big.mark = ",")
        
        log_info("      • [{coh}] Iniciales: {n_ini} | Excluidos: {n_exc} | Retenidos con Hb válida: {n_fin}")
      }
      
      log_info("  [✓] REGISTRO DE EXCLUSIONES COMPLETADO")
      
    } else {
      # Ficheros estándar de cohorte que crean o modifican tablas (CREATE/INSERT)
      resultado <- dbExecute(con, sql_script)
      resultado_fmt <- format(resultado, big.mark = ",")
      log_info("  [✓] PROCESO COMPLETADO. Filas afectadas: {resultado_fmt}")
    }

  }, error = function(e) {
    log_error("  [X] ERROR al ejecutar el fichero {nombre_fichero}: {conditionMessage(e)}")
  })
}

# ==============================================================================
# PROCESAMIENTO DE EXCLUSIONES DE FECHAS INCOMPLETAS (EXCLUIR_FECHAS)
# ==============================================================================
log_info("==========================================================================")
log_info(" INICIO DE FILTRADO POR FECHAS COMPLETAS (EXCLUIR_FECHAS)")
log_info("==========================================================================")

# Lista de ficheros que no deben generar mensajes de log_info
ficheros_sin_log <- c(
  "1_episodios_validos_intervencion.sql",
  "2_episodios_validos_admision_alta.sql",
  "7_borrar_tablas.sql"
)

for (fichero_path_exc in ficheros_ordenados_exc_fechas) {
  
  nombre_fichero_exc <- basename(fichero_path_exc)
  
  # Verificar si el archivo actual debe silenciarse
  mostrar_log <- !(nombre_fichero_exc %in% ficheros_sin_log)
  
  if (mostrar_log) {
    # Determinar descripción y criterio según el script
    if (grepl("6_exclusion_proceso_medico_cohort\\.sql$", nombre_fichero_exc)) {
      criterio_desc <- "Reteniendo únicamente episodios con fecha de admisión y alta completas (hora, minuto y segundo distinto de 00:00:00)"
    } else {
      criterio_desc <- "Reteniendo únicamente episodios con fecha de inicio y fin de intervención completas (hora, minuto y segundo distinto de 00:00:00)"
    }
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] APLICANDO FILTRO DE FECHAS: {nombre_fichero_exc}")
    log_info("    Criterio: {criterio_desc}")
    log_info("--------------------------------------------------------------------------")
  }
  
  tryCatch({
    
    sql_script_exc <- readChar(fichero_path_exc, file.info(fichero_path_exc)$size)
    resultado <- dbExecute(con, sql_script_exc)
    
    if (mostrar_log) {
      resultado_fmt <- format(resultado, big.mark = ",")
      log_info("  [✓] FILTRADO DE FECHAS COMPLETADO. Registros retenidos: {resultado_fmt}")
    }
    
  }, error = function(e) {
    log_error("  [X] ERROR al ejecutar el fichero de exclusión de fechas {nombre_fichero_exc}: {conditionMessage(e)}")
  })
}