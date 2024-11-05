## CHALLENGE 1

make_bread <- function(grains, yeast, water, salt) {
  # Code to generate `bread`.
  # The code here can be easy (easy bread recipes do exist)
  # or quite complex (complex bread recipes do exist too)
  bread <- grains + yeast + water + salt
  return(bread)
}

make_focaccia <- function(grains, yeast, water, salt) {
  # Code to generate `focaccia`
  focaccia <- grains + 1.5 * sqrt(yeast) + 0.7 * water^2 + 2 * salt
  return(focaccia)
}



## Intermezzo 2 - dependencies

make_bread <- function(grains, yeast, water, salt) {
  assertthat::assert_that(assertthat::is.numeric(grains))
  assertthat::assert_that(assertthat::is.numeric(yeast))
  assertthat::assert_that(assertthat::is.numeric(water))
  assertthat::assert_that(assertthat::is.numeric(salt))
  bread <- grains + yeast + water + salt
  return(bread)
}






## CHALLENGE 3B

# Define the dummy data.frame for some ingredients
ingredients <- data.frame(
  grains = c(100, 200, 300),
  yeast = c(1, 2, 3),
  water = c(200, 300, 400),
  salt = c(5, 10, 15)
)
