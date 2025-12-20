class IdRange
  attr_reader :first, :last

  def initialize(parts)
    @first = parts[0]
    @last = parts[1]
  end

  def inspect
    "(#{first}, #{last})"
  end

  def to_range
    @first..@last
  end
end

def parse(line)
  parts = line.split('-')
  return IdRange.new parts[0..1].map &:to_i
end

def parse_entries(src)
  src.split(',')
    .map(&:strip)
    .select {|s| !s.empty? }
    .map {|s| parse s }
end

def part01(data)
  invalid_sum = 0
  data.each do |range|
    range.first.upto(range.last).each do |n|
      s = n.to_s
      if s[...s.length/2] == s[s.length/2...]
        invalid_sum += n
      end
    end
  end
  invalid_sum
end

def part02(data)
  all_nums = data.inject([]) {|result, rhs| result.chain(rhs.to_range) }
  
  all_nums.sum do |number|
    string = number.to_s
    string_len = string.length
    max_len = string_len / 2

    matches = 1.upto(max_len).any? do |len|
      next false if string_len % len != 0
      num_repeats = string_len/len
      next false if num_repeats <= 1
      pat = string[0...len]
      matches = 1.upto(num_repeats-1).all? do |i|
        string[(i*len)...((i+1)*len)] == pat
      end
    end

    if matches
      number
    else
      0
    end
  end
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end