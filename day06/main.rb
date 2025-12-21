def parse_operator(op_src)
  case op_src
  when "*" then :mul
  when "+" then :add
  end
end

def parse_problem(problem_src)
  *numbers_src, op_src = problem_src
  numbers, op = numbers_src.map(&:to_i), parse_operator(op_src)
  [numbers, op]
end

def parse_entries_part01(src)
  rows = src.lines.map(&:strip).reject(&:empty?).map(&:split)
  rows.transpose.map { |problem_src| parse_problem(problem_src) }
end

def parse_entries_part02(src)
  cols = src.lines.map(&:chars).transpose
  transposed_src = cols.map(&:join).map(&:strip).join("\n")
  problem_srcs = transposed_src.split("\n\n")

  problem_srcs.map do |problem_src|
    lines = problem_src.lines.map(&:strip)
    op = lines.first[-1]
    numbers = lines.map { |line| line.tr(" *+", "") }
    parse_problem(numbers + [op])
  end
end

def solve(data)
  data.sum do |numbers, op|
    case op
    when :add then numbers.sum
    when :mul then numbers.reduce(1, &:*)
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