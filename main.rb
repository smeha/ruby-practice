require 'pp'

require_relative 'math'
require_relative 'strings'
require_relative 'sorting'
require_relative 'arrays'
require_relative 'http_json_practice'
require_relative 'utilities'

puts 'Available exercises:'
puts '  prime          - Check if a number is prime'
puts '  evalpoly       - Evaluate a polynomial given coefficients and x'
puts '  subseq         - Check if a word is a subsequence of an array'
puts '  longestrepeat  - Longest substring without repeating characters'
puts '  anagram        - Check if two strings are anagrams'
puts '  allanagrams    - Check if all strings in a list are anagrams'
puts '  palindrome     - Palindrome check (ignores non-alphanumeric)'
puts '  firstuniq      - Index of the first non-repeating character'
puts '  groupdomain    - Group emails by domain (outputs JSON)'
puts '  quicksort      - Sort an array with quicksort'
puts '  brackets       - Validate matched parentheses'
puts '  timediff       - Minutes between two times (e.g. 9:00am-10:30pm)'
puts '  maxsubarray    - Maximum subarray sum (Kadane\'s algorithm)'
puts '  wizardlist     - HTTP challenge: house => most-friends wizard'
puts '  romantoint     - Roman number to integer number'
puts '  aggdata        - Aggregate sample data'
puts
print 'Enter exercise name: '

choice = $stdin.gets.chomp.strip

case choice
when 'prime'
  print '  Enter number: '
  n = $stdin.gets.chomp.to_i
  puts "  #{n} is prime: #{prime?(n)}"

when 'evalpoly'
  print '  Enter coefficients (space-separated, highest degree first): '
  coeffs = $stdin.gets.chomp.split.map(&:to_f)
  print '  Enter x: '
  x = $stdin.gets.chomp.to_f
  puts "  Result: #{eval_poly(coeffs, x)}"

when 'subseq'
  array = %w[a v t u i t s r o l]
  puts "  Array: #{array.inspect}"
  print '  Enter word: '
  word = $stdin.gets.chomp
  puts "  Is subsequence: #{subsequence?(array, word)}"

when 'longestrepeat'
  print '  Enter string: '
  s = $stdin.gets.chomp
  puts "  Longest substring without repeating: #{length_of_longest_substring(s)}"

when 'anagram'
  print '  Enter first string: '
  s = $stdin.gets.chomp
  print '  Enter second string: '
  t = $stdin.gets.chomp
  puts "  Anagram: #{anagram?(s, t)}"

when 'allanagrams'
  print '  Enter strings (space-separated): '
  arr = $stdin.gets.chomp.split
  puts "  All anagrams: #{all_anagrams?(arr)}"

when 'palindrome'
  print '  Enter string: '
  s = $stdin.gets.chomp
  puts "  Palindrome: #{palindrome?(s)}"

when 'firstuniq'
  print '  Enter string: '
  s = $stdin.gets.chomp
  puts "  First unique char index: #{first_uniq_char(s)}"

when 'groupdomain'
  print '  Enter emails (comma-separated): '
  emails = $stdin.gets.chomp.split(',').map(&:strip)
  require 'json'
  puts "  #{JSON.generate(group_by_domain(emails))}"

when 'quicksort'
  print '  Enter numbers (space-separated): '
  arr = $stdin.gets.chomp.split.map(&:to_i)
  puts "  Sorted: #{quicksort(arr).inspect}"

when 'brackets'
  print '  Enter string: '
  s = $stdin.gets.chomp
  puts "  Matched: #{bracket_balance(s)}"

when 'timediff'
  print '  Enter time range (e.g. 9:00am-10:30pm): '
  s = $stdin.gets.chomp
  puts "  Minutes: #{minutes_count(s)}"

when 'maxsubarray'
  print '  Enter numbers (space-separated): '
  nums = $stdin.gets.chomp.split.map(&:to_i)
  sum, sub = max_subarray(nums)
  puts "  Max sum: #{sum}, subarray: #{sub.inspect}"

when 'wizardlist'
  puts '  Fetching wizard list...'
  result = wizard_list_challenge
  require 'json'
  puts "  #{JSON.generate(result)}"

when 'romantoint'
  puts '  Enter Roman number(e.g. XIV): '
  s = $stdin.gets.chomp
  puts "  Integer number: #{roman_to_int(s)}"

when 'aggdata'
  puts '  Sample data input:'
  pp AGGREGATE_HASH_DATA
  puts '  Aggregated data output:'
  pp aggregate_hash(AGGREGATE_HASH_DATA)
else
  puts 'Unknown exercise.'
end
