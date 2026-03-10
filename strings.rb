require 'json'

# Return true if the letters of word appear in order in the array
# (not necessarily contiguous). O(n)
def subsequence?(array, word)
  i = 0

  array.each do |char|
    break if i == word.length

    i += 1 if char == word[i]
  end

  i == word.length
end

# Longest substring without repeating characters. O(n) sliding window.
def length_of_longest_substring(str)
  last = {}
  left = 0
  best = 0

  str.each_char.with_index do |ch, right|
    left = last[ch] + 1 if last.key?(ch) && last[ch] >= left
    last[ch] = right
    best = [best, right - left + 1].max
  end

  best
end

# Return true if str1 and str2 are anagrams of each other. O(n)
def anagram?(str1, str2)
  return false unless str1.length == str2.length

  freq = Hash.new(0)
  str1.each_char { |ch| freq[ch] += 1 }
  str2.each_char do |ch|
    freq[ch] -= 1
    return false if freq[ch].negative?
  end

  true
end

# Return true if all strings in the array are anagrams of each other.
def all_anagrams?(arr)
  return true if arr.length <= 1

  sorted = arr[0].chars.sort
  arr.all? { |str| str.chars.sort == sorted }
end

# Palindrome check — ignores non-alphanumeric characters, case-insensitive. O(n)
def palindrome?(str)
  i = 0
  j = str.length - 1

  while i < j
    i += 1 while i < j && str[i] !~ /[A-Za-z0-9]/
    j -= 1 while i < j && str[j] !~ /[A-Za-z0-9]/

    return false unless str[i].downcase == str[j].downcase

    i += 1
    j -= 1
  end

  true
end

# Return the index of the first non-repeating character, or -1. O(n)
def first_uniq_char(str)
  freq = Hash.new(0)
  str.each_char { |ch| freq[ch] += 1 }

  str.each_char.with_index do |ch, i|
    return i if freq[ch] == 1
  end

  -1
end

# Given an array of emails, return a JSON string mapping domain => sorted unique usernames.
def group_by_domain(emails)
  grouped = Hash.new { |h, k| h[k] = [] }

  emails.each do |email|
    next unless email.include?('@')

    user, domain = email.split('@', 2)
    next if user.nil? || user.empty? || domain.nil? || domain.empty?

    grouped[domain] << user
  end

  grouped.transform_values { |users| users.uniq.sort }
end

# Return 1 if parentheses in str are correctly matched, 0 otherwise.
# Strings with no brackets return 1.
def bracket_balance(str)
  balance = 0

  str.each_char do |char|
    if char == '('
      balance += 1
    elsif char == ')'
      balance -= 1
      return 0 if balance.negative?
    end
  end

  balance.zero? ? 1 : 0
end

# Given a string of two times separated by a hyphen (e.g. "9:00am-10:30pm"),
# return the total number of minutes between them as a string.
# Handles wrap-around midnight.
def minutes_count(str)
  start_str, end_str = str.strip.split('-')

  to_minutes = lambda do |time_str|
    time = time_str[0..-3]
    meridian = time_str[-2..]
    hours, minutes = time.split(':').map(&:to_i)

    hours = 0 if hours == 12
    hours += 12 if meridian.downcase == 'pm'

    (hours * 60) + minutes
  end

  start_minutes = to_minutes.call(start_str)
  end_minutes   = to_minutes.call(end_str)

  difference = end_minutes - start_minutes
  difference += 24 * 60 if difference.negative?

  difference.to_s
end

# Given a string where its a Roman number
# Convert to integer. Hash map lookup
def roman_to_int(str)
  roman_map = {
    'I' => 1,
    'V' => 5,
    'X' => 10,
    'L' => 50,
    'C' => 100,
    'D' => 500,
    'M' => 1000
  }

  str = str.upcase
  raise ArgumentError, 'invalid Roman numeral string' if str.empty? || str.chars.any? { |c| !roman_map.key?(c) }

  result = 0
  str.each_char.with_index do |char, i|
    current_value = roman_map[char] || 0
    next_value = roman_map[str[i + 1]] || 0
    if current_value < next_value
      result -= current_value
    else
      result += current_value
    end
  end

  result
end
