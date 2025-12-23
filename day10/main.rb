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

def try_subtract_state(state, vector)
  return nil, state if state.zip(vector).any? { |s, v| v > s }

  factor = state.zip(vector).map { |a, b| a * b }.select { |a| a > 0 }.min

  return factor, state.zip(vector).map { |s, v| s - factor * v }
end

# receives a joltage state and a list of lists of vectors grouped by their total joltage effect (sum of elements)
def solve(state, grouped_vectors)
  if grouped_vectors.empty? && state.sum > 0
    puts "WEIRD END STATE!"
    p [state, grouped_vectors]
    nil
  end
  return 0 if grouped_vectors.empty? && state.sum == 0
  return solve(state, grouped_vectors[1..]) if grouped_vectors[0].empty?

  vector, *rest = grouped_vectors[0]
  
  # with vector
  presses, new_state = try_subtract_state(state, vector)
  if !presses.nil?
    solved_with = solve(new_state, grouped_vectors)
    presses_with = solved_with ? presses + solved_with : nil
  end

  # without vector
  presses_without = solve(state, [rest, *grouped_vectors[1..]])

  if !presses_with.nil? && !presses_without.nil?
    [presses_with, presses_without].min
  elsif !presses_with.nil?
    presses_with
  else
    presses_without
  end
end

def presses(initial_state, vectors)
  # we want to find coefficients for each of the vectors such that their sum
  # multiplied by their coefficients equals `targets`
  
  # count = 0
  # state = initial_state
  # state = vectors.sort_by(&:sum).reverse.reduce(state) do |state, vector|
  #   try_subtract_state(state, vector)
  # end

  # count
  grouped_vectors = vectors.sort_by(&:sum).reverse.chunk(&:sum).map(&:last)
  solve(initial_state, grouped_vectors)
end

def part01(data)
  data.sum do |machine|
    target, buttons, _ = machine
    sets = powerset(buttons).select { |set| set.reduce(0, &:^) == target }
    sets.min_by(&:length).length
  end
end

def part02(data)
  data.sum do |machine|
    _, buttons, targets = machine
    
    # convert buttons to vectors
    dim = buttons.map(&:bit_length).max
    vectors = buttons.map { |option| 0.upto(dim - 1).map { |i| option[i] } }
    
    p machine
    p presses(targets.clone, vectors)
  end
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end