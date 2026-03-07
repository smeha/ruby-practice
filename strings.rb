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
def length_of_longest_substring(s)
  last = {}
  left = 0
  best = 0

  s.each_char.with_index do |ch, right|
    left = last[ch] + 1 if last.key?(ch) && last[ch] >= left
    last[ch] = right
    best = [best, right - left + 1].max
  end

  best
end

# Return true if s and t are anagrams of each other. O(n)
def anagram?(s, t)
  return false unless s.length == t.length

  freq = Hash.new(0)
  s.each_char { |ch| freq[ch] += 1 }
  t.each_char do |ch|
    freq[ch] -= 1
    return false if freq[ch] < 0
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
def palindrome?(s)
  i = 0
  j = s.length - 1

  while i < j
    i += 1 while i < j && s[i] !~ /[A-Za-z0-9]/
    j -= 1 while i < j && s[j] !~ /[A-Za-z0-9]/

    return false unless s[i].downcase == s[j].downcase

    i += 1
    j -= 1
  end

  true
end

# Return the index of the first non-repeating character, or -1. O(n)
def first_uniq_char(s)
  freq = Hash.new(0)
  s.each_char { |ch| freq[ch] += 1 }

  s.each_char.with_index do |ch, i|
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
      return 0 if balance < 0
    end
  end

  balance == 0 ? 1 : 0
end

# Given a string of two times separated by a hyphen (e.g. "9:00am-10:30pm"),
# return the total number of minutes between them as a string.
# Handles wrap-around midnight.
def minutes_count(str)
  start_str, end_str = str.strip.split('-')

  to_minutes = lambda do |time_str|
    time = time_str[0..-3]
    meridian = time_str[-2..-1]
    hours, minutes = time.split(':').map(&:to_i)

    hours = 0 if hours == 12
    hours += 12 if meridian.downcase == 'pm'

    hours * 60 + minutes
  end

  start_minutes = to_minutes.call(start_str)
  end_minutes   = to_minutes.call(end_str)

  difference = end_minutes - start_minutes
  difference += 24 * 60 if difference < 0

  difference.to_s
end
