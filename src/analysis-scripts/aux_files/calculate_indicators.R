append_result <- function(con_resultados, indicator_name,df_result){
  
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


for (fichero_path in ficheros_ordenados) {
  
  nombre_fichero <- gsub("aux_files/queries/indicators/(.*)\\.sql", "\\1",fichero_path)
  cat("-> Ejecutando fichero:", nombre_fichero, "...\n")
  
  tryCatch({
    nombre_fichero <- gsub('/','',nombre_fichero)
    sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
    
    df_resultado <- dbGetQuery(con, sql_script)
    dbWriteTable(
      conn = con_result,
      name = nombre_fichero,
      value = df_resultado,
      overwrite = TRUE,
      row.names = FALSE
    )
    # df_resultado$mes_año <- as.Date(month)
    # append_result(con_result, nombre_fichero,df_resultado)
    
    
  }, error = function(e) {
    cat("   [ERROR] Fallo al ejecutar el fichero", nombre_fichero, ":\n")
    cat("   Mensaje de error:", conditionMessage(e), "\n")
  })
}
