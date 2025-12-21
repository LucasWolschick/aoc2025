# let's do it with matrices >:)
require "matrix"

def parse_entries(src)
  source_src, *splits_srcs = src.lines
  source = source_src.index("S")
  splits = splits_srcs.map do |split_src|
    split_src.chars.each.with_index.select { |c, _| c == "^" }.map(&:last)
  end.reject(&:empty?)
  [source, splits]
end

def build_splits_matrix(splits, n)
  mat = Matrix.I(n)
  splits.each do |split|
    mat[split, split] -= 1
    mat[split - 1, split] += 1
    mat[split + 1, split] += 1
  end
  mat
end

def premultiply_splits(splits_list)
  n = splits_list.flatten.max + 2
  splits_list.reduce(Matrix.I(n)) do |acc, split_list|
     build_splits_matrix(split_list, n) * acc
  end
end

def compute_beams(start_pos, splits_list)
  mat = premultiply_splits(splits_list)
  vec = Matrix.build(mat.column_count, 1) { |row, _| row == start_pos ? 1 : 0 }
  mat * vec
end

def count_splits_merging(start_pos, splits_list)
  n = splits_list.flatten.max + 2
  vec = Matrix.build(n, 1) { |row, _| row == start_pos ? 1 : 0 }

  splits = 0
  splits_list.each do |split_list|
    before_count = vec.sum
    vec = build_splits_matrix(split_list, n) * vec
    after_count = vec.sum
    splits += after_count - before_count
    vec = vec.collect { |e, _, _| [e, 1].min }
  end

  splits
end

def part01(data)
  source, splits = data
  count_splits_merging(source, splits)
end

def part02(data)
  source, splits = data
  compute_beams(source, splits).sum
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end