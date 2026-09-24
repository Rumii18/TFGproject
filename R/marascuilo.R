#' Test de Marascuilo
#'
#' @param df Un data.frame con los datos crudos.
#' @param col_grupo Nombre de la columna que contiene las categorías/grupos.
#' @param col_respuesta Nombre de la columna con las respuestas (ej. de acuerdo/en desacuerdo).
#' @param valor_exito El valor específico en col_respuesta del que se calculará la proporción.
#' @param alpha Nivel de significación (por defecto 0.05).
#'
#' @return Un data.frame con los resultados de las comparaciones.
#' @export
marascuilo_test <- function(df, col_grupo, col_respuesta, valor_exito, alpha = 0.05) {
  
  # cruzo columnas para sacar la tabla de frecuencias absolutas
  tabla <- table(df[[col_grupo]], df[[col_respuesta]])
  
  # totales por grupo y me quedo solo con los exitos que pide el usuario
  n_j <- rowSums(tabla)
  x_j <- tabla[, as.character(valor_exito)]
  
  # calculo las proporciones de cada grupo
  p_j <- x_j / n_j
  k <- length(p_j)
  
  # saco los grados de libertad de la tabla para buscar el valor chi-cuadrado critico
  filas <- nrow(tabla)
  columnas <- ncol(tabla)
  grados_libertad <- (filas - 1) * (columnas - 1)
  chi_critico <- qchisq(1 - alpha, df = grados_libertad)
  
  # preparo todas las combinaciones posibles de dos en dos
  nombres_grupos <- names(p_j)
  combinaciones <- combn(nombres_grupos, 2)
  num_comb <- ncol(combinaciones)
  
  # dataframe vacio para ir rellenandolo en el bucle
  resultados <- data.frame(
    Par = character(num_comb),
    Diferencia_Abs = numeric(num_comb),
    Margen_Tolerancia = numeric(num_comb),
    Significativo = character(num_comb),
    stringsAsFactors = FALSE
  )
  
  # evaluo las parejas una a una
  for (i in 1:num_comb) {
    g1 <- combinaciones[1, i]
    g2 <- combinaciones[2, i]
    
    p1 <- p_j[g1]
    p2 <- p_j[g2]
    n1 <- n_j[g1]
    n2 <- n_j[g2]
    
    # diferencia real absoluta entre proporciones
    dif_abs <- abs(p1 - p2)
    
    # aplico la formula del error estandar y fijo el limite de tolerancia
    error_estandar <- sqrt((p1 * (1 - p1) / n1) + (p2 * (1 - p2) / n2))
    m_jj <- sqrt(chi_critico) * error_estandar
    
    # pongo los resultados a la tabla y compruebo si superan la linea roja
    resultados$Par[i] <- paste(g1, "vs", g2)
    resultados$Diferencia_Abs[i] <- round(dif_abs, 4)
    resultados$Margen_Tolerancia[i] <- round(m_jj, 4)
    resultados$Significativo[i] <- ifelse(dif_abs > m_jj, "Diferentes", "Estadísticamente iguales")
  }
  
  return(resultados)
  
}


#' Gráfico del Test de Marascuilo
#'
#' @param resultados Un data.frame generado por la función marascuilo_test().
#'
#' @return Un objeto ggplot con la visualización de las comparaciones.
#' @export
#' @import ggplot2
plot_marascuilo <- function(resultados) {
  
  # por si acaso no la tienen cargada
  require(ggplot2)
  
  grafico <- ggplot(resultados, aes(x = Par, y = Diferencia_Abs, fill = Significativo)) +
    geom_col(alpha = 0.8) +
    # pongo la x indicando el margen y la quito de la leyenda.
    geom_point(aes(y = Margen_Tolerancia), color = "black", size = 4, shape = 4, show.legend = FALSE) +
    scale_fill_manual(
      name = "Conclusión del test:",
      values = c("Diferentes" = "#b37079", "Estadísticamente iguales" = "#02d963")
    ) +
    labs(
      title = "Resultados del Test de Marascuilo",
      subtitle = "Diferencia real (barras) vs Margen de tolerancia (cruces negras)",
      x = "Pares comparados",
      y = "Diferencia absoluta de proporciones"
    ) +
    theme_minimal()
  
  return(grafico)
}