def parse_operator(op_src)
  case op_src
  when "*" then :mul
  when "+" then :add
  end
end

def parse_problem(problem_src)
  *numbers, op_src = problem_src
  [numbers.map(&:to_i), parse_operator(op_src)]
end

def parse_entries_part01(src)
  problem_srcs = src.lines.map(&:strip).reject(&:empty?).map(&:split).transpose
  problem_srcs.map { |problem_src| parse_problem(problem_src) }
end

def parse_entries_part02(src)
  transposed_src = src.lines.map(&:chars).transpose.map(&:join).map(&:strip).join("\n")
  transposed_src.split("\n\n").map do |problem_src|
    lines = problem_src.lines.map(&:strip)
    op = lines.first.chars.last
    numbers = lines.map { |line| line.tr(" *+", "") }
    parse_problem(numbers + [op])
  end
end

def solve(data)
  data.sum do |problem|
    case problem[1]
    when :add then problem[0].sum
    when :mul then problem[0].reduce(1, &:*)
    end
  end
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries_part01(src)
  puts "P1: #{solve input}"
  input = parse_entries_part02(src)
  puts "P2: #{solve input}"
end