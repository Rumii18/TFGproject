#' Marascuilo Procedure for Multiple Comparisons of Proportions
#'
#' @description
#' Computes and evaluates all possible pairwise comparisons among proportions 
#' across multiple independent groups from a raw dataset. Following a 
#' statistically significant global test of homogeneity, this procedure 
#' identifies which specific pairs of proportions differ significantly while 
#' controlling the overall family-wise error rate.
#'
#' @param df A \code{data.frame} containing the raw categorical data.
#' @param col_grupo Character string specifying the column name that defines the categories/groups.
#' @param col_respuesta Character string specifying the column name with the responses (e.g., agree/disagree).
#' @param valor_exito Character string indicating the specific value in \code{col_respuesta} considered as statistical success.
#' @param alpha Numeric value indicating the significance level (default is \code{0.05}).
#'
#' @return An object of S3 class \code{marascuilo} (inheriting from \code{data.frame}) 
#' containing the pairwise comparisons with four columns: \code{Pair}, 
#' \code{Absolute_Diff}, \code{Critical_Range}, and \code{Significance}.
#'
#' @note
#' For any pair of groups \eqn{i} and \eqn{j}, the mathematical procedure compares 
#' the observed absolute difference between sample proportions, \eqn{|\hat{p}_i - \hat{p}_j|}, 
#' against a critical range \eqn{r_{ij}} defined as:
#' \deqn{r_{ij} = \sqrt{\chi^2_{1-\alpha, df}} \cdot \sqrt{\frac{\hat{p}_i(1-\hat{p}_i)}{n_i} + \frac{\hat{p}_j(1-\hat{p}_j)}{n_j}}}
#' where \eqn{\chi^2_{1-\alpha, df}} is the critical value from the chi-square distribution 
#' and \eqn{n_i, n_j} are the respective sample sizes for each group. A pairwise 
#' comparison is declared statistically significant if \eqn{|\hat{p}_i - \hat{p}_j| > r_{ij}}.
#'
#' @references
#' Marascuilo, L. A. (1966). Large-sample multiple comparisons. \emph{Psychological Bulletin}, 65(5), 280-290.
#'
#' NIST/SEMATECH (2012). \emph{e-Handbook of Statistical Methods}, Section 7.4.7.4 (Marascuilo procedure). National Institute of Standards and Technology.
#'
#' @export
#' @import purrr
#' 
#' @examples
#' library(ggplot2)
#' df_ejemplo <- data.frame(
#'   City = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
#'   Opinion = c(
#'     rep("Agree", 115), rep("Disagree", 35),
#'     rep("Agree", 53), rep("Disagree", 22),
#'     rep("Agree", 40), rep("Disagree", 35)
#'   )
#' )
#' resultados <- marascuilo_test(df_ejemplo, "City", "Opinion", "Agree")
#' print(resultados)
#' ggplot2::autoplot(resultados)
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
#' @description
#' Prints a formatted tabular summary of the Marascuilo procedure results to the console.
#'
#' @param x An object of class \code{marascuilo}.
#' @param ... Additional arguments passed to \code{print}.
#' @return Invisibly returns the original \code{marascuilo} object.
#' @export
print.marascuilo <- function(x, ...) {
  cat("\n--- Marascuilo Procedure Results ---\n\n")
  # Convert temporarily to pure data.frame to print without infinite loops
  print(as.data.frame(x), ...)
  cat("\n------------------------------------\n")
  invisible(x)
}

#' Autoplot method for marascuilo objects
#'
#' @description
#' Generates a bar chart comparing the observed absolute differences against 
#' the critical ranges for each pair of groups using \code{ggplot2}.
#'
#' @param object An object of class \code{marascuilo}.
#' @param ... Additional arguments.
#' @return A \code{ggplot} object visualizing the pairwise comparisons.
#' @export
#' @import ggplot2
autoplot.marascuilo <- function(object, ...) {
  
  grafico <- ggplot(object, aes(x = Pair, y = Absolute_Diff, fill = Significance)) +
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