def parse_range(line)
  left, right = line.strip.split("-", 2).map(&:to_i)
  left..right
end

def parse_product(line)
  line.strip.to_i
end

def parse_entries(src)
  ranges_src, products_src = src.strip.split("\n\n", 2).map(&:strip)

  ranges = ranges_src.lines.map { |r| parse_range(r) }
  products = products_src.lines.map { |p| parse_product(p) }

  [ranges, products]
end

def merge_ranges(ranges)
  ranges.sort_by(&:begin).each_with_object([]) do |range, acc|
    if acc.empty? || acc.last.end < range.begin
      acc << range
    else
      acc[-1] = acc.last.begin..([acc.last.end, range.end].max)
    end
  end
end

def part01(data)
  ranges, products = data
  ranges = merge_ranges(ranges)
  products.count { |p| ranges.any? { |r| r.include?(p) } }
end

def part02(data)
  ranges, _ = data
  ranges = merge_ranges(ranges)
  ranges.sum { |range| range.end - range.begin + 1 }
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end