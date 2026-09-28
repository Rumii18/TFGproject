#' Marascuilo Test
#'
#' @param df A data.frame containing the raw data.
#' @param col_grupo Name of the column containing the categories/groups.
#' @param col_respuesta Name of the column with the responses (e.g., agree/disagree).
#' @param valor_exito The specific value in col_respuesta for which the proportion will be calculated.
#' @param alpha Significance level (default is 0.05).
#'
#' @return An object of class \code{marascuilo} containing a data.frame with the pairwise comparisons.
#' @export
#' @import purrr
#' 
#' @examples
#' df_ejemplo <- data.frame(
#'   Ciudad = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
#'   Opinion = c(
#'     rep("De acuerdo", 115), rep("En desacuerdo", 35),
#'     rep("De acuerdo", 53), rep("En desacuerdo", 22),
#'     rep("De acuerdo", 40), rep("En desacuerdo", 35)
#'   )
#' )
#' resultados <- marascuilo_test(df_ejemplo, "Ciudad", "Opinion", "De acuerdo")
marascuilo_test <- function(df, col_grupo, col_respuesta, valor_exito, alpha = 0.05) {
  
  # Explicit error handling for missing columns
  if (!col_grupo %in% colnames(df)) stop(paste("Column not found:", col_grupo))
  if (!col_respuesta %in% colnames(df)) stop(paste("Column not found:", col_respuesta))
  
  # Generate a two-way contingency table
  tabla <- table(df[[col_grupo]], df[[col_respuesta]])
  n_j <- rowSums(tabla)
  x_j <- tabla[, as.character(valor_exito)]
  p_j <- x_j / n_j
  
  # Find the critical value in the chi-square distribution
  filas <- nrow(tabla)
  columnas <- ncol(tabla)
  grados_libertad <- (filas - 1) * (columnas - 1)
  chi_critico <- qchisq(1 - alpha, df = grados_libertad)
  
  # Generate all possible pairs without repetition
  nombres_grupos <- names(p_j)
  combinaciones <- combn(nombres_grupos, 2, simplify = FALSE)
  
  # map_dfr iterates over the list and directly returns the final data.frame
  resultados <- purrr::map_dfr(combinaciones, function(par) {
    g1 <- par[1]
    g2 <- par[2]
    
    # Get proportions and sample sizes
    p1 <- p_j[g1]
    p2 <- p_j[g2]
    n1 <- n_j[g1]
    n2 <- n_j[g2]
    
    # Apply the mathematical formula of the Marascuilo procedure
    dif_abs <- abs(p1 - p2)
    error_estandar <- sqrt((p1 * (1 - p1) / n1) + (p2 * (1 - p2) / n2))
    m_jj <- sqrt(chi_critico) * error_estandar
    
    # Construct the output row for this specific comparison
    data.frame(
      Pair = paste(g1, "vs", g2),
      Absolute_Diff = round(dif_abs, 4),
      Critical_Range = round(m_jj, 4),
      Significance = ifelse(dif_abs > m_jj, "Significant", "Not Significant"),
      stringsAsFactors = FALSE
    )
  })
  
  # Assign the custom S3 class
  class(resultados) <- c("marascuilo", "data.frame")
  
  return(resultados)
}

#' Print method for marascuilo objects
#'
#' @param x An object of class \code{marascuilo}.
#' @param ... Additional arguments passed to print.
#' @export
print.marascuilo <- function(x, ...) {
  cat("\n--- Marascuilo Procedure Results ---\n\n")
  # Convert temporarily to pure data.frame to print without infinite loops
  print(as.data.frame(x), ...)
  cat("\n------------------------------------\n")
  invisible(x)
}

#' Plot method for marascuilo objects
#'
#' @param x An object of class \code{marascuilo}.
#' @param ... Additional arguments passed to plot.
#' @return A ggplot object visualizing the pairwise comparisons.
#' @export
#' @import ggplot2
plot.marascuilo <- function(x, ...) {
  
  grafico <- ggplot(x, aes(x = Pair, y = Absolute_Diff, fill = Significance)) +
    geom_col(alpha = 0.8) +
    geom_point(aes(y = Critical_Range), color = "black", size = 4, shape = 4, show.legend = FALSE) +
    scale_fill_manual(
      name = "Test Conclusion:",
      values = c("Significant" = "#b37079", "Not Significant" = "#02d963")
    ) +
    labs(
      title = "Marascuilo Test Results",
      subtitle = "Absolute Difference (bars) vs Critical Range (black crosses)",
      x = "Compared Pairs",
      y = "Absolute Difference in Proportions"
    ) +
    theme_minimal()
  
  return(grafico)
}