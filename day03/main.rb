def parse(line)
  line.split('').map(&:to_i).to_a
end

def parse_entries(src)
  src.lines
    .filter_map do |s|
      s = s.strip
      s.empty? ? nil : parse(s)
    end
end

def find_max(array)
  max_i = 0
  max = array[0]
  for i in 0...array.length
    max_i, max = i, array[i] if array[i] > max
  end
  [max, max_i]
end

def max_row_joltage_2(row)
  l, li = find_max(row[...-1])
  r, _ = find_max(row[(li+1)..])
  l * 10 + r
end

def max_row_joltage(row, n)
  start_at = 0
  n.downto(1).sum do |i|
    num, new_start_at = find_max(i > 1 ? row[start_at...-(i-1)] : row[start_at..])
    start_at = start_at + new_start_at + 1
    num * (10 ** (i-1))
  end
end

def part01(data)
  data.map {|r| max_row_joltage(r, 2)}.sum
end

def part02(data)
  data.map {|r| max_row_joltage(r, 12)}.sum
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end