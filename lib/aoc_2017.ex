defmodule Aoc_2017 do
  @doc"""
  # Day 1a unit test
  iex> Aoc_2017.day1a(1122)
  3

  iex> Aoc_2017.day1a(1111)
  4

  iex> Aoc_2017.day1a(1234)
  0

  iex> Aoc_2017.day1a(91212129)
  9

  iex> Aoc_2017.day1a()
  1097
  """
  def day1a(input \\ Inputs.day1) do
    parsed_input = Integer.digits(input)
    {_, sum} = parsed_input
               |> examine_list(
                    fn
                      (elem, {elem, sum}) -> {elem, sum + elem}
                      (elem, {_, sum}) -> {elem, sum}
                    end
                  )
    if List.first(parsed_input) == List.last(parsed_input) do
      sum + List.first(parsed_input)
    else
      sum
    end
  end
  defp examine_list(list, fun) do
    list
      |> Enum.reduce( {:undefined, 0}, fun)
  end
  @doc """
  # Day 1b unit test
    iex> Aoc_2017.day1b()
    1188

    iex> Aoc_2017.day1b(1212)
    6

    iex> Aoc_2017.day1b(1221)
    0

    iex> Aoc_2017.day1b(123425)
    4

    iex> Aoc_2017.day1b(123123)
    12

    iex> Aoc_2017.day1b(12131415)
    4
  """
  def day1b(inp \\ Inputs.day1) do
    input = Integer.digits(inp)
    size = Enum.count(input)
    offset = div(size, 2)
    {_, res} = List.foldl(
      input,
      {0, 0},
      fn
        (elem, {index, sum}) when index <= offset - 1 ->
          cond do
            Enum.at(input, index + offset) == elem -> {index + 1, sum + elem}
            true -> {index + 1, sum}
          end
        (elem, {index, sum}) ->
          cond  do
            Enum.at(input, index + offset - size) == elem -> {index + 1, sum + elem}
            true -> {index + 1, sum}
          end
      end
    )
    res
  end
  @doc """
  # Day2a unit test
  iex> Aoc_2017.day2a()
  45158

  iex> Aoc_2017.day2a([[5,1,9,5],[7,5,3],[2,4,6,8]])
  18

  """
  def day2a(input \\ Inputs.day2) do
    Enum.sum(Enum.map(input, fn (list) -> Enum.max(list) - Enum.min(list) end))
  end
  @doc """
  # Day2b unit test
  iex> Aoc_2017.day2b()
  294

  iex> Aoc_2017.day2b([[5,9,2,8],[9,4,7,3],[3,8,6,5]])
  9
  """
  def day2b(input \\ Inputs.day2) do
    Enum.sum(
      Enum.map(
        input,
        fn (list) -> [_ | tail] = sort = Enum.sort(list, &(&1 >= &2))
                     {_, sum} = List.foldl(
                       sort,
                       {tail, 0},
                       fn
                         (elem, {[_ | t] = l, acc}) ->
                           {t, acc + Enum.sum(for i <- l, rem(elem, i) == 0, do: div(elem, i))}
                         (_, {[], acc}) ->
                           {0, acc}
                       end
                     ); sum
        end
      )
    )
  end
  @doc """
  # Day 3a unit test
  iex> Aoc_2017.day3a()
  480

  iex> Aoc_2017.day3a(1)
  0

  iex> Aoc_2017.day3a(12)
  3

  iex> Aoc_2017.day3a(23)
  2

  iex> Aoc_2017.day3a(1024)
  31
  """
  def day3a(input \\ Inputs.day3) do
    {_, {x, y}} = Map.fetch(
      Enum.to_list(1..input)
      |> create_grid,
      input
    )
    abs(x) + abs(y)
  end

  defp move_cord(dir, {x, y}) do
    case dir do
      :r -> {x + 1, y}
      :l -> {x - 1, y}
      :u -> {x, y + 1}
      :d -> {x, y - 1}
    end
  end
  defp create_grid(input) do
    {_, _, _, _, _, grid} = List.foldl(
      input,
      {0, 1, 1, :r, {0, 0}, %{}},
      fn
        (elem, {m, l, t, d, c, map}) when m < l ->
          {m + 1, l, t, d, move_cord(d, c), Map.put(map, elem, c)}
        (elem, {m, l, t, d, c, map}) when m == l and t < 2 ->
          {1, l, t + 1, change_dir(d), move_cord(change_dir(d), c), Map.put(map, elem, c)}
        (elem, {m, l, t, d, c, map}) when m == l and t == 2 ->
          {1, l + 1, 1, change_dir(d), move_cord(change_dir(d), c), Map.put(map, elem, c)}
      end
    )
    grid
  end

  defp change_dir(dir) do
    case dir do
      :r -> :u
      :u -> :l
      :l -> :d
      :d -> :r
    end
  end
  @doc """
  #Day 3b unit test
  iex> Aoc_2017.day3b()
  349975

  iex> Aoc_2017.day3b(27)
  54

  iex> Aoc_2017.day3b(66)
  122

  iex> Aoc_2017.day3b(150)
  304

  iex> Aoc_2017.day3b(380)
  747
  """
  def day3b(input \\ Inputs.day3) do
    Enum.reduce_while(
      Enum.to_list(1..input),
      {0, 1, 1, :r, {0, 0}, %{}},
      fn
        (_elem, {m, l, t, d, c, map}) when m < l -> v = calculate_value(map, c);
                                                    cond do
                                                      is_over_input(v, input) ->
{:halt, v};
                                                      true ->
                                                        {:cont, {m + 1, l, t, d, move_cord(d, c), Map.put(map, c, v)}}
                                                    end
        (_elem, {m, l, t, d, c, map}) when m == l and t < 2 -> v = calculate_value(map, c);
                                                               cond do
                                                                 is_over_input(v, input) ->
{:halt, v};
                                                                 true ->
                                                                   {
                                                                     :cont,
                                                                     {
                                                                       1,
                                                                       l,
                                                                       t + 1,
                                                                       change_dir(d),
                                                                       move_cord(change_dir(d), c),
                                                                       Map.put(map, c, v)
                                                                     }
                                                                   } end
        (_elem, {m, l, t, d, c, map}) when m == l and t == 2 -> v = calculate_value(map, c);
                                                                cond do
                                                                  is_over_input(v, input) ->
{:halt, v};
                                                                  true ->
                                                                    {
                                                                      :cont,
                                                                      {
                                                                        1,
                                                                        l + 1,
                                                                        1,
                                                                        change_dir(d),
                                                                        move_cord(change_dir(d), c),
                                                                        Map.put(map, c, v)
                                                                      }
                                                                    } end
      end
    )
  end

  defp calculate_value(map, {x, y}) do
    sum = Enum.sum(
      Enum.map(
        [
          {x + 1, y},
          {x, y + 1},
          {x + 1, y + 1},
          {x - 1, y},
          {x, y - 1},
          {x - 1, y - 1},
          {x + 1, y - 1},
          {x - 1, y + 1}
        ],
        fn c -> fetch_or_skip(map, c) end
      )
    )
    cond do
      sum == 0 -> 1
      true -> sum
    end
  end

  defp is_over_input(value, input) do
    value > input
  end

  defp fetch_or_skip(map, c) do
    case Map.fetch(map, c) do
      {:ok, v} -> v
      :error -> 0
    end
  end
  @doc """
  #Day 4a unit test
  iex> Aoc_2017.day4a()
  337

  iex> Aoc_2017.day4a("aa bb cc dd ee")
  1

  iex> Aoc_2017.day4a("aa bb cc dd aa")
  0

  iex>Aoc_2017.day4a("aa bb cc dd aaa")
  1
  """
  def day4a(input \\ Inputs.day4) do
    b = String.split(input, "\n")
        |> Enum.map(
             fn (s) -> String.trim(s)
                       |> String.split(" ")
             end
           )
    Enum.count(Enum.map(b, fn (b) -> Enum.count(b) == Enum.count(Enum.uniq(b)) end), fn (x) -> x == true end)
  end
  @doc """
  #Day 4b unit test
  iex> Aoc_2017.day4b()
  231

  iex> Aoc_2017.day4b("abcde fghij")
  1

  iex> Aoc_2017.day4b("abcde xyz ecdab")
  0

  iex> Aoc_2017.day4b("a ab abc adb abf abj")
  1

  iex> Aoc_2017.day4b("iiii oiii ooii oooi oooo")
  1

  iex> Aoc_2017.day4b("oiii, ioii, iioi, iiio")
  0
  """
  def day4b(input \\ Inputs.day4) do
    c = String.split(input, "\n")
        |> Enum.map(
             fn (s) ->
               String.trim(s)
               |> String.split(" ") end
           )
        |> Enum.map(fn (e) -> Enum.map(e, fn (x) -> sort_string(x) end) end)
    Enum.count(Enum.map(c, fn (c) -> Enum.count(c) == Enum.count(Enum.uniq(c)) end), fn (x) -> x == true end)
  end
  @doc """
  #Day 5a unit test
  iex> Aoc_2017.day5a()
  373543

  iex> Aoc_2017.day5a([0,3,0,1,-3])
  5
  """
  def day5a(input \\ Inputs.day5) do
    {_length, map} = List.foldl(
      input,
      {0, %{}},
      fn (value, {index, map}) -> {index + 1, Map.put(map, index, value)} end
    )
    jump_a(0, 0, map)
  end
  @doc """
  #Day 5b unit test
#  iex> Aoc_2017.day5b()
#  27502966

  iex> Aoc_2017.day5b([0,3,0,1,-3])
  10
  """
  def day5b(input \\ Inputs.day5) do
    {_length, map} = List.foldl(
      input,
      {0, %{}},
      fn (value, {index, map}) -> {index + 1, Map.put(map, index, value)} end
    )
    jump_b(0, 0, map)
  end
  def jump_a(index, count, map) do
    case Map.fetch(map, index) do
      {:ok, step} -> jump_a(index + step, count + 1, Map.put(map, index, step + 1))
      :error -> count
    end
  end
  def jump_b(index, count, map) do
    case Map.fetch(map, index) do
      {:ok, step} when step >= 3 -> jump_b(index + step, count + 1, Map.put(map, index, step - 1))
      {:ok, step} -> jump_b(index + step, count + 1, Map.put(map, index, step + 1))
      :error -> count
    end
  end
  @doc """
  #Day 6a unit test
  iex> Aoc_2017.day6a()
  12841

  iex> Aoc_2017.day6a("0\t2\t7\t0")
  5
  """
  def day6a(input \\ Inputs.day6) do
    parsed_input = input
                   |> String.split("\t")
                   |> Enum.map(fn x -> String.to_integer(x) end)
    memory_map = Enum.zip(1..length(parsed_input), parsed_input)
                 |> Enum.into(%{})
    {_, _, count} = cycle(memory_map, [], 1)
    count
  end
  @doc """
  # Day 6b unit test
  iex> Aoc_2017.day6b()
  8038

  iex> Aoc_2017.day6b("0\t2\t7\t0")
  4
  """
  def day6b(input \\ Inputs.day6) do
    parsed_input = input
                   |> String.split("\t")
                   |> Enum.map(fn x -> String.to_integer(x) end)
    memory_map = Enum.zip(1..length(parsed_input), parsed_input)
                 |> Enum.into(%{})
    {m, l, _} = cycle(memory_map, [], 1)
    i = Enum.find_index(l, fn elem -> elem == m end)
    i + 1
  end

  def max_value(map) do
    Enum.reduce(
      map,
      {0, 0},
      fn {_i, v} = x, {_i_a, v_a} = acc ->
        if v > v_a do;
          x;
        else
          acc
        end end
    ) end

  def cycle(map, map_list, cycle_count) do
    {index, value} = max_value(map)
    new_map = update_map(map, index, value)
    if Enum.member?(map_list, new_map) do
      {new_map, map_list, cycle_count}
    else
      cycle(new_map, [new_map | map_list], cycle_count + 1)
    end
  end

  def update_map(map, index, value) do
    size = Map.size(map)
    new_map = Map.put(map, index, 0)
    {_, res} = Enum.reduce(
      1..value,
      {index + 1, new_map},
      fn
        (_it, {ind, m}) when ind < size ->
          {_, next_m} = Map.get_and_update(m, ind, fn x -> {x, x + 1} end);
          {ind + 1, next_m}
        (_it, {ind, m}) when ind == size ->
          {_, next_m} = Map.get_and_update(m, ind, fn x -> {x, x + 1} end);
          {1, next_m}
        (_it, {ind, m}) when ind > size ->
          {_, next_m} = Map.get_and_update(m, 1, fn x -> {x, x + 1} end);
          {2, next_m}
      end
    )

    res
  end
  @doc ~S"""
  iex> Aoc_2017.day7a("pbga (66)
  ...>xhth (57)
  ...>ebii (61)
  ...>havc (66)
  ...>ktlj (57)
  ...>fwft (72) -> ktlj, cntj, xhth
  ...>qoyq (66)
  ...>padx (45) -> pbga, havc, qoyq
  ...>tknk (41) -> ugml, padx, fwft
  ...>jptl (61)
  ...>ugml (68) -> gyxo, ebii, jptl
  ...>gyxo (61)
  ...>cntj (57)")
  "tknk"

  iex> Aoc_2017.day7a
  "wiapj"
  """
  def day7a(input \\ Inputs.day7) do
    # Split the input into two list, one of root nodes, and one of subnodes, substract those lists, and remaining item will be the root of the tree
   {nodes,subnodes} = parse_input_day7(input)
                      |> Enum.reduce({[],[]}, fn([node_name,_| subnodes], {nodes, subnodes_acc}) ->  {[node_name|nodes],[subnodes|subnodes_acc]} end)
   List.first(nodes--List.flatten(subnodes))
  end

  def day7b(input \\ Inputs.day7) do
    tower_map = parse_input_day7(input) |> Enum.reduce(%{}, fn([key, weight|subnodes], map) -> Map.put(map, key, {String.to_integer(weight), subnodes}) end)

  end

  def parse_input_day7(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x)
                        |> Enum.map(fn x ->  String.replace(x, ~r"\(|\)|,", "") end)
                        |> Enum.filter(fn x-> x != "->" end) end)
  end
  def calc_subnodes(sub_nodes, map) do
    for sub_node <- sub_nodes, do: Map.get(map, sub_node) |> Enum.sum
  end
  def get_subnodes(map, node_name) do
    {_, subnodes} = Map.get(map, node_name)
    for subnode <- subnodes, do: {subnode,Map.get(map, subnode)}
  end

  def sort_string(string) do
    string
    |> String.downcase()
    |> String.graphemes()
    |> Enum.sort()
  end
