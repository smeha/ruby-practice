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
puts '  ratelimiter    - Simple rate limiter'
puts '  flakytests     - Find flaky tests'
puts '  jobqueue       - Job queue with retry behavior'
puts '  movielist      - Watch list of movies with user ratings'
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
  sample_data_to_agg = [
    { suite: 'models', status: 'passed', duration: 12 },
    { suite: 'models', status: 'failed', duration: 8 },
    { suite: 'api',    status: 'passed', duration: 15 }
  ]

  puts '  Sample data:'
  pp sample_data_to_agg
  puts '  Aggregated data:'
  pp aggregate_hash(sample_data_to_agg)

when 'ratelimiter'
  max_requests = 3
  window_seconds = 10
  sample_limiter_tests = [
    ['user1', 0],
    ['user1', 1],
    ['user1', 2],
    ['user1', 3],
    ['user1', 11]
  ]

  puts "  Allow at most max requests set to #{max_requests}"
  puts "  Within a rolling window seconds set to #{window_seconds}"
  puts "  Will be tested against 'allow?'"
  limiter = RateLimiter.new(max_requests, window_seconds)
  sample_limiter_tests.each do |user, timestamp|
    puts "  user=#{user} time=#{timestamp} => #{limiter.allow?(user, timestamp)}"
  end

when 'flakytests'
  sample_flaky_tests = [
    { test_name: 'creates user', status: 'passed' },
    { test_name: 'creates user', status: 'failed' },
    { test_name: 'deletes user', status: 'passed' }
  ]

  puts '  Sample data:'
  pp sample_flaky_tests
  puts '  Flaky test(s):'
  pp find_flaky_tests(sample_flaky_tests)

when 'jobqueue'
  max_attempts = 3

  puts "  Creating a Job Queue with max attempts set to #{max_attempts}"
  job_queue = JobQueue.new(max_attempts)
  puts "  Adding 2 jobs to queue 'job-1' and 'job-2'"
  job_queue.add_job('job-1')
  job_queue.add_job('job-2')
  puts '  Starting next job in the queue:'
  job = job_queue.start_next
  puts "  job-id:#{job.id} | status:#{job.status} | attempts:#{job.attempts}"
  puts "  Marking 'job-1' failed and retrying failed 'job-1'"
  job_queue.mark_failed('job-1')
  job_queue.retry_failed('job-1')
  puts '  Starting next job in the queue:'
  job = job_queue.start_next
  puts "  job-id:#{job.id} | status:#{job.status} | attempts:#{job.attempts}"
  puts '  Starting next job in the queue:'
  job = job_queue.start_next
  puts "  job-id:#{job.id} | status:#{job.status} | attempts:#{job.attempts}"

when 'movielist'
  puts "  Creating 1 new user and rating 'Avatar' as 4:"
  user_part_one = User.new(1)
  user_part_one.rate('Avatar', 4)
  pp user_part_one.rating_list
  puts '  Creating movie queue'
  movie_queue = MovieQueue.new
  puts '  Adding 2 movies to the queue'
  movie_queue.add_movie('Avatar')
  movie_queue.add_movie('Avatar 2')
  puts '  Creating 2 new users, they watch the queue one by one and give ratings'
  users = []
  users << User.new(2)
  users << User.new(3)
  movie_queue.watch_next(users[0], 3)
  movie_queue.watch_next(users[1], 4)
  puts '  List all movies with status and user ratings:'
  pp movie_queue.list_all(users)

else
  puts 'Unknown exercise.'
end
