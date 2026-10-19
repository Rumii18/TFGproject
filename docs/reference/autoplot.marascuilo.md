# Autoplot method for marascuilo objects

Generates a bar chart comparing the observed absolute differences
against the critical ranges for each pair of groups using `ggplot2`.

## Usage

``` r
# S3 method for class 'marascuilo'
autoplot(object, ...)
```

## Arguments

- object:

  An object of class `marascuilo`.

- ...:

  Additional arguments.

## Value

A `ggplot` object visualizing the pairwise comparisons.