@doc ~S"""
  iex> Aoc_2017.day8a("b inc 5 if a > 1
  ...> a inc 1 if b < 5
  ...> c dec -10 if a >= 1
  ...> c inc -20 if c == 10")
  1

  iex> Aoc_2017.day8a
  4066
  """
  def day8a(input \\ Inputs.day8) do
    input
     |> map_register
     |> Map.delete(:highest)
     |> Map.values
     |> Enum.max
  end
  @doc ~S"""
  iex> Aoc_2017.day8b("b inc 5 if a > 1
  ...> a inc 1 if b < 5
  ...> c dec -10 if a >= 1
  ...> c inc -20 if c == 10")
  10

  iex> Aoc_2017.day8b
  4829
  """
  def day8b (input \\ Inputs.day8) do
   input
    |> map_register
    |> Map.values
    |> Enum.max
  end

  def map_register(input) do
    {_, acc} = input
               |> String.split("\n") #We now have a list of 1 line strings
      # now we have list of strings where 1st is map key, 2nd is operation,
      # 3rd is number, 4th is key to examine 5th is conditional, 6th is value to check
               |> Enum.map(fn line -> String.split(line, "if")
                                      |> Enum.flat_map(fn split_line -> String.split(split_line) end) end)
               |> Enum.map_reduce(%{}, &calculate_line/2)
    acc
  end
  def calculate_line([key, operation, value, key_to_check, conditional, value_to_check] = l, map) do
    update_map = Map.put_new(map, key, 0)
    if is_true(key_to_check, conditional, String.to_integer(value_to_check), update_map) do
     new_v = calculate_new_value(Map.get(update_map, key), operation, String.to_integer(value))
     updated_map =
       if new_v > Map.get(update_map, :highest, 0) do
         Map.put(update_map, :highest, new_v)
       else update_map end
     {l, Map.put(updated_map, key, new_v)}
    else
     {l, update_map}
    end
  end

  def is_true(key, conditional, value, map) do
    k_v = Map.get(map, key, 0)
    case conditional do
      ">" ->  k_v > value
      "<" ->  k_v < value
      ">=" -> k_v >= value
      "<=" -> k_v <= value
      "!=" -> k_v != value
      "==" -> k_v == value
    end
  end
  def calculate_new_value(old_v, operation, value) do
    case operation do
      "inc" -> (old_v) + (value)
      "dec" -> (old_v) - (value)
    end
  end
  @doc ~s"""
  iex> Aoc_2017.day9a(~s({}))
  1

  iex> Aoc_2017.day9a(~s({{{}}}))
  6

  iex> Aoc_2017.day9a(~s({{},{}}))
  5

  iex> Aoc_2017.day9a(~s({<{},{},{{}}>}))
  1

  iex> Aoc_2017.day9a(~s({{{},{},{{}}}}))
  16

  iex> Aoc_2017.day9a(~s({{<!!>},{<!!>},{<!!>},{<!!>}}))
  9

  iex> Aoc_2017.day9a()
  12396
  """
  def day9a(input \\ Inputs.day9) do
    input
    |> String.graphemes
    |> Enum.reduce(%{:skip => :false, :garbage => :false, :level => 1, :garbage_count => 0, :score => 0 }, &iterate_chars/2)
    |> Map.get(:score)
  end
  @doc """
  iex> Aoc_2017.day9b
  6346
  """
  def day9b(input \\ Inputs.day9) do
    input
    |> String.graphemes
    |> Enum.reduce(%{:skip => :false, :garbage => :false, :garbage_count => 0, :level => 1, :score => 0 }, &iterate_chars/2)
    |> Map.get(:garbage_count)
  end

  def iterate_chars(_, %{:skip => :true} = map), do: %{map | :skip => :false}
  def iterate_chars("!", map), do: %{map | :skip => :true}
  def iterate_chars(">", %{:garbage => :true} = map), do: %{map | :garbage => :false}
  def iterate_chars(_, %{:garbage => :true, :garbage_count => gc} = map), do: %{map | :garbage_count => gc+1}
  def iterate_chars("<", map), do: %{map | :garbage => :true}
  def iterate_chars("{", %{:level => level, :score => score} = map), do: %{map |:level => level+1, :score => score+level}
  def iterate_chars("}", %{:level => level} = map), do: %{map |:level => level-1}
  def iterate_chars(_, map), do: map

  @doc """
  iex> Aoc_2017.day10a(Enum.to_list(0..4), "3,4,1,5")
  12

  iex> Aoc_2017.day10a(Enum.to_list(0..255))
  23874
  """
  def day10a(size, input \\ Inputs.day10) do
    input
    |> String.split(",")
    |> Enum.map(fn i -> String.to_integer(i) end)
    |> Enum.reduce(%{:position => 0, :skip_size => 0, :list => size}, &reverse_list/2)
    |> multiply_first_two
  end


  def day10b(size, input \\ Inputs.day10) do
    list = String.to_charlist(input) ++ [17,31,73,47,23]
    IO.inspect(list)
    list
    |> sparse_hash(size)
    |> dense_hash

  end

  def dense_hash(list) do
    use Bitwise
    list
    |> Enum.chunk_every(16)
    |> Enum.map(fn e -> Enum.reduce(e, fn elem, acc -> elem ^^^ acc end) end)
    |> Enum.map(fn s -> Integer.to_string(s, 16) |> String.pad_leading(2, "0") end)
    |> Enum.join
    |> String.downcase
  end

  def sparse_hash(lengths, size) do
    Enum.reduce(lengths, %{:position => 0, :skip_size => 0, :list => size}, &reverse_list/2)
    |> sparse_hash(lengths, 63)
  end
  def sparse_hash(%{:list => list}, _lengths, 0), do: list
  def sparse_hash(parameters, lengths, round) do
    IO.inspect(parameters)
    Enum.reduce(lengths, parameters, &reverse_list/2)
    |> sparse_hash(lengths, round-1)
  end
  def knot_hash(input) do
    use Bitwise
    lengths = String.to_charlist(input) ++ [17, 31, 73, 47, 23]
    Enum.reduce(1..64, {0..255, 0, 0},
      fn(_, {elements, startPos, startSkip}) ->
        knot_it(lengths, elements, startPos, startSkip) end)
    |> elem(0)
    |> Enum.chunk_every(16)
    |> Enum.map(fn e -> Enum.reduce(e, &(&1 ^^^ &2)) end)
    |> Enum.map(fn s -> Integer.to_string(s, 16) |> String.pad_leading(2, "0") end)
    |> Enum.join
    |> String.downcase
  end

  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------
  defp knot_it([curLen | lengths], elements, curPos, skipSize) do
    newElems =
      Enum.split(elements, curPos)
      |> (fn {a, b} -> Enum.reverse_slice(b ++ a, 0, curLen)  end).()
      |> Enum.split(-curPos)
      |> (fn {b, a} -> a ++ b end).()
    knot_it(lengths, newElems, move_pos(curPos, Enum.count(elements), curLen + skipSize), skipSize + 1)
  end
  defp knot_it([], elements, curPos, curLen) do
    {elements, curPos, curLen}
  end

  defp move_pos(curPos, elemLen, move) when move > elemLen, do: move_pos(curPos, elemLen, rem(move, elemLen))
  defp move_pos(curPos, elemLength, move) when (curPos + move) < elemLength, do: curPos + move
  defp move_pos(curPos, elemLen, move), do: move - (elemLen - curPos)

  @doc """
  iex> Aoc_2017.reverse_list(3, %{:position => 0, :skip_size => 0, :list => Enum.to_list(0..4)})
  %{:skip_size => 1, :position => 3, :list => [2,1,0,3,4]}

  iex> Aoc_2017.reverse_list(4, %{:skip_size => 1, :position => 3, :list => [2,1,0,3,4]})
  %{:position => 3, :list => [4,3,0,1,2], :skip_size => 2}

  iex> Aoc_2017.reverse_list(2, %{:skip_size => 1, :position => 1, :list => [1,2,3,4,5]})
  %{:position => 4, :list => [1,3,2,4,5], :skip_size =>2}
  """
  def reverse_list(length, %{:position => position, :skip_size => skip_size, :list => list} = acc) when position + length <= length(list) do
    reversed_list = Enum.reverse_slice(list, position, length)
    %{acc| :list => reversed_list, :position=> get_new_position(length, acc), :skip_size => skip_size+1}
  end

  def reverse_list(length, %{:position => position, :skip_size => skip_size, :list => list} = acc) do
     {first, second} = Enum.split(list, position)
     {to_the_end, beginning} =
       Enum.reverse_slice(second ++ first, 0, length)
       |> Enum.split(length(list)-position)
       %{acc | :list => beginning++to_the_end, :skip_size => skip_size+1, :position => get_new_position(length, acc)}
  end
  defp get_new_position(length, %{:position => pos, :skip_size => skip_size, :list => list}) do
    list_size = length(list)
    move_count = pos + skip_size + length
    cond do
      move_count == list_size -> pos
      move_count > list_size -> rem(move_count, list_size)
      move_count < list_size -> move_count
    end
  end

  defp multiply_first_two(%{:list => [first, second |_rest]}), do: first * second
