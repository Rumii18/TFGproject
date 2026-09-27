# TFGproject: Marascuilo Procedure for Multiple Proportions

## Overview
`TFGproject` is an R package developed as part of a Bachelor's Thesis (TFG). It performs the **Marascuilo procedure** for simultaneous pairwise comparisons of multiple proportions, determining which pairs show statistically significant differences. It also includes a dedicated plotting function using `ggplot2` to visualize the results.

## Installation

You can install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("Rumii18/TFGproject")
```

## Example

Here is a quick example using the dataset from the project analysis:

```r
library(TFGproject)

# Sample data
df_ejemplo <- data.frame(
  Ciudad = c(rep("Cordoba", 150), rep("Villa Maria", 75), rep("Rio IV", 75)),
  Opinion = c(
    rep("De acuerdo", 115), rep("En desacuerdo", 35),
    rep("De acuerdo", 53), rep("En desacuerdo", 22),
    rep("De acuerdo", 40), rep("En desacuerdo", 35)
  )
)

# Run Marascuilo test
resultados <- marascuilo_test(df_ejemplo, "Ciudad", "Opinion", "De acuerdo")
print(resultados)

# Visualize results
plot_marascuilo(resultados)
```

## License
This package is distributed under the GPL-3 license.