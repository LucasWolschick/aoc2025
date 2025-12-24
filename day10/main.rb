def parse_entries(src)
  src.lines.map(&:strip).reject(&:empty?).map do |line|
    light_diagram, rest = line.split("] ", 2)
    light_diagram = light_diagram + "]"
    buttons_diagram, rest = rest.split(" {", 2)
    joltage_diagram = "{" + rest

    # human-readable
    lights = light_diagram[1...-1].each_char.map { |c| c == '#' }
    buttons = buttons_diagram.strip.split.map { |bs| bs[1...-1].split(',').map(&:to_i) }
    joltages = joltage_diagram[1...-1].split(',').map(&:to_i)

    # binary numbers
    lights_bin = lights.each.with_index.select { |v, _| v }.reduce(0) do |accumulator, (_, i)|
      accumulator |= 1 << i
    end
    buttons_bin = buttons.map do |button|
      button.reduce(0) do |accumulator, i|
        accumulator |= 1 << i
      end
    end

    [lights_bin, buttons_bin, joltages]
  end
end

def powerset(elems)
  if elems.empty?
    [[]]
  else
    head, *tail = elems
    powerset_rest = powerset(tail)
    powersets_with_head = powerset_rest.map { |ps| [head] + ps }
    powersets_with_head + powerset_rest
  end
end

# thanks, tenthmascot!
# https://old.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
def solve(state, vectors)
  @cache ||= {}

  if state.any?(&:negative?)
    return Float::INFINITY
  end

  if state.all?(&:zero?)
    return 0
  end

  if @cache[[state, vectors]]
    return @cache[[state, vectors]]
  end

  # figure out which button combos lead us to the final parity
  desired_pattern = state.map { |x| x % 2 }
  possibilities = powerset(vectors).select do |choices|
    resulting_pattern = choices.reduce(Array.new(state.length) { 0 }) { |sum, vec| sum.zip(vec).map { |s, v| s + v } }
    resulting_pattern.map { |x| x % 2 } == desired_pattern
  end

  if possibilities.empty?
    return Float::INFINITY
  end

  # applying these presses, we're left with only pair indices
  # IF a solution exists after these presses, it's going to be a set of presses repeated twice
  # (otherwise we'd have a different parity)
  @cache[[state, vectors]] = possibilities.map do |p|
    new_state = p.reduce(state) { |state, vec| state.zip(vec).map { |s, v| s - v } }.map { |x| x / 2 }
    2 * solve(new_state, vectors) + p.length
  end.min
end

def part01(data)
  data.sum do |machine|
    target, buttons, _ = machine
    sets = powerset(buttons).select { |set| set.reduce(0, &:^) == target }
    sets.min_by(&:length).length
  end
end

def part02(data)
  data.each_with_index.sum do |machine, i|
    _, buttons, targets = machine
    
    # convert buttons to vectors
    dim = buttons.map(&:bit_length).max
    vectors = buttons.map { |option| 0.upto(dim - 1).map { |i| option[i] } }

    solve(targets.clone, vectors)
  end
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end