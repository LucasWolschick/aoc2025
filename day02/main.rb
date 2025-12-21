# todo: there's probably a better number-theoretical way of doing this
# (pattern: 123123123 / 1001001 == 123, 12341234 / 1001 == 1234)

def parse(line)
  start, finish = line.split('-', 2).map(&:to_i)
  start..finish
end

def parse_entries(src)
  src.split(',')
    .filter_map do |s|
      s = s.strip
      s.empty? ? nil : parse(s)
    end
end

def part01(data)
  data.sum do |range|
    range.select do |n|
      s = n.to_s
      half = s.length / 2
      s[...half] == s[half...]
    end.sum
  end
end

def part02(data)
  all_nums = data.flat_map(&:to_a)
  
  all_nums.select do |number|
    string = number.to_s
    1.upto(string.length / 2).any? do |len|
      string.length % len == 0 && string == string[0...len] * (string.length / len)
    end
  end.sum
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end