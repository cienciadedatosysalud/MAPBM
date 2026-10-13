

ficheros <- list.files(
  path = directorio_cohorts,
  pattern = "\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

ficheros_exclusion <- list.files(
  path = directorio_cohorts,
  pattern = "^exclusion_1.*\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

ficheros_exclusion_tablas <- list.files(
  path = directorio_cohorts,
  pattern = "^exclusion_entity_.*\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

if (length(ficheros) == 0) {
  stop("¡ADVERTENCIA! No se encontraron ficheros .sql en el directorio: ", directorio_cohorts)
}

ficheros_ordenados <- sort(ficheros)
patron <- "(?i)CREATE\\s+(?:OR\\s+REPLACE\\s+)?TABLE\\s+([a-zA-Z0-9_\\.\"]+)"

log_info("==========================================================================")
log_info(" INICIO DEL PROCESAMIENTO DE COHORTES Y CRITERIOS DE EXCLUSIÓN")
log_info("==========================================================================")

for (fichero_path in ficheros_ordenados) {
  
  nombre_fichero <- basename(fichero_path)
  
  if (startsWith(nombre_fichero, "exclusion_")) {
    #log_info("  [i] Omitiendo fichero de exclusión en bucle principal: {nombre_fichero}")
    next 
  }
  
  sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
  coincidencia <- regexec(patron, sql_script, perl = TRUE)
  captura <- regmatches(sql_script, coincidencia)
  nombre_tabla <- if (length(captura[[1]]) > 1) captura[[1]][2] else "desconocida"

  # Log descriptivo según la cohorte detectada en el nombre del fichero
  cohorte_desc <- "Desconocida"
  if (grepl("05_pcad_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "PCAD (05_pcad_cohort)"
  } else if (grepl("06_prod_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "PROD (06_prod_cohort)"
  } else if (grepl("07_icv_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "ICV (07_icv_cohort)"
  } else if (grepl("08_hist_no_onco_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "Histerectomía No Oncológica (08_hist_no_onco_cohort)"
  } else if (grepl("09_ncrl_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "NCRL (09_ncrl_cohort)"
  } else if (grepl("10_ncra_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "NCRA (10_ncra_cohort)"
  } else if (grepl("11_hist_onco_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "Histerectomía Oncológica (11_hist_onco_cohort)"
  } else if (grepl("12_ffem_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "FFEM (12_ffem_cohort)"
  } else if (grepl("13_hdig_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "HDIG (13_hdig_cohort)"
  } else if (grepl("14_cist_radical_cohort\\.sql$", nombre_fichero)) {
    cohorte_desc <- "Cistectomía Radical (14_cist_radical_cohort)"
  } else {
    nombre_tabla <- NA    
  }

  if (grepl("01_crear_episode_view\\.sql$", nombre_fichero)) {
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] CREANDO CÓDIGOS LIMPIOS PARA LOS DIAGNÓSTICOS")
    log_info("    Fichero: {nombre_fichero}")
    log_info("--------------------------------------------------------------------------")
    
  } else if (grepl("02_comorbidities\\.sql$", nombre_fichero)) {
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] CALCULANDO COMORBILIDADES EN LOS EPISODIOS")
    log_info("    Fichero: {nombre_fichero}")
    log_info("--------------------------------------------------------------------------")
    
  } else if (grepl("03_complications\\.sql$", nombre_fichero)) {
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] CALCULANDO COMPLICACIONES EN LOS EPISODIOS")
    log_info("    Fichero: {nombre_fichero}")
    log_info("--------------------------------------------------------------------------")
    
  } else if (grepl("04_elixhauser\\.sql$", nombre_fichero)) {
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] CALCULANDO ELIXHAUSER EN LOS EPISODIOS")
    log_info("    Fichero: {nombre_fichero}")
    log_info("--------------------------------------------------------------------------")
    
  } else {
    
    log_info("--------------------------------------------------------------------------")
    log_info("[+] PROCESANDO COHORTE: {cohorte_desc}")
    log_info("    Fichero: {nombre_fichero}")
    log_info("--------------------------------------------------------------------------")
    
  }

  tryCatch({    
    resultado <- dbExecute(con, sql_script)    
    
    if (!is.na(nombre_tabla)) {
      resultado_fmt <- format(resultado, big.mark = ",")
      log_info("  |--> Registros seleccionados al aplicar los criterios de inclusión y exclusión de la cohorte: {resultado_fmt}")
      if (grepl("13_hdig_cohort\\.sql$", nombre_fichero)) {
        next
      }
      
      log_info("  [✓] PROCESO COMPLETADO PARA LA TABLA: {nombre_tabla}")
    }  
    
  }, error = function(e) {
    log_error("  [X] ERROR al ejecutar el fichero {nombre_fichero}: {conditionMessage(e)}")
  })
}

for (fichero_path_exc_entity in ficheros_exclusion_tablas) {
  
  tryCatch({
    
    nombre_fichero_entity <- basename(fichero_path_exc_entity)
    sql_script_entity <- readChar(fichero_path_exc_entity, file.info(fichero_path_exc_entity)$size)
    
    # 1. Identificar la tabla original y el mensaje de log según la entidad
    if (grepl("entity_lab", nombre_fichero_entity, ignore.case = TRUE)) {
      tabla_origen <- "lab"
      criterio_entity <- "Entidad \"lab\" (evaluando fechas completas en \"determination_dt\" y \"result_determination_dt\" para Hbs)"
      
    } else if (grepl("entity_transfusion", nombre_fichero_entity, ignore.case = TRUE)) {
      tabla_origen <- "transfusion"
      criterio_entity <- "Entidad \"transfusion\" (evaluando fechas completas en \"transf_dt\")"
      
    } else if (grepl("entity_hosp_amb_pharmacy|entity_hosp_pharmacy", nombre_fichero_entity, ignore.case = TRUE)) {
      tabla_origen <- ifelse(grepl("hosp_amb_pharmacy", nombre_fichero_entity, ignore.case = TRUE), 
                             "hosp_amb_pharmacy", "hosp_pharmacy")
      criterio_entity <- sprintf("Entidad \"%s\" (evaluando fecha de dispensación completa para los tratamientos de Hierro IV y EPO)", tabla_origen)
      
    } else {
      tabla_origen <- NULL
      criterio_entity <- sprintf("entidad %s", nombre_fichero_entity)
    }

    log_info("      • Ejecutando para {criterio_entity} [{nombre_fichero_entity}]")
    
    # 2. Contar registros en la tabla origen antes de aplicar la vista
    n_inicial <- if (!is.null(tabla_origen)) {
      dbGetQuery(con, sprintf("SELECT COUNT(*) FROM %s", tabla_origen))[[1]]
    } else { NA }

    # 3. Crear la vista/tabla filtrada ejecutando el script
    dbExecute(con, sql_script_entity)
    
    # 4. Extraer el nombre de la vista creada mediante regex (ej. lab_view)
    patron_vista <- "(?i)CREATE\\s+(?:OR\\s+REPLACE\\s+)?(?:VIEW|TABLE)\\s+([a-zA-Z0-9_\\.\"]+)"
    coincidencia <- regexec(patron_vista, sql_script_entity, perl = TRUE)
    captura <- regmatches(sql_script_entity, coincidencia)
    nombre_vista <- if (length(captura[[1]]) > 1) captura[[1]][2] else NA

    # 5. Calcular retenidos y excluidos
    if (!is.na(nombre_vista) && !is.na(n_inicial)) {
      n_final   <- dbGetQuery(con, sprintf("SELECT COUNT(*) FROM %s", nombre_vista))[[1]]
      excluidos <- n_inicial - n_final
      
      log_info("        [✓] Registros iniciales en '{tabla_origen}': {format(n_inicial, big.mark = ',')}")
      log_info("        [✓] Registros excluidos por fechas incompletas: {format(excluidos, big.mark = ',')}")
      log_info("        [✓] Registros válidos retenidos en '{nombre_vista}': {format(n_final, big.mark = ',')}")
    } else {
      log_info("        [✓] Script de entidad ejecutado con éxito.")
    }

  }, error = function(e) {
    log_error("        [X] ERROR al ejecutar el fichero de entidad [{basename(fichero_path_exc_entity)}]: {conditionMessage(e)}")
  })
  
}

log_info("==========================================================================")
log_info(" PROCESO FINALIZADO CON ÉXITO")
log_info("==========================================================================")