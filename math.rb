# Check if number is prime. O(√n)
def is_prime?(num)
  return false unless num.is_a?(Integer)
  return false if num <= 1
  return true if num == 2
  return false if num.even?

  (3..Integer.sqrt(num)).step(2) { |i| return false if num % i == 0 }
  true
end

# Given coefficients and x, evaluate the polynomial using Horner's method.
# coeffs are highest-degree first: [a, b, c] => ax² + bx + c
def eval_poly(coeffs, x)
  raise ArgumentError, 'coeffs must be an Array' unless coeffs.is_a?(Array)

  coeffs.reduce(0) { |acc, c| acc * x + c }
end
