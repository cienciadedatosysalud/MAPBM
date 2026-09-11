append_result <- function(con_resultados, indicator_name, df_result){
  
  tabla_existe <- dbExistsTable(con_resultados, indicator_name)
  if (tabla_existe) {
    cat(sprintf("La tabla '%s' EXISTE. Añadiendo (APPEND) los nuevos datos...\n", indicator_name))
    dbWriteTable(
      conn = con_resultados, 
      name = indicator_name, 
      value = df_result, 
      append = TRUE, 
      row.names = FALSE
    )
  } else {
    cat(sprintf("La tabla '%s' NO existe. Creándola e insertando los datos...\n", indicator_name))
    dbWriteTable(
      conn = con_resultados, 
      name = indicator_name, 
      value = df_result, 
      overwrite = FALSE, 
      row.names = FALSE
    )
  }
}

ficheros <- list.files(
  path = directorio_sql,
  pattern = "\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

if (length(ficheros) == 0) {
  stop("¡ADVERTENCIA! No se encontraron ficheros .sql en el directorio:", directorio_sql)
}

ficheros_ordenados <- sort(ficheros)

# Mapa de reemplazos para las tablas dentro de las queries SQL
reemplazos_cohortes <- c(
  "cirugia_programada_cohort" = "cirugia_programada_cohort_year",
  "cirugia_oncologica_cohort"  = "cirugia_oncologica_cohort_year",
  "cirugia_urgente_cohort"     = "cirugia_urgente_cohort_year",
  "proceso_medico_cohort"      = "proceso_medico_cohort_year"
)

for (fichero_path in ficheros_ordenados) {
  
  nombre_fichero <- gsub("aux_files/queries/indicators/(.*)\\.sql", "\\1", fichero_path)
  cat("-> Ejecutando fichero:", nombre_fichero, "...\n")
  
  tryCatch({
    nombre_fichero <- gsub('/', '', nombre_fichero)
    
    # 1. Definir el nombre final de la tabla con el sufijo _year
    nombre_tabla_year <- paste0(nombre_fichero, "_year")
    
    # 2. Leer el contenido del fichero SQL
    sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
    
    # 3. Sustituir los nombres de las cohortes en la consulta
    for (viejo in names(reemplazos_cohortes)) {
      nuevo <- reemplazos_cohortes[viejo]
      # \\b garantiza que reemplace la palabra exacta y no fragmentos
      sql_script <- gsub(paste0("\\b", viejo, "\\b"), nuevo, sql_script)
    }
    
    sql_script <- gsub(
      pattern = "date_trunc\\('month', a\\.start_intervention_dt\\) as month_year,", 
      replacement = "date_trunc('year', a.start_intervention_dt) as month_year,", 
      x = sql_script,
      ignore.case = TRUE
    )

    # 4. Ejecutar la consulta modificada
    df_resultado <- dbGetQuery(con, sql_script)
    
    # 5. Guardar el resultado con el sufijo _year
    dbWriteTable(
      conn = con_result,
      name = nombre_tabla_year,
      value = df_resultado,
      overwrite = TRUE,
      row.names = FALSE
    )
    
    # Descomentar si vas a usar append_result en lugar de dbWriteTable directo:
    # df_resultado$mes_año <- as.Date(month)
    # append_result(con_result, nombre_tabla_year, df_resultado)
    
  }, error = function(e) {
    cat("   [ERROR] Fallo al ejecutar el fichero", nombre_fichero, ":\n")
    cat("   Mensaje de error:", conditionMessage(e), "\n")
  })
}