@doc """
 iex> Aoc_2017.day11a("ne,ne,ne")
 3

 iex> Aoc_2017.day11a("ne,ne,sw,sw")
 0

 iex> Aoc_2017.day11a("ne,ne,s,s")
 2

 iex> Aoc_2017.day11a("se,sw,se,sw,sw")
 3

 iex> Aoc_2017.day11a
 687
"""
  def day11a(input \\ Inputs.day11) do
    input
    |> String.split(",")
    |> Enum.reduce([0,0,0,0], &crawl/2)
    |> Enum.map(fn coordinate -> abs(coordinate) end)
    |> Enum.drop(-1)
    |> Enum.max
  end
  @doc """
  iex> Aoc_2017.day11b
  1483
  """
  def day11b(input \\ Inputs.day11) do
    input
    |> String.split(",")
    |> Enum.reduce([0,0,0,0], &crawl/2)
    |> Enum.max
  end

  defp crawl("n",  [x, y, z, _] = list), do: [x, y+1, z-1, get_max_distance(list)]
  defp crawl("ne", [x, y, z, _] = list), do: [x-1, y+1, z, get_max_distance(list)]
  defp crawl("se", [x, y, z, _] = list), do: [x-1, y, z+1, get_max_distance(list)]
  defp crawl("s",  [x, y, z, _] = list), do: [x, y-1, z+1, get_max_distance(list)]
  defp crawl("sw", [x, y, z, _] = list), do: [x+1, y-1, z, get_max_distance(list)]
  defp crawl("nw", [x, y, z, _] = list), do: [x+1, y, z-1, get_max_distance(list)]
  defp get_max_distance(list), do: Enum.map(list, fn elem -> abs(elem) end) |> Enum.max
  @doc """
  iex> Aoc_2017.day12a
  169

  iex> Aoc_2017.day12a("0 <-> 2
  ...> 1 <-> 1
  ...> 2 <-> 0, 3, 4
  ...> 3 <-> 2, 4
  ...> 4 <-> 2, 3, 6
  ...> 5 <-> 6
  ...> 6 <-> 4, 5")
  6
  """
  def day12a(input \\ Inputs.day12) do
    input
    |> build_pipe_map
    |> calculate_connections
    |> MapSet.size
  end
  @doc """
  iex> Aoc_2017.day12b("0 <-> 2
  ...> 1 <-> 1
  ...> 2 <-> 0, 3, 4
  ...> 3 <-> 2, 4
  ...> 4 <-> 2, 3, 6
  ...> 5 <-> 6
  ...> 6 <-> 4, 5")
  2

  iex> Aoc_2017.day12b
  179
  """
  def day12b(input \\ Inputs.day12) do
    input
    |> build_pipe_map
    |> get_all_groups
    |> length
  end
  def get_all_groups(pipe_map) do
    first_set = calculate_connections(pipe_map)
    #taking a shortcut here, assuming there will be always more than 1 group
    [root|_remaining_nodes] = Map.keys(pipe_map)--MapSet.to_list(first_set)
    get_all_groups(root, pipe_map, [first_set])
  end
  def get_all_groups(root, pipe_map, acc) do
    next_set = calculate_connections(pipe_map, root)
    case Map.keys(pipe_map) -- Enum.reduce(acc, [], fn set, list -> MapSet.to_list(set)++list end) ++ MapSet.to_list(next_set) do
      [] -> [next_set|acc]
      [new_root|_nodes] -> get_all_groups(new_root, pipe_map, [next_set|acc])
    end
  end
  def calculate_connections(pipe_map, root \\ 0) do
    pipe_map[root]
    |> MapSet.new()
    |> MapSet.put(root)
    |> calculate_connections(pipe_map, pipe_map[root])
  end

  def calculate_connections(connected_nodes, pipe_map, nodes_to_examine) do
    new_connections =
      Enum.flat_map(nodes_to_examine, fn n -> pipe_map[n] end)
      |> Enum.filter(fn n -> not MapSet.member?(connected_nodes, n) end)
      cond do
      new_connections == [] -> connected_nodes
      true -> calculate_connections(add_connections(new_connections, connected_nodes), pipe_map, new_connections)
      end
  end

  def add_connections(new_connections, connections_set) do
    MapSet.union(MapSet.new(new_connections), connections_set)
  end

  def build_pipe_map(input) do
    String.split(input, "\n")
    |> Enum.reduce(%{}, &day12_map/2)
  end
  def day12_map(line, acc) do
    [node|nodes] =
    String.replace(line, ~r"\<|\>|,|-", "")
    |> String.split
    |> Enum.map(fn elem -> String.to_integer(elem) end)
    Map.put_new(acc, node, nodes)
  end
  @doc """
  iex> Aoc_2017.day13a("0: 3
  ...> 1: 2
  ...> 4: 4
  ...> 6: 4")
  24

  iex> Aoc_2017.day13a
  632
  """
  def day13a(input \\ Inputs.day13) do
    input
    |> String.split("\n")
    |> Enum.map(fn l ->  String.split(l, ":") |> Enum.map(fn s -> String.trim(s) |> String.to_integer end) end)
    |> Enum.reduce(%{:curLayer =>-1, :severity => 0, :caught => :false}, fn [layer, depth], acc -> Map.put_new(acc, layer, {1, depth, :down}) end)
    |> (fn(params) -> Enum.reduce(0..get_last_layer(params), params, &run_program/2)  end).()
    |> Map.get(:severity)
  end
  @doc """
    iex> Aoc_2017.day13b("0: 3
    ...> 1: 2
    ...> 4: 4
    ...> 6: 4")
    10
  """

  def day13b(input \\ Inputs.day13) do
    input
    |> String.split("\n")
    |> Enum.map(fn l ->  String.split(l, ":") |> Enum.map(fn s -> String.trim(s) |> String.to_integer end) end)
    |> Enum.reduce(%{:curLayer =>-1, :severity => 0, :caught => :false}, fn [layer, depth], acc -> Map.put_new(acc, layer, {1, depth, :down}) end)
    |> clean_run(0)
  end
  def clean_run(%{:curLayer => l} = map, delay) do
    map_new = Enum.reduce(0..get_last_layer(map), map, &run_program/2)
    case rem(delay, 10000) do
      0 when delay >= 10000 -> IO.puts("Delay #{delay}")
      _ -> :ok
    end
    case Map.get(map_new, :caught) do
     :false  -> delay;
     :true -> clean_run(%{map_new|:caught =>:false, :curLayer=>-1}, delay+1)
    end
  end

  def run_program(_turn, map) do
    move_packet(map)
    |> check_scanners
    |> move_scanners
  end

  def move_packet(%{:curLayer => l} = map), do: %{map |:curLayer=> l+1}
  def check_scanners(%{:curLayer => l, :severity => s} = map) do
    case Map.get(map, l) do
     {1, depth, _} -> %{map | :severity => s+l*depth, :caught => :true}
    _ -> map
    end
  end
  def move_scanners(map) do
    map
    |> Map.drop([:curLayer, :severity, :caught])
    |> Enum.map(fn {l, {curDepth, maxDepth, :down}} when curDepth+1 < maxDepth -> {l, {curDepth+1, maxDepth, :down}}
                   {l, {curDepth, maxDepth, :down}} when curDepth+1 == maxDepth -> {l, {maxDepth, maxDepth, :up}}
                   {l, {curDepth, maxDepth, :up}} when curDepth-1 > 1 -> {l, {curDepth-1, maxDepth, :up}}
                   {l, {curDepth, maxDepth, :up}} when curDepth-1 == 1 -> {l, {1, maxDepth, :down }}
                end)
    |> Enum.into(%{})
    |> (fn(new_map)-> Map.merge(map, new_map) end).()
  end

  def get_last_layer(map) do
    map
    |> Map.drop([:curLayer, :severity, :caught])
    |> Map.keys
    |> Enum.max
  end
  def day14a(input \\ Inputs.day14) do
    Enum.reduce(127..0, [], fn suffix, acc -> [input<>"-"<>Integer.to_string(suffix)|acc] end)
    |> Enum.flat_map(fn s -> s |> knot_hash |> String.to_integer |> Integer.digits end)
    |> Enum.sum
  end
  def day14b(input \\ Inputs.day14) do
    Enum.reduce(127..0, [], fn suffix, acc -> [input<>"-"<>Integer.to_string(suffix)|acc] end)
    |> Enum.map(fn s -> s |> knot_hash end)
