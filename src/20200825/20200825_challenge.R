## CHALLENGE 1

# Use debug techniques to find the bug in the function evenOdd()

#' Function evenOdd() takes an integer n and returns a list containing two integers
#' that respectively indicate how many even and odd digits occur in n
#'
#' @examples
#' evenOdd(398473234) -> (4, 5)
#' evenOdd(459) -> (1, 2)
evenOdd <- function(n) {
  char_n <- as.character(n)
  counter_even <- 0
  counter_odd <- 0
  for (i in char_n) {
    digit <- as.integer(i)
    if (digit %% 2 == 0) {
      counter_even <- counter_even + 1
    } else {
      counter_odd <- counter_odd + 1
    }
  }
  return(list(n_even = counter_even,
              n_odd = counter_odd))
}


## CHALLENGE 2

# Using debug techniques find what is going wrong in functions step() and steps()

#' Function step() takes a positive integer:
#' 886328712442992
#'
#' Write down a positive integer:
#' 398473234
#' Count up the number of even and odd digits, and the total number of digits:
#' 4 5 9
#' String the digits of those three numbers together to make a new number:
#' 459
#' Return it as a number
#' @examples
#' step(398473234)
#' 459
#' step(459)
#' 123
step <- function(n) {
  n_odd_even <- evenOdd(n)
  total_digits <- nchar(n)
  n_odd_even_total <- n_odd_even
  n_odd_even_total$n_total <- total_digits
  return(n_odd_even_total)
}


#'Function `steps` takes an integer and return how
#' many steps you need before the number 123 is reached.
#' @examples
#' steps(398473234)
#' 2
#' steps(1)
#' 5
#' steps(2)
#' 2
steps <- function(n) {
  while (n != 123) {
    n <- step(n)
    n_steps <- n_steps + 1
  }
  return(n_steps)
}
