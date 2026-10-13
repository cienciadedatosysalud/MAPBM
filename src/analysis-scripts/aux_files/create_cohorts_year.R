directorio_year <- file.path(directorio_cohorts, "year")
directorio_excluir_fechas <- file.path(directorio_year, "excluir_fechas")

ficheros <- list.files(
  path = directorio_year,
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
  stop("¡ADVERTENCIA! No se encontraron ficheros .sql en el directorio: ", directorio_year)
}

ficheros_ordenados <- sort(ficheros)
ficheros_ordenados_exc_fechas <- sort(ficheros_exc_fechas)

# 1. Ejecución de los scripts de la carpeta year
for (fichero_path in ficheros_ordenados) {
  tryCatch({
    sql_script <- readChar(fichero_path, file.info(fichero_path)$size)
    dbExecute(con, sql_script)
  }, error = function(e) {
    warning("Fallo al ejecutar el fichero ", basename(fichero_path), ": ", conditionMessage(e))
  })
}

# 2. Ejecución de los scripts de exclusión por fechas
for (fichero_path_exc in ficheros_ordenados_exc_fechas) {
  tryCatch({
    sql_script_exc <- readChar(fichero_path_exc, file.info(fichero_path_exc)$size)
    dbExecute(con, sql_script_exc)
  }, error = function(e) {
    warning("Fallo al ejecutar el fichero de exclusión ", basename(fichero_path_exc), ": ", conditionMessage(e))
  })
}