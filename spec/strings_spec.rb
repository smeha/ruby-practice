RSpec.describe '#subsequence?' do
  let(:array) { %w[a v t u i t s r o l] }

  it 'returns true when the word is a valid subsequence' do
    expect(subsequence?(array, 'avt')).to be true
  end

  it 'returns true when characters are non-contiguous' do
    expect(subsequence?(array, 'tut')).to be true
  end

  it 'returns false when characters appear in the wrong order' do
    expect(subsequence?(array, 'tua')).to be false
  end

  it 'returns true for an empty word' do
    expect(subsequence?(array, '')).to be true
  end

  it 'returns false when the word is longer than the array' do
    expect(subsequence?(array, 'avtuitsrolx')).to be false
  end
end

RSpec.describe '#length_of_longest_substring' do
  it "returns 3 for 'abcabcbb'" do
    expect(length_of_longest_substring('abcabcbb')).to eq(3)
  end

  it 'returns 1 for a string of all identical characters' do
    expect(length_of_longest_substring('bbbbb')).to eq(1)
  end

  it 'returns the full length when all characters are unique' do
    expect(length_of_longest_substring('abcde')).to eq(5)
  end

  it 'returns 0 for an empty string' do
    expect(length_of_longest_substring('')).to eq(0)
  end
end

RSpec.describe '#anagram?' do
  it 'returns true for valid anagrams' do
    expect(anagram?('anagram', 'nagaram')).to be true
  end

  it 'returns false for non-anagrams' do
    expect(anagram?('rat', 'car')).to be false
  end

  it 'returns false when lengths differ' do
    expect(anagram?('ab', 'abc')).to be false
  end

  it 'returns true for identical strings' do
    expect(anagram?('abc', 'abc')).to be true
  end
end

RSpec.describe '#all_anagrams?' do
  it 'returns true when all strings are anagrams of each other' do
    expect(all_anagrams?(%w[listen silent enlist])).to be true
  end

  it 'returns false when one string is not an anagram' do
    expect(all_anagrams?(%w[rat tar car])).to be false
  end

  it 'returns true for a single-element array' do
    expect(all_anagrams?(['hello'])).to be true
  end

  it 'returns true for an empty array' do
    expect(all_anagrams?([])).to be true
  end
end

RSpec.describe '#palindrome?' do
  it 'returns true for a classic palindrome with punctuation' do
    expect(palindrome?('A man, a plan, a canal: Panama')).to be true
  end

  it 'returns false for a non-palindrome' do
    expect(palindrome?('race a car')).to be false
  end

  it 'returns true for a single character' do
    expect(palindrome?('a')).to be true
  end

  it 'returns true for an empty string' do
    expect(palindrome?('')).to be true
  end

  it 'is case-insensitive' do
    expect(palindrome?('Racecar')).to be true
  end
end

RSpec.describe '#first_uniq_char' do
  it 'returns 0 when the first character is unique' do
    expect(first_uniq_char('leetcode')).to eq(0)
  end

  it 'returns the correct index for a later unique character' do
    expect(first_uniq_char('loveleetcode')).to eq(2)
  end

  it 'returns -1 when there are no unique characters' do
    expect(first_uniq_char('aabb')).to eq(-1)
  end

  it 'returns 0 for a single character string' do
    expect(first_uniq_char('z')).to eq(0)
  end
end

RSpec.describe '#group_by_domain' do
  let(:emails) { ['a@gmail.com', 'b@gmail.com', 'a@gmail.com', 'x@yahoo.com', 'bademail'] }

  it 'groups usernames by domain' do
    result = group_by_domain(emails)
    expect(result['gmail.com']).to eq(%w[a b])
    expect(result['yahoo.com']).to eq(['x'])
  end

  it 'deduplicates usernames within a domain' do
    result = group_by_domain(['a@x.com', 'a@x.com'])
    expect(result['x.com']).to eq(['a'])
  end

  it 'sorts usernames alphabetically' do
    result = group_by_domain(['z@x.com', 'a@x.com'])
    expect(result['x.com']).to eq(%w[a z])
  end

  it 'ignores malformed emails' do
    result = group_by_domain(['bademail', '@nodomain.com', 'nouser@'])
    expect(result).to be_empty
  end
end

RSpec.describe '#bracket_balance' do
  it 'returns 1 for correctly matched brackets' do
    expect(bracket_balance('(hello)(world)')).to eq(1)
  end

  it 'returns 0 for unmatched opening brackets' do
    expect(bracket_balance('((hello)')).to eq(0)
  end

  it 'returns 0 for an unmatched closing bracket' do
    expect(bracket_balance('(hello))')).to eq(0)
  end

  it 'returns 1 for a string with no brackets' do
    expect(bracket_balance('hello world')).to eq(1)
  end

  it 'returns 1 for an empty string' do
    expect(bracket_balance('')).to eq(1)
  end
end

RSpec.describe '#minutes_count' do
  it 'calculates minutes between two times on the same day' do
    expect(minutes_count('9:00am-10:30am')).to eq('90')
  end

  it 'handles am to pm' do
    expect(minutes_count('9:00am-10:00pm')).to eq('780')
  end

  it 'handles wrap-around midnight' do
    expect(minutes_count('10:00pm-8:00am')).to eq('600')
  end

  it 'handles 12am (midnight) correctly' do
    expect(minutes_count('12:00am-1:00am')).to eq('60')
  end

  it 'handles 12pm (noon) correctly' do
    expect(minutes_count('12:00pm-1:00pm')).to eq('60')
  end
end

RSpec.describe '#roman_to_int' do
  it 'handles xi correctly' do
    expect(roman_to_int('xi')).to eq(11)
  end

  it 'raises ArgumentError when input containing other characters rather than Roman numerals' do
    expect { roman_to_int('stst') }.to raise_error(ArgumentError, 'invalid Roman numeral string')
  end
end
