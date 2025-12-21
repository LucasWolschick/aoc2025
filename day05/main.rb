def parse_range(line)
  l, r = line.strip.split("-", 2).map(&:to_i)
  l..r
end

def parse_product(line)
  line.strip.to_i
end

def parse_entries(src)
  ranges, products = src.strip.split("\n\n", 2).map(&:strip).map(&:lines)
  [
    ranges.map { |r| parse_range(r) },
    products.map { |p| parse_product(p) }
  ]
end

def part01(data)
  ranges, products = data
  products.count { |p| ranges.any? { |r| r.include?(p) } }
end

def part02(data)
  ranges, _ = data

  # merge ranges
  ranges.sort_by!(&:begin)

  current_i = 0
  while current_i < ranges.length - 1
    this_range, next_range = ranges[current_i..(current_i+1)]
    if this_range.end < next_range.begin
      current_i += 1
      next
    end

    new_range = this_range.begin..([this_range, next_range].map(&:end).max)
    ranges[current_i] = new_range
    ranges.delete_at(current_i + 1)
  end

  # count range elements
  ranges.sum { |range| range.end - range.begin + 1 }
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end