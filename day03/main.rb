def parse(line)
  line.chars.map(&:to_i)
end

def parse_entries(src)
  src.lines
    .map(&:strip)
    .filter_map { |s| s.empty? ? nil : parse(s) }
end

# we have to do this because Enumerable#max is not stable
# (ie not guaranteed to return first max value in enumerable)
def find_max(array)
  max = array.first
  max_i = 0
  
  array.each_with_index do |v, pos|
    max_i, max = pos, v if v > max
  end

  [max, max_i]
end

def max_row_joltage_2(row)
  l, li = find_max(row[...-1])
  r, _ = find_max(row[(li+1)..])
  l * 10 + r
end

def max_row_joltage(row, digits)
  offset = 0
  digits.downto(1).sum do |pos|
    window = pos > 1 ? row[offset...-(pos-1)] : row[offset..]
    value, index = find_max(window)
    offset += index + 1
    value * (10 ** (pos-1))
  end
end

def part01(data)
  data.sum {|r| max_row_joltage(r, 2)}
end

def part02(data)
  data.sum {|r| max_row_joltage(r, 12)}
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end