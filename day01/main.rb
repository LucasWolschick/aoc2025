def parse(rot)
  case rot[0..0]
  when "L"
    return -rot[1..].to_i
  when "R"
    return rot[1..].to_i
  end
end

def parse_lines(src)
  src.lines
    .map(&:strip)
    .select {|s| !s.empty? }
    .map {|s| parse s }
end

def part01(data)
  dial = 50
  counter = 0
  data.each do |d|
    dial += d
    if dial % 100 == 0
      counter += 1
    end
  end
  counter
end

def part02(data)
  dial = 50
  counter = 0
  data.each do |d|
    whole_turns = d.abs / 100

    dd = d.remainder(100)
    partial_turn = if dd > 0 then
      # R: crossing 100->0
      dial < 100 && dial + dd >= 100 ? 1 : 0
    elsif dd < 0 then
      # L: crossing 1->0
      dial >= 1 && dial + dd <= 0 ? 1 : 0
    else
      0
    end

    counter += whole_turns + partial_turn
    dial = (dial + d) % 100
  end
  counter
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_lines(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end