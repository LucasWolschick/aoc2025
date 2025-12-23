def parse_entries(src)
  graph = src.lines.map(&:strip).reject(&:empty?).map do |line|
    from, to = line.split(": ")
    [from, to.split]
  end.to_h
  graph
end

# only works for DAGs
def paths_from_to(graph, from, to)
  counts = {from => 1, to => 0}

  while counts.keys != [to]
    new_counts = {to => counts[to] || 0}
    counts.each do |key, val|
      next if key == to
      (graph[key] || []).each do |child|
        new_counts[child] = (new_counts[child] || 0) + val
      end
    end  
    counts = new_counts
  end

  counts[to]
end

def part01(data)
  paths_from_to(data, "you", "out")
end

def part02(data)
  svr_fft = paths_from_to(data, "svr", "fft")
  fft_dac = paths_from_to(data, "fft", "dac")
  dac_out = paths_from_to(data, "dac", "out")

  [svr_fft, fft_dac, dac_out].reduce(1, &:*)
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end