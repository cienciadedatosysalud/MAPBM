ficheros <- list.files(
  path = paste0(directorio_cohorts,'month/'),
  pattern = "\\.sql$",
  full.names = TRUE,
  recursive = FALSE
)

if (length(ficheros) == 0) {
  stop("¡ADVERTENCIA! No se encontraron ficheros .sql en el directorio:", paste0(directorio_cohorts,'month/'))
}

ficheros_ordenados <- sort(ficheros)




for (fichero_path in ficheros_ordenados) {
  
  nombre_fichero <- basename(fichero_path)
  cat("-> Ejecutando fichero:", nombre_fichero, "...\n")
  
  tryCatch({
    
    sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
    
    resultado<-dbExecute(con, sql_script)
    
    cat(resultado)
    
  }, error = function(e) {
    cat("   [ERROR] Fallo al ejecutar el fichero", nombre_fichero, ":\n")
    cat("   Mensaje de error:", conditionMessage(e), "\n")
  })
}