#    |> Enum.map(fn l -> String.graphemes(l) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&hex_string_to_binary/1)
    |> Enum.map(&to_row/1)
    |> Enum.map(fn row -> Enum.zip(0..127, row) |> Enum.into(%{}) end)
    |> (fn l -> Enum.zip(0..127, l)|>Enum.into(%{}) end).()
    |> count_regions(get_region_map(),0,0,0)
  end
  def get_region_map do
    Enum.reduce(0..127, %{},
      fn e, a -> Map.put_new(a, e, Enum.zip(0..127, List.duplicate(:false,128)) |> Enum.into(%{})) end)
  end
  def count_regions(grid_map, region_map, 128, y, count), do: count_regions(grid_map, region_map, 0, y+1, count)
  def count_regions(_, _, _, 128, count), do: count
  def count_regions(grid_map, region_map, x, y, count) do
    IO.inspect{x,y, count}
    {new_count, new_region_map} =
      case{grid_map[x][y], region_map[x][y]} do
        {0, _} -> {count, region_map}
        {1, :true} -> {count, region_map}
        {1, :false} -> {count+1, find_region(region_map, grid_map, x,y),}
      end
      count_regions(grid_map, new_region_map, x+1,y, new_count)
  end
  def find_region(region_map, grid_map, x,y) do
    case {grid_map[x][y], region_map[x][y]} do
      {nil, nil} -> region_map
      {_, true} -> region_map
      {0, _} -> region_map
      {1, _} -> %{region_map | x =>%{region_map[x] | y => :true}}
                |> find_region(grid_map, x+1, y)
                |> find_region(grid_map, x-1, y)
                |> find_region(grid_map, x, y+1)
                |> find_region(grid_map, x, y-1)
    end
  end
  defp hex_string_to_binary(string), do: hex_string_to_binary(String.codepoints(string), <<>>)
  defp hex_string_to_binary([], binary), do: binary
  defp hex_string_to_binary([char | rest], binary) do
    hex_string_to_binary(rest, << binary :: bitstring, String.to_integer(char, 16) :: size(4) >>)
  end

  defp to_row(binary, row \\ [])
  defp to_row(<<1 :: size(1), rest :: bitstring>>, row), do: to_row(rest, row ++ [1])
  defp to_row(<<0 :: size(1), rest :: bitstring>>, row), do: to_row(rest, row ++ [0])
  defp to_row(<<>>, row), do: row

  def day15a(input \\{634, 301}) do
    Enum.reduce(1..40000000, {input, 0}, &calculate_15a/2)
    |> elem(1)
  end
  def day15b(input \\ {634, 301}) do
    Enum.reduce(1..5000000, {input, 0}, &calculate_15b/2)
    |> elem(1)
  end

  def calculate_15a(_, {{a, b}, count}) do
    divider = 2147483647
    a_m = 16807
    b_m = 48271
    rem_a = rem(a*a_m, divider)
    rem_b = rem(b*b_m, divider)
    <<a_res::16,_::binary>> = <<rem_a::little-64>>
    <<b_res::16,_::binary>> = <<rem_b::little-64>>
    case a_res == b_res do
      true ->  {{rem_a, rem_b}, count+1}
      false -> {{rem_a, rem_b}, count}
    end
  end
  def calculate_15b(_, {{a, b}, count}) do
    a_m = 16807
    b_m = 48271
    rem_a = get_gen_value(a, a_m, 4)
    rem_b = get_gen_value(b, b_m, 8)
    <<a_res::16,_::binary>> = <<rem_a::little-64>>
    <<b_res::16,_::binary>> = <<rem_b::little-64>>
    case a_res == b_res do
      true ->  {{rem_a, rem_b}, count+1}
      false -> {{rem_a, rem_b}, count}
    end
  end
  def get_gen_value(v, m, div) do
    divider = 2147483647
    rem_res = rem(v*m, divider)
    case rem(rem_res, div) do
      0 -> rem_res
      _ -> get_gen_value(rem_res, m, div)
    end
  end
  def day16a(input \\ Inputs.day16) do
    input
    |> String.split(",")
    |> Enum.reduce(dancing_programs(), &dance_moves/2)
    |> Enum.join
  end
  def day16b(input \\ Inputs.day16) do
    map = Enum.reduce_while(1..1000, %{0 => dancing_programs()}, &dance_all_night/2)
    map[rem(1000000000, map[:cycle])] |> Enum.join
  end

  def dance_moves(move, programs) do
    {command, dancers} = dispatch_move(move)
    case command do
      "s" -> spin(programs, dancers)
      "x" -> exchange(programs, dancers)
      "p" -> partner(programs, dancers)
    end
  end
  def dance_all_night(round, map_of_sequence) do
  {_, programs}  = Map.fetch(map_of_sequence, round-1)

    new_sequence =
      Inputs.day16
      |> String.split(",")
      |> Enum.reduce(programs, &dance_moves/2)
      case Enum.member?(Map.values(map_of_sequence), new_sequence) do
        true -> {:halt, Map.put_new(map_of_sequence, :cycle, round)}
        false -> {:cont, Map.put_new(map_of_sequence, round, new_sequence)}
      end
  end
  def spin(programs, dancers) do
    programs
    |> Enum.split(-dancers)
    |> (fn{a,b} -> b++a end).()
  end
  def exchange(programs, {from, to}) do
    from_dancer = Enum.at(programs, from)
    to_dancer   = Enum.at(programs, to)
    programs
    |> List.replace_at(from, to_dancer)
    |> List.replace_at(to, from_dancer)
  end
  def partner(programs, [dancerA, dancerB]) do
    indexA = Enum.find_index(programs, &(&1 ==dancerA))
    indexB = Enum.find_index(programs, &(&1 ==dancerB))
    programs
    |> List.replace_at(indexA, dancerB)
    |> List.replace_at(indexB, dancerA)
  end
  def dispatch_move(move) do
    case String.first(move) do
      "s" -> {"s", String.trim(move, "s") |> String.to_integer}
      "x" -> {"x", String.trim(move,"x") |> String.split("/") |> Enum.map(&String.to_integer/1) |> List.to_tuple()}
      "p" -> {"p",  String.split_at(move, 1) |> (fn{_, d} -> d |> String.split("/") end).()}
    end
  end
  def list_of_moves() do
    Enum.map(Inputs.day16|> String.split(","), fn l -> Aoc_2017.dispatch_move(l) end)
  end
  def dancing_programs, do: ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]

  def day17a(input \\ 348) do
    Enum.reduce(1..2017, %{spin: [0], pos: 0, steps: input}, &spin_lock/2)
    |> (fn %{pos: pos, spin: spin} -> Enum.at(spin, pos+1)  end).()
  end

  def day17b(input \\ 348) do
    Enum.reduce(1..50000000, %{cur: 0, pos: 0, steps: input}, &get_first_after_zero/2)
    |> Map.get(:cur)
  end
  def get_first_after_zero(it, %{pos: pos, cur: cur, steps: steps} = acc) do
    index = rem(pos+steps, it)+1
    case index == 1 do
      true -> %{acc| cur: it, pos: index}
      false -> %{acc| pos: index}
    end
  end
  def spin_lock(it, %{pos: pos, spin: list, steps: steps} = acc) do
    lock_len = length(list)
    new_index = rem(pos+steps, lock_len)+1
    new_list = case new_index >= lock_len do
                true -> list++[it]
                false -> List.insert_at(list, new_index, it)
              end
    %{acc| pos: new_index, spin: new_list}
  end
end
