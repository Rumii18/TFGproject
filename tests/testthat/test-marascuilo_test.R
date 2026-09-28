test_that("marascuilo_test returns the correct structure and dimensions", {
  # 1. Setup the scenario with exact data from the TFG
  df_ejemplo <- data.frame(
    Ciudad = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
    Opinion = c(
      rep("De acuerdo", 115), rep("En desacuerdo", 35),
      rep("De acuerdo", 53), rep("En desacuerdo", 22),
      rep("De acuerdo", 40), rep("En desacuerdo", 35)
    )
  )

  # 2. Execute the function
  resultados <- marascuilo_test(df_ejemplo, "Ciudad", "Opinion", "De acuerdo")

  # 3. Verify the output structure
  expect_s3_class(resultados, "data.frame")
  expect_equal(nrow(resultados), 3) 
  
  # Check for correct column names
  expect_true(all(c("Pair", "Absolute_Diff", "Critical_Range", "Significance") %in% colnames(resultados)))
})

test_that("marascuilo_test throws error with invalid column names", {
  df_ejemplo <- data.frame(
    Ciudad = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
    Opinion = c(
      rep("De acuerdo", 115), rep("En desacuerdo", 35),
      rep("De acuerdo", 53), rep("En desacuerdo", 22),
      rep("De acuerdo", 40), rep("En desacuerdo", 35)
    )
  )

  # Force errors by passing column names that do not exist in df_ejemplo
  expect_error(marascuilo_test(df_ejemplo, "ColumnaFalsa", "Opinion", "De acuerdo"))
  expect_error(marascuilo_test(df_ejemplo, "Ciudad", "OpinionFalsa", "De acuerdo"))
})

test_that("marascuilo_test calculates absolute differences correctly", {
  df_ejemplo <- data.frame(
    Ciudad = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
    Opinion = c(
      rep("De acuerdo", 115), rep("En desacuerdo", 35),
      rep("De acuerdo", 53), rep("En desacuerdo", 22),
      rep("De acuerdo", 40), rep("En desacuerdo", 35)
    )
  )

  resultados <- marascuilo_test(df_ejemplo, "Ciudad", "Opinion", "De acuerdo")

  # Strict mathematical verification:
  # Proportion Cordoba = 115/150 = 0.7666...
  # Proportion Rio IV = 40/75 = 0.5333...
  # Absolute difference = 0.2333333
  
  # Check that this value (with a margin of error for rounding) exists in the output
  expect_true(any(abs(resultados$Absolute_Diff - 0.2333333) < 0.001))
})