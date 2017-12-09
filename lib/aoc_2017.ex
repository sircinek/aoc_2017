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
end
defmodule Inputs do
  def day1() do
    818275977931166178424892653779931342156567268946849597948944469863818248114327524824136924486891794739281668741616818614613222585132742386168687517939432911753846817997473555693821316918473474459788714917665794336753628836231159578734813485687247273288926216976992516314415836985611354682821892793983922755395577592859959966574329787693934242233159947846757279523939217844194346599494858459582798326799512571365294673978955928416955127211624234143497546729348687844317864243859238665326784414349618985832259224761857371389133635711819476969854584123589566163491796442167815899539788237118339218699137497532932492226948892362554937381497389469981346971998271644362944839883953967698665427314592438958181697639594631142991156327257413186621923369632466918836951277519421695264986942261781256412377711245825379412978876134267384793694756732246799739464721215446477972737883445615664755923441441781128933369585655925615257548499628878242122434979197969569971961379367756499884537433839217835728263798431874654317137955175565253555735968376115749641527957935691487965161211853476747758982854811367422656321836839326818976668191525884763294465366151349347633968321457954152621175837754723675485348339261288195865348545793575843874731785852718281311481217515834822185477982342271937155479432673815629144664144538221768992733498856934255518875381672342521819499939835919827166318715849161715775427981485233467222586764392783699273452228728667175488552924399518855743923659815483988899924199449721321589476864161778841352853573584489497263216627369841455165476954483715112127465311353411346132671561568444626828453687183385215975319858714144975174516356117245993696521941589168394574287785233685284294357548156487538175462176268162852746996633977948755296869616778577327951858348313582783675149343562362974553976147259225311183729415381527435926224781181987111454447371894645359797229493458443522549386769845742557644349554641538488252581267341635761715674381775778868374988451463624332123361576518411234438681171864923916896987836734129295354684962897616358722633724198278552339794629939574841672355699222747886785616814449297817352118452284785694551841431869545321438468118
  end
  def day2() do
    [
      [86, 440, 233, 83, 393, 420, 228, 491, 159, 13, 110, 135, 97, 238, 92, 396],
      [646, 3952, 3430, 145, 1574, 2722, 3565, 125, 3303, 843, 152, 1095, 3805, 134, 3873, 3024],
      [2150, 257, 237, 2155, 1115, 150, 502, 255, 1531, 894, 2309, 1982, 2418, 206, 307, 2370],
      [1224, 343, 1039, 126, 1221, 937, 136, 1185, 1194, 1312, 1217, 929, 124, 1394, 1337, 168],
      [1695, 2288, 224, 2667, 2483, 3528, 809, 263, 2364, 514, 3457, 3180, 2916, 239, 212, 3017],
      [827, 3521, 127, 92, 2328, 3315, 1179, 3240, 695, 3144, 3139, 533, 132, 82, 108, 854],
      [1522, 2136, 1252, 1049, 207, 2821, 2484, 413, 2166, 1779, 162, 2154, 158, 2811, 164, 2632],
      [95, 579, 1586, 1700, 79, 1745, 1105, 89, 1896, 798, 1511, 1308, 1674, 701, 60, 2066],
      [1210, 325, 98, 56, 1486, 1668, 64, 1601, 1934, 1384, 69, 1725, 992, 619, 84, 167],
      [4620, 2358, 2195, 4312, 168, 1606, 4050, 102, 2502, 138, 135, 4175, 1477, 2277, 2226, 1286],
      [5912, 6261, 3393, 431, 6285, 3636, 4836, 180, 6158, 6270, 209, 3662, 5545, 204, 6131, 230],
      [170, 2056, 2123, 2220, 2275, 139, 461, 810, 1429, 124, 1470, 2085, 141, 1533, 1831, 518],
      [193, 281, 2976, 3009, 626, 152, 1750, 1185, 3332, 715, 1861, 186, 1768, 3396, 201, 3225],
      [492, 1179, 154, 1497, 819, 2809, 2200, 2324, 157, 2688, 1518, 168, 2767, 2369, 2583, 173],
      [286, 2076, 243, 939, 399, 451, 231, 2187, 2295, 453, 1206, 2468, 2183, 230, 714, 681],
      [3111, 2857, 2312, 3230, 149, 3082, 408, 1148, 2428, 134, 147, 620, 128, 157, 492, 2879]
    ]
  end
  def day3() do
    347991
  end
  def day4() do
    "kvvfl kvvfl olud wjqsqa olud frc
    slhm rdfm yxb rsobyt rdfm
    pib wzfr xyoakcu zoapeze rtdxt rikc jyeps wdyo hawr xyoakcu hawr
    ismtq qwoi kzt ktgzoc gnxblp dzfayil ftfx asscba ionxi dzfayil qwoi
    dzuhys kfekxe nvdhdtj hzusdy xzhehgc dhtvdnj oxwlvef
    gxg qahl aaipx tkmckn hcsuhy jsudcmy kcefhpn kiasaj tkmckn
    roan kqnztj edc zpjwb
    yzc roc qrygby rsvts nyijgwr xnpqz
    jqgj hhgtw tmychia whkm vvxoq tfbzpe ska ldjmvmo
    nyeeg omn geyen ngyee rcjt rjuxh
    qpq udci tnp fdfk kffd eyzvmg ufppf wfuodj toamfn tkze jzsb
    rrcgxyp rbufd tfjmok vpyhej hcnz ftkojm
    jnmomfc jnmomfc bkluz izn ovvm flsch bkluz
    odisl hzwv hiasrhi hez ihihsra qpbmi ltwjj iknkwxf nbdtq gbo
    gjtszl gjtszl fruo fruo
    rdapv gaik cqboix sxnizhh uxmpali jdd usqnz advrp dze
    flooz flooz qad tcrq yze bnoijff qpqu vup hyagwll
    lnazok dze foi tqwjsk hpx qcql euzpj mwfrk
    ilb fmviby ivybmf gtx xtg
    rpauuu timere gyg wcolt ireetm safi
    croe szwmq bbhd lciird vhcci pdax
    hnc ykswt qqqmei goe bri wmyai hnc qpgqc pberqf bzs
    hsnrb wdvh iezzrq iezzrq rdbmpta iezzrq kemnptg alkjnp wymmz
    ngw don ddvyds nlhkoa aaf gptumum ugtpmmu
    vmccke qbpag kvf kvf tgrfghb kvf bhpd sglgx
    obomgk bkcgo yso ttft vbw ckl wjgk
    fli qvw zhin dfpgfjb udsin nihz ovr tiewo
    tgmzmph hauzieo jmg tdbtl lvfr qpaayq qapaqy ausioeu jun piygx
    jkp guqrnx asdqmxf vmfvtqb tloqgyo ioix gajowri tmek ilc puhipb
    uycn zxqm znft ayal znacus kvcyd ekv qqfpnh
    fqghur xtbtdd ztjrylr bpuikb ziyk
    rvakn uqbl ozitpdh uqbl dsej xehj
    laxp haz jyd xnkrb ijldth woy xapl iqgg alpx gnupa ukptmmh
    dyiy dyiy ihb qcyxr
    wbwkd hdwu zvgkn hdwu wjc sakwhn zxujdo npllzp uyr uyr
    fxczpmn cininu akcxs ggslxr riyxe ojisxe
    ppbch sampq dnct afikor dnct edsqy pnzyzmc afikor
    jnvygtn hijqjxl vsd jnvygtn nqcqv zns odq gkboxrv kolnq wrvd
    mroq mroq flsbu flsbu
    fyshor xvpaunj qmktlo xoce wkiyfu ukcl srndc ugwylwm ozcwdw mtqcste kpokr
    cfh cxjvx cfh cfh uewshh
    bpspbap bpspbap fquj mxmn bwls iirhvuk dmpkyt exrn mxmn
    tvyvzk ezszod ntxr xtnr och
    knfxhy kbnyl knfxhy xhkssx lxru uprh nkxpbx oodolxr tpvyf
    nblmysu iwoffs upgof tyagwf aan vovji ajk ywzq oyfi sfulz
    aushzkm lcaeki mkuzsah ynxvte rsntd refk pcm
    mgguob gobmug dzenpty gmogbu
    yvq eepof rgnree nerger fpb stfrln ernger
    hrgkbl mzwvswk rsrsbk ieru holco pajvvn ztgsr qkyp fyeg owpcmoj
    fowda gmsqdca yugj mcrroxv mqcbojd fjnqfji qdfsc jqs
    qnc rvjfz vvxk sjd xrma ucdjvq sbw zydyt dfzww
    ocajazv cozaajv tqunkla udwf ecnnmbz lsakqg bki njnda zsdu ccfqw rxpc
    qqm qdfya qxyx qmq qfday uqnfttt
    rnbirb iapor qet iapor hxkhz dfvzig pedl ybyb
    mkgamxg xkniv meb hbzmxjn dhbj zhbxjmn hdjb
    ilteux pyutyfx mau lrr bacak
    sjjonmn dbbbgs crxyuu jztstgd ezb uiabyaa
    tra fle ufzlvf nnaw kec hiwnnlj tei wld iyt syk hjdczb
    qmd jtlud dgh dbanock fzp dsjgqru wwvo jwvxwgv xlemfij jcacd
    rpkx oxesil snazcgx fly miiyc ikmtmp oefyyn egbw
    ypfpeu wldnyd acchppb yqwcaw wldnyd turbz megci nbgxq xkc ypfpeu
    iqqv iqqv neui iqqv
    ypsxm icqyup zyetrwq nbisrv
    viommi toszx dpueq eyy cunjou ffcjc jaeez djefra pxvkj liudlig yye
    fhnacbg jghchh ghjhhc iue hwqmo
    vbjw lpn cizba ltnsfpz tzoweml irewlc uzckhpd mszal obd
    yeos utxkft hflxkfe fxczge qpgigkc ksgr vuumql vhlvv
    xzmkv xzmkv krecdi klpem jsbu nwcmik emfzxf cjmpgnj
    vtkjo pmiv zou gxo qdiyxsf hwyinjk jhkgf rjq
    dyuoc ywiyvch irfgl ywiyvch fxb fxb
    tuz onhr syu rqya abkaf bcfx mbknex juwoor zmksl
    oheg spjorx ksdy vwtq fxz phvtazk tcze lrxg
    hew lbup botaj ltr jpd
    dxgc tzinkej gnz hxvvub adsqmc dxgc asgpp rqbdcra goy pmamdua bhiacva
    xqv ygb kihxqz vyv pjcny vmyvsdv cgsi nfyx
    tqga ssshrw ndq qlbvwh huyd pxbgj qbxk dkkbf jxy chsobw pph
    hxl iwph iwph xnr otifm ljhre
    zlgvpd kapxpoc dve rklk ogh hgnp rbrmc zzkz hhmcx aklmo
    sar gfor nkf hek nkf aql shc aql
    dtcrw kfjzcjx qyhi bldson whwdayo mqtgt xhqzp ttqmg
    omspdml isze jdl nvwo qrkm wztfg ssfgyh dryj jhp unsmty
    jxt cszylng ifht ixtuna azoi xutqlv jtx tjx
    usgm azuayp fgkby ezpyq jqwl ezofj
    tnhvil nrvg moyrpqs sldx qymoff megflxh pyhqwms xmdw
    zomy zcquwnv lzx bvcna yods mjp dgsez
    blklyf xokd gpit tiysj yrwfhm tofx
    dtig vhdp omuj vhpd
    fogwxim qvdwig emdiv jvhl euwbzkg xvxb hwmqo ujdmlp epmykj
    sjxll sjxll pedvgb sjxll
    drvay gtzhgtx yrt okz nqf
    haxfazn pvkovwb pgu tgshw mxcjf pbe nwoymzc mxcjf pbe hydwy jradcr
    prjsloa ahylvj okbsj qbdcdjt pmfo pagyoeg vkmhjzt khzmjvt opfm xfrji gyjqyel
    lzypt jdbtrad ogr jdbtrad heink
    rcoucuq gdxewa rcoucuq whlw zhhm rcoucuq azaqohe mzyli rdvaf
    yuag ebcf yuag nsotg qqzuxr jfmao vyucw wmoye
    qwvk xemm hgqrr wyxkpp tojndm xlvzypw jus bgnu bgnu nklfwhs
    daqi knenmku ccm xkiuy vkexsbc kvvdagx umopitw yaocnx yoakqql mllmsp
    mrxgl gywit mfopia ncnsvw vdxek axuiot rsejua nei prndudz mnu
    egqn gaa qgen urs mix zbn rhn
    ewharq aihy udkdaob kgrdd kgrdd kugbjtj fcef llqb pduxaq wcexmm
    dwtiw nelq hppad algxgf gcc upou akm efnb mxmhrud
    yxqaa ups okbhgt iet qns tqn rnjqxgp
    npmhdm cgds ldexvr typi jyivoqk zkgq vfyxu xgfo
    dkwnmr umm dkwnmr okpjw wqx jpztebl eqsib dkwnmr
    dxbild wpbup evscivq dxbild dxbild geqp ojfbpl jshvqej
    cxdntxs csfocjd pyy tuhws teb boyloz xfw scxh pxhonky
    lteucke xrgwy hszgzu hnyrcvb
    pfgsgwg dxzh fworek qbstod
    usemcrf psczxu gcjtr brls
    hjol efxczux bqdn gvrnpey yyoqse gbam ndzyj lbwb bhzn unsezg
    bapw xifz blupk qqdk bofvqpp wnbuwyt rnwocu lzwgtt zucag pov
    xkre lqvd juf lqvd xio xyg xyg
    tzdao ztheib aymcf aorg iyawrch hetcxa iyawrch czdymc ccv
    ucgl azlppu jvxqlj pest
    dvwlw fuuy mnhmm okrp ualnqlm uyuznba fzyejk yaq crl ctprp
    odfq knox mkbcku pxucmuf lpjpol phl
    ixongh hfs ruorbd auy qyssl kykwcix aytsm rlj aytsm duq segpqhk
    izufsk wedpzh podjkor eamo vqvev ifnz podjkor xrnuqe
    twyfps bmdbgtu qye qkwjms
    wlav htym vhsnu cocphsj mdsuq vhsnu jflgmrp
    opajag itwjhfu purnnvk opajag
    hpkopqp vnj aialpt lzrkzfs nwucez nwuezc
    mcx hzcjxq zbxr dsx tpknx fva
    rlvgm xrejsvn ghawxb efyos xty wdzdgh olahbtn rga efyos vhtm nsr
    cni mbab qtgeiow ulttn rckc kmiaju jvbq emyvpew cdlxldn ulttn brhkprx
    eykpffp rapik qki fhjgdyu tome ehjuy bibjk htxd vexvag
    wrk dpxt gwkuiov gbkif ike gbkif pcd wpj toywyf qzsa aol
    yqwzh uujn ujun ujnu
    srs ralwxrz yxvvmgp sjhbhk waasid cqtxoxf whcladv jkmaq khjbsh dlavcwh
    mdvsjh xaj etvxlsy fxgiy rgjesel rlegesj ptriz ebdyhkp kugxm dxv egljser
    lhehwrs mqevb ygmv gri izop qgb ivm
    loqqam alojlwg hgen hbyw qlwpun loqqam worgnwk kope
    phozre todsknr todsknr ibj mvllsar
    wuripy ruwlfbh wukbkey qhq iishw tvtvci xawvxc vxacwx hsiwi ogq
    xryq vxwupqa zhqex aquxpwv bnvxrba dtbxki
    yvvwh zvsm vqskhp vqskhp ggqqlw bpn wbuv
    kqz tdy goqwge ygn jgd
    szjjhdk zkpoo nxexz ebicc
    wzuemcj oyd qupulju iaakzmt vzkvz
    nppahov umm wpzev wxkgfxd owgekp bhhb bbhh dgviiw kdfgxwx wryb
    bnc rhes lmbuhhy kwbefga bnc rtxnvz bnc
    ani mggxf mcoixh zdd nai hbhzl mes bdpqr
    mjn uinoty jjegvze bjgqg yhqsxbt coj obylb hddude xqi rhfbhha alood
    cbjzj drmihy tfkrhsd nuhav hihzx bvblqpl tdd szmp gjgfv box
    uumhdxd cmwgyf vepr rwqdkj exwk
    hwvr ydvw bqefu kghes gvbhp awms iqsqes khgse
    mrey jqfw fwvzhps komj dayvs fbui zmtd cofn mrey
    dsjds fdpx irjj usndok qcctsvf fgk wvg txwxcl dxs llp zyilwtq
    xmkelgk fdukc cye legkxkm wwly
    enlny eynln cccku brkz dpof mwfoxcd yftmnqh wpebvyc
    ggdn jnysl dsacffw ukj hdae cmzxku
    uqhm gcachmn kxndfrl htmfis jfnajz fiqiypr kekho kekho ndcw ckrndub dejfna
    keazuq ertql rauwl keazuq obmh rauwl ksrotm
    jppp poigqhv repfsje grjk xwkyuh pkx ayzcj hoxzv
    yhjw pcuyad icie icie icie hwcsuy wcd yihjh jnrxs
    gaug ivvx ceb xujonak hbtfkeb ttciml cctoz
    dggyyi dggyyi gqlyumf yasu fwdfa cbb nncn verhq
    rhgcw gpcyct kiuhbg kiuhbg gpcyct jlmleo nhumm
    wulxxu jyjek hclcp ogob viex wiqcupq
    tthu nxgzpid kcnj mss ukapgkp nnc bxjocv qwxs oejwsif aywqtu brahkb
    dtde bgvb smu vbbg zhlu
    lyo nwjjmep ldbok wgxhto wwuh qfgjknk wnsl
    lleyr onha hkwulbm jfg
    bybjwd uoxvbh mvj iqfpnxs bybjwd zqtszp wvc lbazjr zkzenja cev
    rbuyyr divtslq yuqmyt ajyveb smxsjb nlk tzqhq ims fewg wpjhr gqh
    kpewfd beq klilis klisli eeezut
    euqh hueq ldoo crqurv lvrwh tmaewp oodl
    bqi lzrf jyhvxfh bqi jyhvxfh nbztd lwpdn cuzi
    srjylou phavzjd wost uxkaq byh sluryoj
    ihrdk bcegkpq nygrs qbcq wyjg dvzme pgzhjl vibg kvv
    ijsx iedemek ktlz gtga tbal lbki gtga
    vmiaxn kefig kefig vngxz
    vrdmfvi qts vlvhq vlvhq dihmq
    cfz dyrz zlw qnt vok fwvahg skshbqf hbwozdc ntana jdb uflp
    rimbj bxemw sfps krtk umta vnk ewmbx nrlje ymrtqrz mxewb kjxunbt
    egnuti ozat eltl ngueti
    qtcwoxq rmaf qtcwoxq qtcwoxq
    zws gcoa pydruw qsrk lrkybdf ugr wkrxoj nyvf vitwn
    tmr hhd dojid zwrj bhsim righ keqlep flzunou
    lwoquvy acjowxk tqudk oenvioh nyavyl
    rgh dfhgyke iff cpxhuz hui koe iff hui dmukrei
    bjiumig lcbmbgh vleipx sfawua rnf
    gftfh qwb tfdroe xbno qhgofm vqfoe mux
    ljdrr gyfggai iun nju xrucbis mhrcrh fukr obvuqc whlalfe xrucbis nju
    nxjmjr egqwg arllu xqaahri lzc ivt uhsti
    sqiepba rcmts kvesv nvp
    tiksw tiksw rjni gbhvzm ctbq zuqfyvz
    ibsnm kfka aoqigwo sqouih rxz
    jmymq lxio adtmk umyu sxvzquq bporqnb heol fow
    mepa eckq rqviawv dkqoei ifmngpp jiava rtklseu
    yuycd jiufjci yuycd uowg yuycd udq izkicbr csxobh
    nwu tfsjavb rruoxbn oepcov elxf rruoxbn rruoxbn azglwth jcjm ksqiqpv
    dthfwip zqnwa zqnwa zqnwa
    gso wruece ufl crgnlxv vllsm dpyfm wpa ctxko
    wvpze seodz lpq lpq pmtp wsxs ffppx
    yfxquj phvjn rtwieq rtwieq kgxztyu vbjvkc prqqd lyzmdo ojbrt ojbrt qiqjz
    esaezr rpggiy jey kbzrhu uthus osr xxaiijd qfxlf auhzbx gkigoqw
    yfhcj uvgck cds gjhhrg cmempgj yfhcj cjb
    yxi voxvtuw unwg jqqm
    igvjr ljz rus sru gbjtjt qfeg ztu zjl
    leof ocxns hbkoysh hbkoysh leof
    hab lyxmf yhh qeks fwhfxki xmbcak okqjii nfgzyg bhtfgdj lpmjn
    mgognh tad herere lvwnzx ixwqs zphmuuc etdjz kczsf
    mtej rlolsnn zbl uykek dpkan gmz etxtgj
    mihuieo emjgbp jgks mihuieo iexrfw mjdnr bvp mcuzea xkbusvi
    jvqpj bwt jvqpj bwt gxr
    qpnd fpt tpor bibbpcg hmvguez wqc afl ckviua gpi
    dntmcg jglm sxtnu sxtnu sxtnu
    fzkbptw cbfwo ozvwov wbv gcdd izqo ovwzov lolewo xikqpw
    nkxyxzd kpn datf fki werq mwidqx oiibor zizcjph
    xvgyxym zor ijoy lvwsf fjuara idvvq rreit mqyyy ctio tzwqqhj rnpee
    maqkfpk maqkfpk xukg sfdmnlg xjopvr xjopvr irf
    liujcd vnlkouy dxkwc gto vhjvtw
    swhqhj cas aupsd swhqhj cas bvbooii jquck dtdm
    igh iqicicf ghi pcxt srcrjx gmf gyscphv
    drplj drplj wopgpnk wytag wopgpnk
    zexe ilcqoh qiefb txkuv lirfzv
    ovvpn ovvpn uqeurqx uwzn hgmucj ovvpn sjxulms
    rox silka irhsvym kutus otasof tdneav pcagds
    mkja omu tyshbfq onp trxs lxa tftbv bnpl djhnc zdqfs muo
    tjj rmmqas cbbkxs qio pikk ykyew gxlxt nhsyl ykyew
    frcprg njrz oaxcmhc qben pedm ecvtga nzxwpb ior gaklot dpem
    zyt kncau spoe qlchg sqys wkpbng yflju qlchg vkve bzadbpa
    qtq pkaicl qtq mfkfqvr dnleiq brrjxsx uoyxh pkaicl yvmlug
    firwy imtlp ywl qfa dqrbazz ztzb pcsbwhn zesmlag
    ivey ivey mtvc mtvc
    lhize acwf moa cdeoazd voktshy qmvqq jvmuvk ljfmq tsanygc
    xreiqkc aawrovl pofcsg xreiqkc xreiqkc
    cjbzvn ozds iniqu sdoz gqmki bablvll krs vjzcbn
    izsod htkeqz entxn qtns prpcwu omfnmoy
    kwfb tctzda aztctd tadtcz gyt wunbcub ydiwdin xxk
    epnl ijcp giq ltfk zjcabve zfksmz epnl giq xxxbsom
    ulyukpa mdjsbn dydko uhkdt qms aaaj hustlwu
    zlsbu ohx jcwovf egf zlvpqgx qhejm wrywdmw
    uhxqrzr mmu kjxcalj unuohiq rri yzngnb ikvlxry mfiym qbksdx
    khqciz som yklmm jceb khqciz jspy jceb
    ncwggv njvi nqox krtsn lnm
    bgtqme xaxcoq qbtgme obqual vorfk baoqul lgrb
    jli tsbb nlxjc pkwzmz dlxrj hmho gzguko ilj iyaasm
    wlmw grkumg dynwtyo emxhhqr huluk slpqu uhqcmd absmr ufirmwr
    pbs pcammxv dplfr tzvmav nccyy blvyq ffhnz bccutq
    hgge ghge vxmvz hqxgjdg zab guo gheg
    ylj bucoyoq udndc wpgyrbx ueh udndc gxdsdh hdoz wwgqlg
    cjdeh gttyqe kdkm ltzd lfeozse quvjq mnwhokm kdv oojxm nxt
    mfkzus knqxt saxkqww njx zumsfk sbmcyad cpt agvbuv
    tukn vyco yobvsn bzgnn klrnzy kea thzk pxpwq ryfff nxzm
    ylbm lxlz lybm lzxl
    wgtxoij zad slgsi cvnxfg iomswwl vmx
    hkm yinhnkj kmh kwkw kayknck chur styjif yknakck
    rtfwhkq rtfwhkq zsf zsf
    sldq zlntr ueegiw kajivqc ozcbm ceft snvugom pdyc elppeed nnqrp prwwf
    lhk xjonc muc tudag tsafx mmivb dvrjbp qgrew
    hnzer fbgqp aazta aazta lxaz lmgv aazta
    victgxu victgxu mlpd ummrnbx cazjgnw isxcyp efy zfa cyusj
    gyojxo onzq gyojxo uxufp awi ilhl wefwfxr gcjlt tmliynw uxufp pdcnxah
    wjwachn xkuhfbp oky oky ybaeqkr rbuix yreoaw wepmye brvon aasb
    kiidorw vxtxiqx wtqvbrv efdth isel qbom vcssyc vxtxiqx wtqvbrv riafzsw mqzsj
    eurpjd vkhdamt tmfx czeoot hiz ykz lmixzq tfur jhzr
    ipuftpj qbll sqkkdw fwncmiv bri oeeh lehd ioh wag
    suima nanngc imrmc krq atxdo woy atxdo akev qlr aezco qlr
    cfc efwbzck ozkmcxv moczkvx ccf
    bnekky iakrk sask uwgnjp iyi rynev bdnas ldh kass
    sicmw vvjbvv cap nsumc xgvrlm wsoo uoqdu psykckm
    ugg mtr wnzhmmh tjxc ehwnji lwhu mdsckk yvmk enubrqo
    grb oxmxz ohu ytetedv ssx apzlppg fdkamm sxofc jdt ynmu wyejok
    umoep rbyqm eqfk twqnog cptbbi dragna ngqs ffb cexxnc rbyqm
    utizi ormkel wvwur bdx ecelqbv xiccama aag glfvmj
    znb rsuqoa uxo svc
    obs lbifa cffi catpd
    qkxwian ajlzjz wewduzp bbyv qmt fsr qgiu epinp ghmf
    hatg bfgmb aght ghat
    kuq inp dun cknbun wmwsu drlmmg kyxc bdl
    bddybth swdbf jhi fva qpobio bjwm wjaztp jywi
    mgckz vhveu zkemhp zdf xtiqqew mlx wazgd
    umbjq pya lvvxf jeavij rhrxvew bwjqgpr piz
    xaycpwo vjcuc qksc yuixhni sfbfb dydyaq gdfvb tggg xidphvf bpjdrl goskxym
    agxfoip gguif wvo agxfoip ntkbaw fbyggy ooft zxih
    nzvsu ffwq uxvfbl qrql olhmhom qhdltg ymwz krtndtx olhmhom nfsv krtndtx
    qdp jqk ustz xjripzv mnk grnodk pjwdsj uug zqxjqj
    mufrcox zunisfs ocvcge acamm xua vor bsde kxr vor kxr orccxx
    ncycbp anvcxay bmm wndmeaw oso knmk mmb wamenwd kmkv ppdd
    motdcn xzagzwu vuzt utffrn yuqxzrh uvzt ujttq
    tauoqy coiy ybesz tauoqy wpmr trquyne ahxbj jzhems dsdy
    aczq ypw pgmzz srfn quatjgf
    cih ypapk bfxvr euvhkk gugru auhqui
    vyf pssgfvy dnhvbfl xpacme dnhvbfl mzdv iynq hcqu
    lbzvbu hhxiq hdfyiiz iyzihfd xhqih uzdqyxr
    iapbdll vdr cprmrkk vdr dfjqse mlry flpqk vdr
    grrfkq xcpxd grrfkq dxc bjpr prvwh swoc swoc
    bopo chvwuhf qhd ieesl xey ieesl fnjcbe
    kic fyq hsucnu agwyl pzzmd hqksh psw
    mxf uau iti lcoz lpg zbu ocre wqlocmh mxf nidqj lcoz
    bypmix ptzxgmf xmtzgpf hrvzzq
    lbfw zwusma lbfw tuyyy
    lrf uej unswvh obgsb npbl zajr kenea uej qnyjcu wzufim qpzkgya
    qcrxj llyu kligt hlm ehwtbx dda lgsvhdt xewfcv uikn
    nfzjx izqdbq mfbxs imiuc yqxb xlmvix izqdbq eflqfq wku omgtuu izqdbq
    lasdwg hiy btzt eefd eyoep icn nnmhg otml rek luixac nyzgn
    vekteds utsuxdx utsuxdx vekteds
    feyov qrij zbebwg ijrq seplram wttkwm zewbgb kzuhuh
    dmkgtv wohgqo ddtqmv zatahx mym hqowog tkmvdg
    vhha wjrmuyx kqh vyyrj xzchbi ejsdq orlxg vyyrj dlrc
    yetngqn zdtuqox hkarjei fqpsgh eaqwbg zsssog ghb gddqqzr hbg
    obldb zsrhz zxp uxphnev mwnbc pfjft fms xwslk vjm fxy
    nfij dbfykv ttq gyjgac igxuyqi gtiioqx ilhdex dbfykv uyp bdiwya gqf
    pffzruz vogfosh dcs wje
    pohhf fhpoh oon yyz
    xxuam afwm qxl lnt syyr bwxhhf sozauq shlhfmz kwnn milav ochq
    wefcqrt gejw cwerqtf fttf gjew
    jfsvnmr osca epwtle pgfif sxom
    exlfzmq nakp rgdnx rrcvth vhrrct aajjdrt ryyg dsozd jdqlqj pakn iruv
    rmcvo txszcs xxhyxz hbsozk wshkocf rmcvo rcbnt
    kitz yjgney yvkymef nauj hmllsgl kyhm kqr pzsu rcf pzsu qpte
    cdinpx bfur mkj naz ihkheyr nohhoe
    ylris xeqcgup wap bbfih tgfoj
    ina gnlnm zyeqhij cudfuf ipufae bvkdzni aat teqsg cudfuf bjokrbl teqsg
    aedx edax dnfwq qndwf
    rdngdy jde wvgkhto bdvngf mdup eskuvg ezli opibo mppoc mdup zrasc
    qcnc iaw grjfsxe gnf gnf
    zbjm snznt zelswrk gkhlnx dqxqn qqxnd dmro
    zisecvx ztezof uzbq otnrtj qsjzkwm ewvcp rlir bfghlq tgapdr qxmr
    ipnqj opjf vabyoe wkwnd
    wyf mfqxnrf apm snarf jqu aaghx pwecbv lvghayg
    acncv jmmbwlg oiphlm ifuo cvt
    pvmb egansnd zmh gcuzzci rrxpslv ubith
    uoleptg xbouzn xbmg cfh cpn wpqi xbouzn xtxis sxzpns
    rilybri kurbpq vfmjpck tjyogho hfyxad svfofx lfbbhxj khaerfs iqr
    seaebgz wlmtkre qguv qguv wlmtkre
    sgo edkxya zdqgwtt gxu nibuu rairqoq mzxli dci qsv
    tsol mdhzqr rmaqnru ggvcq arbwkn hlkcnj ljkcuof
    mmliphp ocup puoc eijjv
    gmajqpb ijki ijki kvz
    pmqss unhlpcj dlkll nuhlcjp expe tlurzmv nsy vlumtzr tgseozl
    gkvaoni hsba hsba viuedv phyoclp fdq phyoclp febld nqfs
    rxvdtw abn pntv qrqfzz slsvv abn lrxix mnu npot
    ghlfjp woy xwkbmv bkahpkj jve cncvk jvdype fwgvoju yrkwjp gwfvln mvkv
    kmluh mie bby fwer chsinb ojglqr nqk mie
    yzmiu igkgca ybnsqja jpfejtp yjddy xsosxfi ingx qwuhb emrkwpx idqjmmm
    btrllw mphm dkvo ewdl dchcul yah btrllw kmqi mtvgk wtb
    hxsgard yuikc lykt tdee adprp gpougod klnzk mzsmlb
    hdn znblw ifoblur bwzln dbv
    smofpbs vjuyiro llk lfzesga tybu tybu
    gffnpug xaup iqiyz fjkpnkz drrk fwyxw lwzfskz gslwpmv vjxylva tbkyo nib
    evydmb nhwuiiu fkerq nkgbuyy uclrs ydjgglh xhotwbm riirgzt
    bsub eavbt uvd dpzwyt rhn khrbptt xszckc djnfxju axofhat powmso nvdffrv
    xtuykl fjz mbikc xpnx hmey fjz fjz
    rkls nwdcsyx rkls rkls
    tygml untequ ybdfumz nqffbq uipc sove hfnqj
    ytecew vven koqn royynd qsn ksl qsn sdw
    hknlw qwho whoq oqwh
    lzmmtqu qvhyeo cnofuj utpwkjz gnirz yhhu aodbnd
    zsr axw kwtzcv tydzo kwtzcv lkxsm
    rbjtqe nihifd gvdxd bpxzy rxteky vgcgllv vbbua anygiup rqo
    dpd wblfwp wblfwp wblfwp ygahc tqjbaq
    gsw gsw pacgj xmrcz zmxhmch xmrcz
    pdq rhe xqmq lgpkhg fyffrot ovnqh wle
    tbjavke ypzzrj jizx gdxoh icjsat otfh fmygumv
    snch nxlgjgp jeyn sxoqfj jtage jtage iuice
    rtb coefuj grwg grwg rtb krhqnma vfhgbr
    vhegtl btorwxg szcev kbvkx itsk nlzpbed
    hiukrf ilzkm yllhh xsgwkdp zyy kjbv
    rfcg tdorci zcj wzftlv rfcg rfcg
    lgbc lzizat vsno pau nvv vsno bbr lzizat qhtb gwp
    sfwnio tcugjk bsfsz ykyfwg ibkap fsrvy mygk kzunawx zyhyh
    mpavlh qps bylh lttjkz rqabgk vewb bwev tlzkjt gzrbxga ktmso prpkj
    gpf ims ynh ffrs vpa iemp gofh cgbauje
    secys qks mcnfhwh drog kqs pajy zoltkw lfihnb myb ioxptu
    ytq nrta ouk ajqblf yuwwcd zdy blyoxbw dakk nvgi bzrhzaa
    nkoych sufiia xkdvw crtldee zycl qblab egqhr qblab
    nllno muxaf vds qjnitmw zkpj wskyhft kmqct xamuzpw qcai cdjtbt kaxv
    qzdytpe osr fuw osr qzdytpe whperd rydwdcl knoa
    zkdznhd peh duoygr zamrgl irnvj otpe pltpq jdkecg
    byzgw rece iigdug ehif tpgje
    ccnn foqdran gbctca tefdjxh ntcr rjciii xip xlss crl wvvhzqm twyohf
    dqyii milqqc qjgkojp qjgkojp ryde
    tdkyj tbrcud tsba vqtmb cjwxnf
    hqhmq wemvrce nagig pwnw nagig epg nagig vlsi
    tqgvw luoplw hccti npjm rytdruq cylrsun rytdruq vjsbjl rytdruq ppti
    itgt tuwc itgt rvp itgt tigns eipl ksmru
    pdw wdhtkn nbdbpn wff zhuuipg rvemv qxr
    qgkwdq cjilayh ymeks mrpuzai dwgs stfstgz ucvqhb yout oiq
    vpxik ypfr qytimvu qms oxbmw ppyfx
    fwwidn gdhd pyuexk snsz iwndfw
    lfcb sllxjna lfcb hpzahfg mmvgaa svny jhuzd
    unyg gicmzd fwc spkciy toyq wjupckd vzzx iuqgka ytqycb pxsufj
    goj tnrcml eyizngj txa xrkiw zvu igduz
    wek xrrlkna clyof rrlnxak
    cjm rmyuku vjom gtf
    buk cfae awstd dywgqp hxo wcxvf laihqw xdqfes wdbh qceh uzlwj
    sudguo dxwplto rlebdh bkamu dxwplto
    crwkyxm yuz kjtdhom crwkyxm
    trhc sduorxr aizfryh rsudxor gbyc
    pczkyl bptp qnn nxmpwsx udrg hhlb rubtrmx twzodlp xygnht
    jmqct cden yfajtkz fevcw sxonbxz sxonbxz qkzkm hhngr fbv
    sdsnm mwvicr wypfi cty ndbowr woiz mrauwzd qlno mwvicr
    vteyo fng lvr lxytn txpj milg
    wjx ahtmgo cgwcaj kaxae fhlvlqf
    ezj eetqhzu upwda iiefwlk vyvby
    imalvy yeghqe jwcu mvrod cwju
    bxnmsa yhfu npsdar tsbri hfuy sirbt oofxmy
    fkndt elbjtn vepqtxt elvpf fpelv bzkgag qttexpv prblwb
    rmq iqs yvprnyy iezqrzm wlqsrr
    yviovq lekxghj oey qwhzj lxknxw qiyovv ksnt jptz
    tyrg cifxt hugqf tyrg ffuiv jmax qyw fozfosq ffuiv
    nmg rsl jpzazd qbtlf yxqtsj czwmdfd bamge lbjdof uqy jssc
    cbx boozjip pwgvzlq rjz kxy kxy hszacok fvsq jhnir cnsba gafz
    sbcuxb wfur nnnfqjj fdwg huhe sbcuxb
    icwk qelbxs uevp qped zsnhh wpuok wddxsln ftnzupr ruxol cgxjb jbhh
    izcp htykj xxmndoq amnspe htykj
    vverol oixwlny vqd tvfzu henc gnyrwr
    ytxio etytsx choynep zqapo hfjit
    lkvgr oyzfa taiqr jok djatvy ckif tmdw oyzfa zroy
    jlgpyp kkqysg oqjki hjohoug hbhta muilz zft
    sumfyu wftcu bwwdcy lezimwa qwvxv zwh mqyv bmfot aii torcol rnt
    tpdj xrw ccsbnh fhptv fwkxjfm dmqaokd bjci
    zxi vmf vmf dpyg
    sfzxysw lcms bkojtv bkojtv
    opywo qll ipkitr mtwp tudrr svhyp huz bxsdpn xomfy
    gkod luo qrosbp orbd rpsjzyd rlh gdok tze
    nusiuq nusiuq zeys ahufexc
    veno jntg avtmtdn qojxru zegdcql odfcetz pgehau
    uqun vigjm ykac ozlelj danmji bibugox
    rpuozh ajwru rbvuevv uhzsq
    iawoe tyb aewio ymf byt inijv ctu fcys micsgzl pbby alt
    gktyxp ris mqpfm bkqsfl nrg idbbcxg jhcf
    qibt invvv qibt luitx rnm eby hrfbmwl wnap sgkzvb qlwc hrfbmwl
    jwkv qecsjbw lycgldd wjvk tjcp dycldgl pzrvr zrlcf kji
    nzsrmiq nmhse ilivrk kqv
    besmyzi imkgpt iekbjax abxeijk uvzs wwv
    jdocl uki ltswp tjkljc ymce iuepze qygqxzs tei lkry
    hhyfy gvzd mqksxlq czn afe mesnag eep frwgekg mqksxlq phpy
    ehg connnza ekt ddgokw
    mpbsoms uzhzl xevww ztt uzhzl
    lftybr firc awsud dsxdkk ltf ipjv dtx lcymth
    vkcpb gxtxq yioeq fexj xxgqt
    srvca fslnnvf nfmkpvt egw wemumq jie vznf dzsjw cukf kcvyir
    yxjkl lyjkx jyxlk kgc xtz
    tpoe xzov csp leleoqo noyre tdhf cyib sjgtdx raehdw nmcxp
    qvt uhznqe bpvos vtq ddlebtd tqv
    xlw utsxs gpia rvlvnts elkxr dddihy tnrslvv ibf wlx bxg
    cwqnnrt rkkqyf dye yde fzl pthanj
    boc rqjenpp xjqte jteqx pvoofc pidqe ruoucy gvnro ognrv
    qhalb gnazwc fhl iuti
    clnbjfo nnfs nnfs heymvr oarew oarew nxu
    lwtrotg hiaxwj ymzbly nvhzjhj zlsaheg nvhzjhj ymzbly
    rrvi tsjp tsjp tsjp killji
    rpx hiclj cmwq ibhj nfd
    pvwymn iebkd xmpw vuhhkap ksw zigzy mzzyyxy rmuh iwwhea cglfq
    rlwelgy sffml jin qsdzro xlsty mgqzuu etxjuo emzd jgnoyq tkjuy vfvb
    tkctdj hhkuc viskmy obw
    zvjkuj akeky ikj jqd hfhzbwe bkc
    btev nrdo hcyiuph stf qharfg vpmel mpfz nvs ytgbbc
    ieepn ndueuw svmdr tcvumw mceyrn mrjwhyl tbdj mgrgvz
    uxrs ckyi xpmqm czzrkl cjp
    nlliwd wrqkrkz yjmng nlliwd zirde hcjjn wco ysf mgl
    dxti lcahe ommare izlwf ramsfb nzgfvo ijvm fwymrdu bndq
    isxy jpvuzu tdduyhw dixp cfa fkzbteg ytoi kepk ysf yqcpi
    qmeprfj soqo ncgeor cqsuuj grzy wogxy vyblnbg slvtry vdols kka
    ltykfp gtzl olrp gxend vapee deq
    emywfbn dbfiut rkt wvwe dbfiut bwffhea yuzcxv gogpicp wvwe
    vqvmrp ofbk dlfabd jwllzxk obx vqpwjj umvng tqwis fstxy fstxy
    miha zgvyux rmraszo xwf
    kjaagk btm kjaagk wkewjrg kjaagk
    lbmli aizs omrdr gzktnx asiz ptanzpa xlo ljre ckyb wob
    svz dlk rijagg avxmg fkzwhk uro gegm
    dzplum temdw jqnm tvxcww bmg tftttpp deuw comxey xfimzjx caluczi nqn
    uwvhxa ztkd nlsdyt vihl julkwwv uzch dwakhs
    wkhuihh ycrc cxff vzcfhpp uegfd gaok kcnvz lhzogq lwa tyrypvu
    idp zmrrzp zmrrzp nktp xsnx rjsxn
    eybrnib ivgntl vaxsbpi eybrnib
    nzvnq xvbfa pbhwwh ylju runvsj imlx vztesn
    nfdohd nfdohd gtevnky pivjyct ihvd fzcsrq lko fmqk
    kwpkks ecikxu bcxswlt qvrxm sbcqmh
    kdjrmj piuh kdjrmj vnaf gyedkg vptxgm xezssxx zsg qjzpo zsg
    oqo sley aqx qmpqb fgmylbj egd zivj kepxizv kuakyn lunbnd
    hmcf hmcf xlhgc hmcf cdlm buofnx
    onjcj yluonz kzmk phqo phqo phqo
    ohaafy efl bnkkjww wwjnyoj dxeaig ywnjjwo slk hrbebw ohlyju elf
    msohiqz aunk njki bfktdgi htmyrj mgx
    numlzrl rmnlulz glb ltt fhbajz gqxpu
    gko hco oai ryq xwy sdqosft spjkiu cxfhg ycwpglh noy rah
    btzpjem brpk vqr atxu rhlh rqv jmg fvyus
    phmxxgj ejx xje qtk hsb kqt npwj gqt
    hujyjp nwmsd ant zipuya lrkahww uwqal vzlo qmbo twkjkse ufivi
    zfbnyz fwvh xrnrw usn zin daq iwjzj
    yykyg iwypfy hehqnl cjvk cevdrec
    gui muuto wsta glqmx gfo rdmbv mxwz gffzt eejpw gion
    lpng nduid iqbpu nduid knrqd
    xwxn oefpckv gjaua ugaaj gjuaa
    qxk aeql trqdmqc crzlinj crzlinj trqdmqc rijcne ewyf
    rfv qmbe fvr bmeq
    upqyfw lowzq wpen upqyfw gfskbil sljuzh wpen
    bdcara qyhx rtaez qyq gbyr
    evzls qxtxq clzd svbgqi zxlzgss vtrre fko eebo qjyl
    zaapeo kpwhz tygknau nyd pch trp xqe
    ypzcafg rnqmbh qtteg sncu ssojhhm zonfym thir xmgheb wqj gpjg ssojhhm
    wvcwyn xrf muozyya lasdp xpjgu kpqv zkiihiv ifje cbdlavg xbied hfnaa
    qqqb rettz rycukl ihpkhh
    dnxzxqv znb znb fbxj azxtezb xvxa
    peqkd xlzqkov esgnw ucku hrwpfxd xtd vnig vlmfp ajte qswr kqoj
    dpwy oavzkk dwyp ehij upqxgii pydw
    amfc hfv xmqa nqvn cal rqmcq oej amqx cla ntxj
    hqhhe qkbhwli wmhlcq xaczs peywuo
    vcr xfv xfv kymo qpszwzo xfv
    nmrbur tswo xbo ljlrzo bmhpgc pev zovkznz lok wbbhtkk
    tojj lxqgr rhjavrm ndsdup gdbjwaq cqpnl wfaxivl rfry ryfr udspnd
    beffod sknlph amb feobdf
    mldgn jxovw yuawcvz kzgzwht rxqhzev fsdnvu vluuo eycoh cugf qjugo
    tlnd qcxj ker fdir cgkpo nrqhyq raef uqadf iahy rxx
    mhvisju lhmdbs tcxied xeidtc ujry cditex gvqpqm
    cgc jazrp crgnna uvuokl uvuokl uoiwl sknmc sknmc
    rvbu czwpdit vmlihg spz lfaxxev zslfuto oog dvoksub"
  end
  def day5() do
    [1, 2 ,-1 ,-2 ,1 ,-3 ,-1 ,1 ,0 ,-4 ,-8 ,-7 ,-2 ,0 ,-2 ,-11 ,1 ,-2 ,0 ,0 ,-11 ,-17 ,-18 ,-1 ,-12 ,-21 ,-15 ,-24 ,-8 ,-5 ,0 ,-17 ,-8 ,-5 ,-24 ,-16 ,-16 ,-21 ,-5 ,-7 ,-13 ,-11 ,-2 ,-27 ,-29 ,-38 ,-2 ,2 ,-27 ,-10 ,-9 ,-32 ,-3 ,-1 ,-6 ,-50 ,-21 ,-47 ,-47 ,-16 ,-48 ,-19 ,-53 ,-25 ,-57 ,-42 ,-64 ,-21 ,-59 ,-3 ,-51 ,-66 ,-44 ,-42 ,-45 ,-6 ,-18 ,-28 ,-18 ,-48 ,-21 ,-15 ,-4 ,-10 ,-49 ,-72 ,-56 ,-47 ,-41 ,-74 ,-38 ,-60 ,-28 ,-10 ,-32 ,-1 ,-9 ,-40 ,-10 ,-6 ,-58 ,-92 ,-8 ,-94 ,-99 ,-93 ,-33 ,-31 ,-84 ,-28 ,-39 ,-105 ,-23 ,-76 ,-35 ,-71 ,-100 ,-102 ,-29 ,-86 ,-70 ,-30 ,-8 ,0 ,-109 ,1 ,-22 ,-24 ,-92 ,-21 ,-103 ,-127 ,-67 ,0 ,-68 ,-31 ,-71 ,-111 ,-26 ,-123 ,-39 ,-116 ,-15 ,-86 ,-85 ,-137 ,-127 ,-134 ,-145 ,-29 ,-123 ,-19 ,-43 ,-152 ,-122 ,-148 ,-129 ,-97 ,-39 ,-28 ,-49 ,-93 ,-110 ,-103 ,-130 ,1 ,-114 ,-146 ,-99 ,-128 ,-118 ,-32 ,-48 ,-115 ,-155 ,-26 ,-37 ,-65 ,-48 ,-71 ,-6 ,-137 ,-178 ,-111 ,-139 ,-127 ,-160 ,-172 ,-98 ,-38 ,-156 ,-11 ,-62 ,-187 ,-53 ,2 ,-117 ,-3 ,-31 ,-143 ,-41 ,-47 ,-169 ,-162 ,-158 ,-12 ,-69 ,-114 ,-180 ,-155 ,-125 ,-64 ,-176 ,-184 ,-202 ,-116 ,-74 ,-98 ,-205 ,-84 ,-152 ,-54 ,-102 ,-165 ,-138 ,-140 ,-180 ,-96 ,-98 ,-109 ,-81 ,-199 ,-137 ,-56 ,-74 ,-179 ,-175 ,-114 ,-124 ,-15 ,-234 ,-219 ,-51 ,-41 ,-144 ,-134 ,-161 ,-59 ,-128 ,-71 ,-22 ,-165 ,-222 ,-70 ,-65 ,-51 ,-43 ,-86 ,-198 ,-238 ,-119 ,-31 ,-195 ,-87 ,-102 ,-30 ,-73 ,-76 ,-153 ,-238 ,-8 ,-73 ,-63 ,-148 ,-42 ,-16 ,-228 ,-243 ,-235 ,-160 ,-107 ,-235 ,-29 ,-188 ,-202 ,-42 ,-215 ,-159 ,-134 ,-172 ,-263 ,-188 ,-124 ,-34 ,-206 ,-15 ,-138 ,-184 ,-20 ,-32 ,-271 ,-103 ,-203 ,-129 ,-177 ,-69 ,-107 ,-265 ,-68 ,-299 ,-161 ,-148 ,-182 ,0 ,-207 ,-106 ,-68 ,-92 ,-53 ,-52 ,-288 ,-3 ,-211 ,-143 ,-204 ,-126 ,-152 ,-106 ,-232 ,-153 ,-234 ,-62 ,-124 ,-131 ,-42 ,-297 ,-332 ,-188 ,-115 ,-100 ,-173 ,-52 ,-115 ,-296 ,-301 ,-312 ,-292 ,-2 ,-321 ,-178 ,-174 ,-244 ,-309 ,-161 ,-346 ,-251 ,-157 ,-325 ,-292 ,-159 ,-95 ,0 ,-124 ,-69 ,-324 ,-223 ,-89 ,-359 ,-242 ,-239 ,1 ,-39 ,-204 ,-287 ,-142 ,-123 ,-363 ,-218 ,-197 ,-136 ,-20 ,-304 ,-281 ,-83 ,-7 ,-129 ,-315 ,-76 ,-349 ,-141 ,-318 ,-369 ,-346 ,-161 ,-141 ,-110 ,-279 ,-5 ,-86 ,-348 ,-59 ,-255 ,-266 ,-355 ,-110 ,-14 ,-339 ,-109 ,-44 ,-38 ,-10 ,-164 ,-214 ,-265 ,-412 ,-72 ,-413 ,-271 ,-343 ,-124 ,-352 ,-304 ,-124 ,-381 ,-258 ,-8 ,-235 ,-288 ,-27 ,-296 ,-179 ,-392 ,-336 ,-255 ,-114 ,-15 ,-407 ,-296 ,-29 ,-352 ,-419 ,-190 ,-308 ,-2 ,-430 ,-157 ,-379 ,-220 ,-179 ,-77 ,-337 ,-61 ,-48 ,-64 ,-197 ,-408 ,-284 ,-84 ,-409 ,-243 ,-316 ,-77 ,-77 ,-428 ,-432 ,-182 ,-437 ,-254 ,-50 ,-260 ,-301 ,-28 ,-33 ,-335 ,-348 ,-240 ,-287 ,-436 ,-225 ,-221 ,-198 ,-190 ,-50 ,-87 ,-161 ,-408 ,0 ,-14 ,-225 ,-105 ,-188 ,-290 ,-349 ,-57 ,-45 ,-20 ,-384 ,-36 ,-264 ,-359 ,-52 ,-21 ,-328 ,-194 ,-432 ,-113 ,-475 ,-391 ,-86 ,-407 ,-18 ,-435 ,-206 ,-317 ,-254 ,-369 ,-373 ,-127 ,-405 ,-309 ,-154 ,-480 ,-271 ,-71 ,-306 ,-381 ,-252 ,-253 ,-420 ,-40 ,-349 ,-403 ,-44 ,-256 ,-33 ,-429 ,-10 ,-461 ,-405 ,-216 ,-329 ,-201 ,-498 ,-392 ,-149 ,-419 ,-85 ,-408 ,-248 ,-88 ,-322 ,-438 ,-381 ,-100 ,-445 ,-412 ,-215 ,-220 ,-83 ,-436 ,-411 ,-555 ,-372 ,-232 ,-309 ,-151 ,-214 ,-219 ,-268 ,-123 ,-90 ,-241 ,-508 ,-134 ,-74 ,-296 ,-505 ,-240 ,-161 ,-477 ,-63 ,-118 ,-293 ,-69 ,-197 ,-88 ,-520 ,-170 ,-37 ,-114 ,-234 ,-36 ,-225 ,-116 ,-36 ,-195 ,-363 ,-75 ,-137 ,-7 ,-506 ,-124 ,-556 ,-15 ,-327 ,-74 ,-367 ,-505 ,-29 ,-296 ,-281 ,-180 ,-420 ,-119 ,-449 ,-502 ,-204 ,-294 ,-484 ,-515 ,-74 ,-337 ,-256 ,-479 ,-471 ,-27 ,-614 ,-354 ,-369 ,-607 ,-244 ,-578 ,-195 ,-215 ,-407 ,-552 ,-247 ,-514 ,-434 ,-291 ,-521 ,-99 ,-598 ,-292 ,-400 ,-594 ,-381 ,-602 ,-260 ,-79 ,-441 ,-444 ,-146 ,-451 ,-502 ,-215 ,-81 ,-577 ,-652 ,-507 ,-264 ,-588 ,-431 ,-401 ,-103 ,-282 ,-125 ,-259 ,-615 ,-321 ,-271 ,-84 ,-84 ,-323 ,-650 ,-79 ,-289 ,-522 ,-129 ,-343 ,-441 ,-186 ,-561 ,-244 ,-186 ,-296 ,-272 ,-258 ,-308 ,-390 ,-677 ,-367 ,-186 ,-604 ,-104 ,-481 ,-394 ,-31 ,-663 ,-493 ,-608 ,-142 ,-86 ,-356 ,-581 ,-131 ,-11 ,-92 ,-258 ,-552 ,-176 ,-244 ,-208 ,-564 ,-9 ,-558 ,-256 ,-439 ,-460 ,-641 ,-457 ,-715 ,-328 ,-291 ,-172 ,-380 ,-406 ,0 ,-123 ,-286 ,-301 ,-375 ,-358 ,-607 ,-599 ,-670 ,-94 ,-143 ,-65 ,-201 ,-486 ,-394 ,-405 ,-671 ,-673 ,-564 ,-137 ,-200 ,-148 ,-644 ,-589 ,-643 ,-155 ,-714 ,-602 ,-54 ,-746 ,-403 ,-520 ,-446 ,-646 ,-680 ,-474 ,-431 ,-762 ,-712 ,-554 ,-187 ,-242 ,-242 ,-595 ,-66 ,-610 ,-378 ,-430 ,-595 ,-485 ,-467 ,-434 ,-663 ,-375 ,-81 ,-503 ,-688 ,-651 ,-17 ,-10 ,-184 ,-361 ,-165 ,-785 ,-61 ,-211 ,-140 ,-740 ,-126 ,-549 ,-222 ,-611 ,-557 ,-786 ,-525 ,-431 ,-111 ,-287 ,-131 ,-574 ,-212 ,-733 ,-223 ,-734 ,-275 ,-524 ,-295 ,-541 ,-240 ,-162 ,-750 ,-350 ,-486 ,-672 ,-579 ,-410 ,-737 ,-544 ,-728 ,-516 ,-163 ,-227 ,-249 ,-177 ,-522 ,-363 ,-190 ,-613 ,-148 ,-810 ,-593 ,-702 ,-545 ,-187 ,-27 ,-332 ,-611 ,-510 ,-214 ,-56 ,-219 ,-696 ,-593 ,-720 ,-479 ,-155 ,-278 ,-517 ,-691 ,-314 ,-638 ,-748 ,-232 ,-737 ,-46 ,-138 ,-192 ,-631 ,-224 ,-691 ,-628 ,-613 ,-324 ,-185 ,-365 ,-259 ,-219 ,-462 ,-290 ,-783 ,-710 ,-444 ,-271 ,-117 ,-469 ,-609 ,-105 ,-602 ,-465 ,-260 ,-323 ,-544 ,-493 ,-458 ,-261 ,-102 ,-198 ,-221 ,-321 ,-694 ,-614 ,-147 ,-511 ,-592 ,-335 ,-738 ,-198 ,-274 ,-780 ,-598 ,-281 ,-686 ,-25 ,-682 ,-827 ,-491 ,-312 ,-540 ,-304 ,-293 ,2 ,-238 ,-614 ,-22 ,-380 ,-194 ,-167 ,-167 ,-569 ,-170 ,-184 ,-104 ,-327 ,-401 ,-654 ,-926 ,-571 ,-181 ,-809 ,-552 ,-767 ,-579 ,-823 ,-620 ,-660 ,-853 ,-448 ,-720 ,-872 ,-898 ,-45 ,-154 ,-409 ,-399 ,-950 ,-393 ,-782 ,-376 ,-65 ,-644 ,-654 ,-523 ,-24 ,-767 ,-419 ,-183 ,-143 ,-98 ,-792 ,-485 ,-923 ,-360 ,-173 ,-879 ,-847 ,-732 ,-962 ,-643 ,-392 ,-117 ,-4 ,-932 ,-253 ,-298 ,-381 ,-339 ,-796 ,-274 ,-79 ,-586 ,-567 ,-425 ,-541 ,-329 ,-800 ,-878 ,-519 ,-111 ,-224 ,-304 ,-560 ,-183 ,-604 ,-952 ,-229 ,2 ,-115 ,-748 ,-262 ,-54 ,-533 ,-139 ,-785 ,-583 ,-634 ,-164 ,-836 ,-77 ,-578 ,-593 ,-561 ,-596 ,-611 ,-440 ,-27 ,-848 ,-998 ,-56 ,-947 ,-740 ,-737 ,-612 ,-655 ,-845 ,-812 ,-925 ,-197 ,-236 ,-37 ,-753 ,-747 ,-286 ,-641 ,-43 ,-348 ,-33 ,-713 ,-610 ,-777 ,-899 ,-1005 ,-264 ,-193 ,-928 ,-193 ,-412 ,-213 ,-228 ,-1012 ,-920 ,-702 ,-420 ,-496 ,-1019 ,-386 ,-645 ,-804 ,-795 ,-12 ,-810 ,-117 ,-454 ,-266 ,-1059 ,-321 ,-674 ,-647]
  end
  def day6() do "4	10	4	1	8	4	9	14	5	1	14	15	0	15	3	5" end
  def day7() do
  "ifyzcgi (14)
axjvvur (50)
tcmdaji (40) -> wjbdxln, amtqhf
yjzqr (73)
smascq (97)
hyehtm (7)
oylvq (136) -> witry, cvlod
csyiik (34)
zivjpfo (23) -> lcchgb, bhqlq
ggfmiv (94)
vpltn (41)
gzxnn (171) -> mqodhde, djvkd
bsfygp (75)
dnrjb (9)
ohdnhx (261) -> tgiou, lndczw
frcrd (56)
cldaag (31) -> orbcuzi, teyakvf
vphlxz (26)
nljmcv (47)
xcxqa (6759) -> znely, rtsbgwx, hilafgl
hywzja (81)
ytxcti (60)
igzvp (68)
uzvsml (34)
keusrg (27)
tlmfw (45) -> pehflc, lefxyzt
hjmtrw (6772) -> cblhmk, zzflc, xsztla, iitbuxz, tckyc
ahjlf (1474) -> ejvipa, xhzyzer, pzwtjfj
egszxz (14)
skmuo (1607) -> rxsihsa, vsslzfp
ifyja (32) -> rvixnmq, aumrixf, wbenaek, jkkwtd, ywnsmem, mmhtyd, xmzzrgs
dwnokzu (311) -> xinfpy, lwvfsu
txbgfm (33)
roqfxg (62) -> wrhnq, rskara
autjn (29)
hnedp (10)
owxawf (60) -> twoyl, sikmtaj, lvptmrf
jensj (281)
sglkjsh (66)
eeziziu (34)
qjuuu (83)
iebulx (297) -> mqcflzv, nafrmeo
lhfuku (159) -> syzcti, ynhvfvx, ckegba
mxnlv (61)
emtjcx (60)
jspui (58) -> chlpx, xjkquk, afyxhh
nmikggy (64)
vatflrk (6) -> uxbhu, gekygl, xdyrvy, wesoooi, esphpt
jfcoc (41)
gyepcnc (6)
atbiby (80) -> aqtog, qjsvs
ygnkwn (52)
piexct (65)
uitfx (39)
rdvciwk (55)
jkgnvbn (23)
xpewzk (45)
vlqyxe (337) -> rosfnb, vphlxz
bmdgthp (215) -> kyfuyaf, tzrqqk
czafdho (24)
emuwzd (102) -> ifyzcgi, edotax
fwabsk (14)
uftnfv (53)
ndkcn (39) -> mkjuq, ghcgz, cxpwfir, lxwvf, nsghrq, vyvrn
srzfd (77)
gqhnstx (870) -> xmedt, brzucfh, layqazp
bdnjn (57)
pbckxv (14)
fbpbs (74)
zwutlym (92)
lzeud (290) -> igkrktn, oixlcn
gjctf (27)
azmneyd (60)
wbenaek (253) -> gdunxee, vgiqvsi, bmlkhaf
orpjw (72)
dgyulo (9)
qklqozd (125) -> otikjx, wuvhyc, dwejsn
waiwj (47)
bnevesk (256) -> dmglcj, blnwcb
yqnjd (50)
vvkkkpb (39)
ciprksz (84)
hblux (91)
dfywz (60)
jeiqx (26)
zdissfg (7)
mriqcjy (66)
eydak (49)
qwxwd (49)
plhlj (64)
nqgbp (67)
ewwfzg (70)
djzjiwd (44600) -> zszzkl, hrnrjrt, hjmtrw
mtflvu (71)
shesfq (143) -> ohdnhx, uhnqr, zdglrh, ripilxo, gfszte
huzokb (298) -> mnqii, mieqti
ohuvsf (83)
wcdibhx (196) -> xvwvc, ncmad, jkgnvbn
fxlbc (184) -> mdqeh, kmvcmg, sonvcww, pcckqq
lnknp (91)
swugafb (504) -> ryazls, vmkeu, fewrzd
pmadd (97)
mprgtb (42)
lorxjw (62)
welidg (97)
zzbad (30) -> npccgnv, yqnjd
dwejsn (40)
fvivo (225) -> worqh, yjzqr
zuawuo (111) -> jktlfu, uhvtpfy, ivlus
ikaol (26)
mmhtyd (220) -> yekmflj, nmikggy, xepgx
hujjten (37)
htqps (36)
dlobfkw (44)
fxrijc (57)
xgfad (33) -> zivlnu, ipsst
pafiy (17) -> dhtxpbb, dgcecu
cblhmk (1108) -> ggmhxx, tysdkgl, rrvbwb
kioga (93)
ljhlxc (83)
qsvbb (56)
uaffk (61)
lvptmrf (58)
hebhue (11)
eefyyr (10)
wyylpt (184) -> oneoorw, cfbaj
vmboh (90)
ghcgz (195) -> tajfmq, yzufk
jjhrmi (190) -> qhubjd, uycop
teduvv (25)
xjadrfg (28)
ugcccv (67) -> wehdeq, gyepcnc
psdzpg (38)
hyhbu (593) -> sblfh, ekvdv, iicpkf, xidtz
satjdgz (60)
cjbdxts (34)
gdunxee (53)
fqswta (47)
iwouvid (81)
iqbdxb (67)
ozbjpiq (16)
ysafyj (97)
lcchgb (82)
wkamonm (19)
waqca (61)
bbeyl (9)
rkfspx (17)
nggtuh (64)
jmypc (20)
yfegso (122) -> yhsmjfq, jzmacb, autjn, werkz
zirysk (72)
rtsbgwx (251) -> cbmqx, hvmlb, rsstvn, jtyurkp, gmkvgf, qkawtfu, ggwtf
yxgwsj (14)
xmgqmv (84)
lncmhi (48)
orclyi (30)
bjwny (94)
zehkwy (69)
mzajj (92) -> nljmcv, waiwj
ffsehyc (17)
agelbfq (343) -> iuchai, qynrx
dgcecu (86)
wtqxei (61) -> afywb, dqbfloz
vlmihf (32)
lovox (77)
cmvofka (30)
ttbuzrh (96)
vsunxw (196) -> pdbykx, dnynny, pqjua, jhnujj
skfnp (97)
upuybrd (300) -> dnrjb, rfknc, bbeyl
cpmebw (60)
wkmtw (59)
rpvwtq (5)
jenfafh (58)
pubtxq (51)
xlkwyg (55)
iltoh (22)
ctaazgn (103) -> hywzja, pywmbis
zxhqlfy (26)
dklujy (76)
khgvmj (66)
yfnkp (33)
edsjbi (37)
brtomr (75)
siqcu (15)
kxdehcg (13)
vmkeu (315)
momda (90)
pocvrcs (6)
sonvcww (17)
nemrt (91)
ldbkyg (75)
jsrrt (22)
ifuvyo (180) -> zvszwl, utewfcr, dtmbf
kfzqw (80)
iyfyi (41)
tykwy (44)
twgjdmg (24)
qface (27)
ygkdmh (74)
sblfh (120) -> gglxj, fqswta
gbldz (49) -> xitcp, jpynea
hmjpa (122) -> elovaun, uijgiu, apxgf, nlacdac
wsixz (14)
vgegr (83)
fggyk (46)
kjoru (16)
ixqrl (22)
gklehu (84) -> sazbmjz, piexct
xxego (33)
jxfimbl (95) -> nvpdisw, kioga
vymmkdf (116) -> ofqbu, sboms, obbpd, czafdho
jpwtbds (1608) -> zwutlym, qntzr
xsztla (828) -> cmdizw, qxkhq, nfcbi, rtutzu
wtfliw (87)
lbxrh (94)
ybioco (29)
yvdhwyh (102) -> xpewzk, hdxrbzc, vsaejz, pudso
eauxeyl (53)
skuazsw (70)
jlcie (99)
ckmftuc (21) -> khixdho, ihzsljz, uvkxner
yuikqm (68)
dqbfloz (87)
zofjia (133) -> gshsx, ntkpthi
vyvrn (173) -> lrjbgd, vwojto
tszockk (729) -> ctaazgn, gqbwc, wcdibhx, cujimpt
ydqqgrw (15)
hcxwql (398) -> lpoejf, cmvofka
gjedup (5)
arelp (195)
aonfn (235) -> kzkfcn, eefyyr
lsgbe (99)
gunvu (99)
kasaf (34)
imohij (13)
khwbzl (1131) -> zlbnkdc, ljmrml, roqfxg
nwikfyc (80)
khtegw (91)
epggt (90)
yapaib (175) -> gunvu, ymdmn
saawhdk (12641) -> vwvowk, ilcsp, vatflrk, iajts
qoetrb (15)
ztmmr (147) -> ypkhqlq, uitfx
uqfbnlo (69)
sgrhs (249) -> zymggc, wnvrg
hqjinj (101) -> skuazsw, ewwfzg
vmpnccn (73) -> bidhw, qriyeb, xsyzhcf, ehjjbu
vqddcl (71)
yffeit (76)
xvzinl (99)
znzbkh (16) -> swnan, tbioyr
gnjit (23) -> dhfagjw, xxnpoe
qojhhod (1789) -> sjdanf, hmjpa, szglq
aluqao (313) -> lyhlx, ouhuptm
ipysrdj (222)
worqh (73)
tsxfibs (46) -> yfnkp, edjlm, txbgfm
pcumn (420) -> qwcyozf, dskuj, anoxh, dkmkdfd, fkapr
mejwrm (139) -> oxsewk, zsknxq
aynpyne (44)
sikmtaj (58)
sbfprua (70)
wwofru (53)
nmuxe (88)
uuvtlk (74)
rqisvrh (2703) -> bvmgt, gbxxpd, ffinat, ympbbx, uimoc, shesfq
ehjjbu (89)
cbmqx (163) -> bnlbs, psdzpg
naekrk (70)
cvnrr (17)
pwnqyt (133) -> zijzutq, yvdhwyh, vbmyyrh
sagyrje (49)
efuysje (97)
pzwtjfj (74) -> oyienb, ozbjpiq
ggmhxx (42) -> fhhgts, cepxc, zwzxy
bhfui (13)
chlpx (87)
hmlbrz (55)
oneoorw (90)
kyfuyaf (79)
kiylza (88)
fghxbc (99) -> fozagvz, wqgssb, kqqsq, oijwjli
qgxgzo (14)
cubqfzc (184) -> qwmqci, dmvcduz
lcqfe (61)
xypffi (11)
qntzr (92)
mkjuq (181) -> jdiczst, edsjbi
dhtii (62) -> kfzqw, lbozpy
amtqhf (99)
ixknk (37)
iuapj (162) -> gzfrn, wqtuhe, fndyvvn, zjveu, iebulx, agelbfq
khtooum (53)
aecsfp (72)
fcdcdh (88)
junfev (18)
pxfrz (91)
xratfed (6)
gwbfat (26)
cvcblhv (73) -> jbnns, glkjrrs
sdfvrod (114) -> lcqfe, uigcn
xkfkucf (951) -> skbrota, pwvahdb, odpqjr
okkvefs (820) -> fpuscxk, zhdioii, gzxnn, koxnez
dgosy (59)
yhvndwy (27)
pefzsea (86)
xaogy (131) -> ixknk, ykvss, hujjten
nvpdisw (93)
lmkwafp (56)
cwnvk (51) -> tvdsktm, pwzsq, plhlj, ayqbj
phbtrm (171) -> hmmjjct, xzvln
mrmbyj (53)
jibemf (87)
tysdkgl (20) -> mrwbv, llkaoeh
fpuscxk (147) -> ypdumo, lvdrrk
ejkumeu (235) -> xypffi, nvcafwu, cvdows
uijgiu (38)
cjjynt (264) -> rkwhbhr, axjvvur
nobfn (236)
svanha (62)
nuxxmd (53) -> lybaepp, eolqn
vsaejz (45)
hbbpuc (238) -> thrvlt, ziiqv
tbley (31) -> nvfca, nojly, nguafeb
bkkwe (70)
tywzxwb (24) -> lbhlxqa, dklujy, vzxktth
ezqeusd (71)
qwcyozf (115) -> igzvp, vtefqb
xpwxo (80)
layqazp (39)
hwdtvvc (40)
pwnxw (69)
jobwpao (181) -> pqgiox, uloppmh
wrhnq (87)
amsfvm (53) -> nqgbp, bcldmsg
dfxjjzr (190) -> udaitd, sdktm
cnwzxpy (65)
kpvbt (85)
ifbhg (62)
cpeonw (27)
rsizei (20)
gmkvgf (63) -> tykwy, dlobfkw, aynpyne, vaovit
bjiuus (56)
bwpeux (17)
szrkuzi (27)
ygvpk (33701) -> saawhdk, svthizp, abamn
mjtji (35)
rqvvv (50) -> pzbxpou, rxzfdg
pozua (128) -> vljjqbw, hmlbrz
hmjueiq (79)
hdxrbzc (45)
twway (181) -> orclyi, hmdxion
jocmdmv (72)
lacddy (68)
lsxjl (94)
edotax (14)
gmirjhi (62)
iwicpur (10)
uigcn (61)
ynhvfvx (32)
ugavy (91)
jbgxcj (48)
zdglrh (239) -> csrww, haqaohl, gskveo, qoetrb
lmlsog (62)
sazbmjz (65)
ymeoz (24) -> lbxrh, lsxjl
hhqmsd (34)
ykmfoah (245)
lfdefc (30)
qynrx (53)
znely (919) -> qcmnpm, yjutt, yqgesx
cauig (58)
gvamhux (71)
hqqingt (13)
fiynt (72)
tyysd (63) -> cjjynt, lzeud, wyylpt, pewxc, ibevwow, fvmeeas, uksnrfx
igkrktn (37)
pzbxpou (87)
dllzp (59)
iblvki (11)
vaovit (44)
tcpduh (212)
btpvxq (56) -> urktg, ifnkl, hbbpuc, casmwo, ylqvuk, dblmcye, zvpboy
xxnpoe (67)
sboms (24)
whvvemg (83) -> tafss, vnfigul
ljjyy (64)
qvdid (70)
koxnez (71) -> bolpsk, pefzsea
elgtk (40)
wesoooi (87) -> pmadd, welidg
tiikt (92)
eadvs (797) -> ofnewz, neywe, qklqozd, ykmfoah
sreke (34)
clqqyi (51)
kuufl (1074) -> aonfn, cgrima, lhfuku
qswoy (7) -> bklfmch, xpwxo, eoustfr
rakfg (91) -> fiynt, opdtk, qkhvu
zvgsa (59)
gskveo (15)
clbbi (27)
ilcsp (844) -> pafiy, phbtrm, nwupf
blnwcb (17)
udaitd (23)
aewmad (73)
tvdsktm (64)
zavcu (25)
gglxj (47)
jmrlaxf (48)
sppxnti (48)
zhdioii (243)
olepfo (98)
ezsnmw (14)
hsmjm (25)
xmuxsr (44) -> bjiuus, qqjly
kmvcmg (17)
zuoeh (7782) -> hbaxtai, pmefov, zfteizz
sqxrad (80) -> marord, jbgxcj, xsmyok
vrbcn (34)
ibevwow (308) -> cvnabd, pbckxv, xrunic, ezsnmw
rqilp (25) -> quwfos, vekxdqh
ojfzokk (99)
bjwvw (209)
sygjhzp (36) -> hsxhyf, knqxdq
pjvnmqn (43) -> azoutv, jwhcmc
qqjly (56)
iezyfwf (20)
wrlkfij (55)
wuvhyc (40)
aqgtml (51) -> wywxu, tiikt, uwnwp
fhjysp (164) -> czvyrzi, nbmnwsq
rmlru (71)
bdiiv (15)
tlxekcp (42)
lbozpy (80)
uksnrfx (224) -> bkkwe, sbfprua
gmuwpyi (90)
zsqzm (64)
evhhfo (5)
xdyrvy (189) -> wyois, cwkdlil
gbxxpd (82) -> rynmge, hngao, vlqyxe, jhyjqxq
nzhqepw (60)
zfteizz (59) -> ytvjxq, vhoasjq, fwwub, xglsp, cubqfzc, nfucnzx
ulragq (39)
jgrsa (269) -> ukfsn, kptjhtd
uisnk (2228) -> tbley, eqkot, tlmfw, gnjit
chyhykz (59)
zjveu (437) -> qhyfphs, bfwnv
syliku (78)
syzcti (32)
nnmayb (85)
zdqmuey (209) -> ibkfqok, lhmgw
myopc (16)
cifdyio (74)
nguafeb (42)
dbczwnr (15)
vxede (10)
ouhuptm (52)
sdyox (93)
slahk (43)
skbrota (217) -> toeyz, gjcibb
hbaxtai (851) -> zynpp, ylbaxtu, rfwaq
hvdfq (112) -> imohij, pwetqid
zgfqdv (15)
dpqxfp (209)
arskvgv (88)
bqywl (157) -> ooufod, clqqyi
ymataqq (22)
krwgy (109) -> dllzp, xqpfvwx
ohsyhln (53)
ofqbu (24)
ccpnopa (59)
bfkbp (156)
bolpsk (86)
tckyc (456) -> dzfclsm, sqxrad, qkrpzl, ppcsoo, rqvvv
qbftkij (204) -> rtcfcyn, vlmihf
bpcnzi (82)
rhacrz (27)
wzbqh (306) -> xratfed, fjcobs, enlctw, pklcmix
qqnmzb (1723) -> mzyqoc, soirl, dhtii, ahbcl
tuvehcz (17)
yzufk (30)
xsmyok (48)
tgiou (19)
izvtqsa (84)
ooufod (51)
rfwaq (80) -> nmuxe, ttofoep
lpoejf (30)
oykwsk (76)
wdipy (92)
jbnns (93)
qcxiehu (312) -> eeune, gbldz, ztmmr
vsslzfp (91)
uimoc (30) -> crhojk, ejkumeu, lovaf, fhjysp, uxbrs, qbftkij
phtghp (3945) -> rpjozji, swnafht, swugafb, guyrnpn, evbtz, hyhbu
svthizp (1149) -> saddwx, olhnx, uisnk, iuapj, btpvxq, iovxjv
xvwvc (23)
ovpzt (139) -> dfywz, emtjcx
uatlbrq (17)
hmpisyb (41) -> igdtz, lnmhw, ttpmzgm, dkxzsaq
pehflc (56)
iedfk (49) -> ydqqgrw, bdiiv
nomeb (112) -> mmfuve, lxudoaz
ffuqr (90)
gsgwqk (204) -> ddraicf, dgyulo
igqle (222)
jhcwkl (41)
yfusbw (76)
lpsafeq (51)
lklqxg (83)
lofayaa (22)
itqwz (113) -> rhacrz, keusrg
xbidr (74) -> pozua, gisiv, skpux, tcmdaji, gorpw, yfegso, waakcx
pnouux (9)
ryazls (221) -> zhpfgzv, rvpxob
bxwng (53)
xwkyrer (8691) -> srnnjbb, qcxiehu, gqhnstx, ghdbwu
nbmnwsq (52)
cxfsoh (53)
gdylf (74) -> jlcie, hewatw, sdpsl
vksyy (96) -> wfpzhfz, phsmt, zuwaw
qekxzsx (87)
qzglav (42) -> ubxvdq, aqvtgi
xsoqzbe (1068) -> llgbz, itqwz, yxzlpnj
lndczw (19)
perzy (46)
oigsk (38)
uytsra (106) -> hkgxpgh, gzxddd
zszzkl (72) -> ifyja, cdqdm, rwmdbn, exwzzr, leyikdx
wfvjnxf (93)
pklcmix (6)
cvpuwrb (82)
ileugiu (225)
defbun (57)
fbzvm (72) -> vgexqw, cejtpyf
aduikk (133) -> kmfel, paopwt, hdjzg, qckzqv
shlfz (3932) -> swcvn, obwkzhc, pcumn
yhjhgu (57)
vgiqvsi (53)
iajts (451) -> izzzyqd, fegaac, jagdwg, mblvpm
kxwbdvm (1104) -> mzajj, ubuge, ddguar, znzbkh
rynmge (25) -> ecwjaw, zdqsmv, aodoc, pxfrz
bqxnoid (31) -> aqgtml, qprenhy, upuybrd, sgrhs, flptbw, mxwbp, boszym
kqqsq (37)
xrunic (14)
vqnyvr (57)
lvdrrk (48)
bamxvq (86) -> zywvdda, ygnkwn, taxrkif
xkzvo (33)
vhoasjq (226) -> uogva, tuvehcz
hkgxpgh (46)
zocwx (35)
qhyfphs (6)
coselm (44)
ypbrxyq (206) -> siqcu, kqicqf
ffgzg (151)
ujuunj (64)
iuchai (53)
ykvss (37)
ovszp (64)
helyfoo (65)
pryhgj (81)
fxhqq (29)
eeshl (30)
qzftgbx (44)
ppcsoo (26) -> gwqgewp, lsgbe
xinfpy (53)
ddraicf (9)
xidtz (126) -> azuoza, coselm
ipsst (23)
wzvzgg (60)
fqqyipa (200) -> eeshl, cxqeyt, qkhqrq
jpyvpw (20)
xhzyzer (82) -> pawvr, dckbvlg
boszym (129) -> rqrhrnz, beewze, evqibrc
kabqu (38)
sdpsl (99)
bekguie (31)
klovr (30) -> kihqh, wafjqj
zklbfdg (47)
ccter (84)
wzqanwj (240) -> zavcu, hsmjm
uxbrs (94) -> qekxzsx, odqns
dzxpqj (22)
csrww (15)
wwxak (108) -> vbmqj, ugavy
etfbuu (22)
miwst (40)
iiugq (15)
cuprzhk (40)
waakcx (238)
faijmsh (35) -> rwakmo, nwikfyc
cvlod (76)
sjgvkg (1566) -> cldaag, bjwvw, dpqxfp, dgdtt, ujbzq
ixxww (61)
mipqe (91)
xitcp (88)
lxudoaz (51)
ibkfqok (19)
ulchkal (55)
qubli (60)
tsamaj (1171) -> axgndac, vbuvkx, uqeag, qyurm, lzypz
mmpnppi (60)
prlvn (63)
ddwursx (245) -> sdwrx, jtfylv
aljgr (62)
glkjrrs (93)
vwftcva (46)
ylbaxtu (144) -> frcrd, shjxje
jqpdpr (14)
yzhvrx (90) -> viqvtzw, twway, zwzzce, hqjinj, mejwrm, yyursb, gfigt
iqoxkhd (91)
locrtxl (2681) -> xsoqzbe, oxoocfp, ndkcn, vmeubf
fbmajm (58)
rylaxjf (90) -> ojfzokk, iksaub
wyois (46)
ecwjaw (91)
alhlvth (36) -> zirysk, orpjw, zdxscz
jlofqwz (13)
sdktm (23)
bjvuicy (217) -> xjyyfe, rahgf, qqllir
hepkop (7311) -> xkfkucf, xbidr, yvgkdi
gqbwc (25) -> ytxcti, qubli, cpmebw, wzvzgg
yojcz (201) -> rkjuz, rmlru
obwkzhc (86) -> vksnq, tijwlva, szcozjr, krwgy, pnhpv, ydiicdl, kskts
cdqdm (2502) -> wnfqsa, jbqmy, hvdfq
gjcibb (23)
igdtz (83)
phsmt (112) -> jqpdpr, bmnsmqz
hdjzg (77)
jukxlr (29)
oajdx (61)
ktayld (179) -> skfnp, xwjmsjr
dkxzsaq (83)
utewfcr (50)
jljjai (14) -> fhycptc, olepfo, armfpvt
gnughzp (5)
oyienb (16)
kqicqf (15)
ggvwlp (80)
vlbivgc (13370) -> xcxqa, aeatvub, pwmrau, rqisvrh, hepkop, ogmoqb
kczlit (64)
mblvpm (124) -> fbmajm, ofwbsgp
wehdeq (6)
fegaac (206) -> ffsehyc, sapwhr
qpsirr (15)
gisiv (80) -> hmjueiq, unqui
xjkquk (87)
rsdub (61)
gzxddd (46)
oxsewk (51)
ahfdt (234)
wafjqj (80)
mhjeza (93)
bljkg (12) -> yivjj, cxcyrd, lorxjw
fkapr (39) -> wwofru, weyfsg, khtooum, ohsyhln
dtfdn (71)
zxgrq (25)
rlfqf (63)
hvisx (68)
laopkn (40)
zvszwl (50)
gorpw (55) -> jnrnwos, rsdub, uaffk
skmbdhz (54) -> scqtkga, xdojlm
ecaiau (424) -> rakfg, ddwursx, nsbzfgy
bfwnv (6)
uhvtpfy (47)
zafggcz (17)
qkrpzl (170) -> kjonvut, clbbi
bvmgrs (75)
iicpkf (16) -> vhkydm, htecpc
rbuwrpw (17)
funnv (5679) -> cdlzi, fpfpv, bqxnoid
flkkr (74)
brzucfh (39)
lfavcfd (72)
dmvcduz (38)
izdhn (1183) -> uytsra, xxmtvr, bljkg
hrnrjrt (9135) -> kuufl, khwbzl, tocvooe
eiatt (291) -> gfhummb, jsmde
czvyrzi (52)
ypkhqlq (39)
egxzjn (81)
qzzlmw (319) -> szrkuzi, cpeonw
xepgx (64)
iftyxdd (79) -> xmaqelf, htqps
rskara (87)
uytsdd (292) -> hyehtm, zdissfg
mqodhde (36)
ylqvuk (48) -> shdgsk, fcdcdh, kiylza, arskvgv
gisrnfs (23)
vntsex (77)
rwmdbn (2136) -> xmuxsr, bfkbp, ibjdru, ttvfha, zhohes
fhhgts (38)
opdtk (72)
beewze (66)
leyikdx (1995) -> ewswf, gaashgh, cwnvk
kcbwrrr (631) -> wzbqh, sysdxvb, huzokb, ifuvyo, ghakp, rqqlzs
jwhcmc (72)
mqcflzv (76)
ofwbsgp (58)
hiyswbt (889) -> ileugiu, suuhqpd, yffhk, htstksc
armfpvt (98)
zsknxq (51)
pewxc (246) -> rmexd, wkmtw
lhmgw (19)
qwmqci (38)
hioofm (319)
cujimpt (137) -> ovszp, zsqzm
htstksc (169) -> wsixz, egszxz, gzjut, rutqzk
quwfos (85)
tcjqw (81)
orbcuzi (89)
sybpg (49) -> sdyox, dwrwuoq
qyhvc (16)
sadnqcp (62)
zihpcn (232) -> jukxlr, louebj
zxygs (208) -> njvkdrp, hqqingt
gyoqtcg (77)
emwblax (49)
hewatw (99)
qxkvfid (53)
kglsx (74)
yhfpq (56) -> cxyfam, mjumixz
zivlnu (23)
xsyzhcf (89)
howlyws (206) -> gwyljq, xhhwwso
uycop (59)
yhxlzc (91)
isqvoex (30)
bklfmch (80)
tvrxaw (106) -> qdqtw, qpsirr, dbczwnr
lkreb (72)
kxyfb (90)
jnrnwos (61)
mxbrva (72)
qkhqrq (30)
gfhummb (40)
zwzzce (221) -> ahqfu, gjedup, evhhfo, rpvwtq
rrvbwb (34) -> wcmyn, haclvfu
enlctw (6)
yeaic (61)
otipr (480) -> gdrxgji, fonrd, wqoae
qxkhq (143) -> ixqrl, jsrrt
wbqeo (22)
iugsida (64)
azuoza (44)
yxemuyq (19)
fyouz (18)
bnlbs (38)
hilafgl (59) -> hmpisyb, ktayld, yapaib, bmdgthp, qzzlmw
shdgsk (88)
rnqgy (34)
kmwxj (92)
hmmjjct (9)
mefmo (46)
lwvfsu (53)
fixwkec (84)
haclvfu (61)
werkz (29)
iovxjv (1204) -> uhwnr, ypbrxyq, dfxjjzr, pxkypf, nobfn, tkdvenx, sdfvrod
dmglcj (17)
qprenhy (221) -> cxfsoh, mrmbyj
qmwmbsk (804) -> tmoui, amtayi, wgqpt, xaycmtu, kztkif
zywvdda (52)
ntkpthi (6)
jkkqxfr (1135) -> nomeb, fbzvm, gklehu
muptknj (66)
uwnwp (92)
ggwtf (213) -> vkaay, kxdehcg
afywb (87)
xglsp (94) -> ljhlxc, htpblzv
elovaun (38)
qhubjd (59)
exwzzr (1542) -> bchixdc, fphmu, hcxwql
xhhwwso (43)
uevxbyn (170) -> ucaee, yuikqm
pqgiox (50)
edjlm (33)
ypdumo (48)
ehhbjt (26)
cxyfam (98)
bhqlq (82)
abamn (8) -> tsamaj, qojhhod, kcbwrrr, ttfyrk, qqnmzb, tyysd, sjgvkg
sjdanf (49) -> ldbkyg, brtomr, qwfvm
wcjnjpf (57)
xzvln (9)
citaywz (64)
aqtog (66)
khdbe (9)
vksnq (85) -> vqddcl, ezqeusd
fkwbo (91)
jefjzvl (73)
azoutv (72)
aqvtgi (90)
vlyof (97)
gwyljq (43)
xmedt (39)
rsstvn (75) -> bpcnzi, cvpuwrb
vekxdqh (85)
toeyz (23)
pvyvx (99)
pwmrau (9594) -> roogi, ajcbzv, pwnqyt
qahzrif (63)
gzjut (14)
mzyqoc (194) -> yxgwsj, fwabsk
tkdvenx (44) -> sppxnti, lncmhi, jmrlaxf, qmati
vtefqb (68)
yekmflj (64)
pdbykx (14)
fpgyyu (67)
qjbbyb (26)
izzzyqd (186) -> djvfa, qrrvi, junfev
lsire (61685) -> locrtxl, shlfz, ycpcv
vbuvkx (204) -> tlxekcp, pxdkes
ahqfu (5)
cjxyp (81)
aeatvub (10983) -> hghjsk, vksyy, otipr
jhnujj (14)
cxpwfir (63) -> mhpzrw, txwzysl
gcydgf (22)
zlbnkdc (92) -> lfavcfd, lkreb
lrjbgd (41)
casmwo (246) -> nsbnixe, vntsex
rqqlzs (270) -> lfdefc, isqvoex
xtqthxs (44)
kjonvut (27)
mptovq (19)
dwrwuoq (93)
ziiqv (81)
vnfigul (38)
jpynea (88)
rplcrt (90)
flptbw (159) -> xmgqmv, ciprksz
nojly (42)
jbqmy (86) -> zxhqlfy, ehhbjt
ozhydny (40)
zzflc (92) -> rnyndr, eiatt, fvivo, gdylf
jktlfu (47)
njvkdrp (13)
qyurm (76) -> eauxeyl, nrwmjk, qxkvfid, rjmuly
bjyraf (7)
zhpfgzv (47)
qfcetm (30) -> iqoxkhd, gptyqwd
dhfagjw (67)
qriyeb (89)
ucaee (68)
djvkd (36)
scqtkga (54)
yvgkdi (992) -> pjvnmqn, kgoyufq, zivjpfo, amsfvm
zsukqjo (90)
hfmaqp (94)
gxsxqwt (20)
marord (48)
uloppmh (50)
iktmpdq (34)
wnvrg (39)
cxiturs (95) -> ttoer, jpwtbds, yykkph, yffpvf, ahjlf, yoxetv, okkvefs
fewrzd (24) -> efuysje, olrgu, rtmiw
swnan (85)
xdojlm (54)
dhtxpbb (86)
roogi (100) -> cesnj, wsvfkr, hzhcl
yffhk (143) -> jfcoc, vpltn
ffinat (630) -> avyoy, tywzxwb, zuawuo, vsunxw
txrfl (81)
eoustfr (80)
bxmcg (249) -> epggt, gfjsie
kdeqm (99) -> qjbbyb, ikaol
lfsvtih (97) -> aylxc, bekguie
qkhvu (72)
zzfcq (7259) -> balknnd, iiqzvha, kzzfvt, ecaiau
kebhn (106) -> iktmpdq, sreke, cjbdxts, ehlnex
ljmrml (178) -> fxhqq, ybioco
asozcan (96)
ceeotg (53)
fonrd (12)
fvmeeas (88) -> wdipy, khnjt, kmwxj
cejtpyf (71)
wsvfkr (193) -> liznr, yytpewc
evdwf (31)
wqgssb (37)
uhnqr (247) -> oncexf, jeiqx
xzmdis (24) -> yhjhgu, vqnyvr, taacpu
tafhilv (11)
mhpzrw (96)
cgrima (79) -> xvayjwv, eyxccr, xtqthxs, qzftgbx
nrwmjk (53)
yjutt (47) -> jocmdmv, iaoyb, aecsfp, mxbrva
cxcyrd (62)
fwwub (146) -> defbun, wcjnjpf
sapwhr (17)
ihzsljz (46)
zmkwnv (66)
yytpewc (50)
xdctkbj (83) -> zuoeh, tnqram, funnv, zzfcq, xwkyrer, cxiturs, phtghp
kptjhtd (86)
pcecbrn (66)
sdwrx (31)
dfiyju (49)
gxddhu (133) -> itlwpm, bdnjn
zvpboy (76) -> txrfl, egxzjn, iwouvid, cjxyp
fndyvvn (85) -> khtegw, aocfuj, mipqe, lnknp
ozvtqp (53)
kxizh (74) -> yojcz, uafhv, wnpnfiv, kivyltn, jxaorvd
zwzxy (38)
rkjuz (71)
jagdwg (46) -> ytiljvt, smascq
rutqzk (14)
zymggc (39)
afbzsz (148) -> vzcklke, ggvwlp
ymdmn (99)
twoyl (58)
lqcutyt (74)
nlacdac (38)
otikjx (40)
rxzfdg (87)
huvihu (49)
cfbaj (90)
lqlyf (59)
apxgf (38)
nqicerc (62)
iksaub (99)
avyoy (252)
kzzfvt (94) -> aluqao, oherzyz, dwnokzu
uqeag (162) -> prlvn, xtaoisd
crhojk (40) -> yffeit, yfusbw, oykwsk
oxoocfp (237) -> igqle, eukgf, qzglav, ipysrdj, gsgwqk, kevlq
aylxc (31)
khnjt (92)
ytvjxq (260)
xkxqc (64)
ogmoqb (8) -> uqmgmst, hiyswbt, qmwmbsk, skmuo, tszockk, kxizh, thbwh
nvfca (42)
xaycmtu (67) -> cnwzxpy, helyfoo
kklbcs (74)
wqtuhe (341) -> myookpi, gqikhhw
unqui (79)
vhkydm (99)
zcomxf (40)
hsxhyf (63)
rwakmo (80)
uogva (17)
cesnj (57) -> hrokzl, rtgobsq, kmfsmp, chyhykz
rtcfcyn (32)
qckzqv (77)
oixlcn (37)
iaoyb (72)
idrror (34)
bcldmsg (67)
lbxdtms (281)
adbxp (35)
qsjqlp (74)
mjumixz (98)
rtmiw (97)
jzmacb (29)
umgch (64)
rpjozji (279) -> faijmsh, xzmdis, arelp, guvke, rqilp, eqpuuzs
xvayjwv (44)
vgemekb (53)
odpqjr (263)
hekibe (63)
xmaqelf (36)
ivlus (47)
rkwhbhr (50)
pawvr (12)
crcrimv (57)
ukfsn (86)
nfcbi (117) -> zocwx, mjtji
qwfvm (75)
jfieeor (96)
eolqn (91)
bgehlas (6)
ruozk (10)
gqikhhw (54)
pqjua (14)
jtyurkp (239)
wjbdxln (99)
paopwt (77)
fefuzon (126) -> jenfafh, cauig
ifualyn (93)
npccgnv (50)
nvcafwu (11)
htecpc (99)
uxbhu (175) -> bxwng, ozvtqp
gzfrn (365) -> mprgtb, qkicc
qlwhsix (71) -> bjwny, ghapm
uvkxner (46)
kmfel (77)
ytiljvt (97)
cxqeyt (30)
yyursb (93) -> lqcutyt, uuvtlk
mpijr (88)
rpqbv (23)
oginzo (24)
sydjg (10)
ehlnex (34)
ukqmhyc (25)
gshsx (6)
nafrmeo (76)
ifwmfdm (114) -> jibemf, wtfliw
rmexd (59)
ujbzq (41) -> izvtqsa, ssnhc
scxdo (56)
bvmgt (1203) -> xqncgyu, tsxfibs, zofjia
vkaay (13)
pxdkes (42)
witry (76)
ttpmzgm (83)
pxgkg (69)
vwojto (41)
jcise (35)
tbioyr (85)
wnpnfiv (55) -> tehat, ttbuzrh, jfieeor
ejxib (53)
htpblzv (83)
dgdtt (155) -> qface, yhvndwy
weyfsg (53)
aodoc (91)
vmeubf (759) -> sygjhzp, ilhib, ldgyqh, uewdyd, skmbdhz
pwetqid (13)
pudso (45)
ibjdru (136) -> dzqqgbm, qivxs
rtgobsq (59)
kqiuy (81) -> ffuqr, rplcrt, gmuwpyi, zsukqjo
gfszte (23) -> pxgkg, zehkwy, pwnxw, uqfbnlo
ngxtfhu (25)
fphmu (62) -> jpvxzcn, xvzinl, pvyvx, lxgvhy
yxzlpnj (85) -> iyfyi, jhcwkl
khixdho (46)
pjjmau (353) -> hktzoq, oigsk
ttofoep (88)
fhycptc (98)
nsghrq (105) -> bvmgrs, bsfygp
hmdxion (30)
nsbzfgy (167) -> mplhwo, qvdid
hngao (361) -> olhfbr, qgxgzo
iitbuxz (1186) -> eexmf, emuwzd, zzbad
ywnsmem (246) -> qjuuu, ohuvsf
qjsvs (66)
uuyfecv (9)
uafhv (223) -> azmneyd, mmpnppi
aocfuj (91)
kaghlc (34)
eionkb (1079) -> hxmcaoy, sybpg, jfhqrla
hzhcl (127) -> vgegr, lklqxg
ssnhc (84)
ttfyrk (2158) -> xnxsdq, ffgzg, tvrxaw
nvfqmkw (96)
qrrvi (18)
ajcbzv (55) -> jjhrmi, jljjai, afbzsz
ydiicdl (93) -> iqbdxb, fpgyyu
eyxccr (44)
gdkjoit (56)
urktg (196) -> pxgcbfi, lacddy, hvisx
wuclmu (64)
rosfnb (26)
osjsm (87)
kgoyufq (133) -> holen, gjctf
kihqh (80)
xjyyfe (25)
gyfbgkr (16) -> gyoqtcg, lovox, srzfd
bidhw (89)
wfpzhfz (78) -> zyfwjxs, evdwf
rnyndr (149) -> kklbcs, ygkdmh, cifdyio
xqncgyu (25) -> nzhqepw, satjdgz
hvmlb (141) -> qwxwd, huvihu
txwzysl (96)
suuhqpd (48) -> ccpnopa, lqlyf, fxpoal
djviima (31) -> qyhvc, kjoru, myopc
ddguar (116) -> adbxp, jcise
wptyd (87)
obbpd (24)
anoxh (63) -> hfmaqp, ggfmiv
llgbz (167)
mhxheb (167) -> rkfspx, uatlbrq, cvnrr, bwpeux
yybnbso (89)
lxgvhy (99)
yffpvf (1698) -> pwoyfeh, zklbfdg
ttvfha (156)
tocvooe (99) -> fqqyipa, zihpcn, wzqanwj, wajnseu, bnevesk, wwxak
taxrkif (52)
rvixnmq (376) -> fyouz, nsnqedk
uhwnr (60) -> zjzgs, mpijr
djvfa (18)
rjmuly (53)
pnhpv (227)
sjaax (190)
amtayi (29) -> qsvbb, scxdo, inlrm
vbmyyrh (142) -> uwjowb, naekrk
gomcbqb (203) -> lofayaa, iltoh
oijwjli (37)
wajnseu (20) -> kxyfb, vmboh, zguzlx
hghjsk (348) -> fixwkec, gcowt
dzqqgbm (10)
guvke (19) -> brjgwq, kejtzg
jpvxzcn (99)
mplhwo (70)
dblmcye (325) -> bffnszc, zxgrq, ngxtfhu
ahbcl (178) -> hebhue, edlved, tafhilv, iblvki
liznr (50)
pwoyfeh (47)
jdiczst (37)
ejvipa (38) -> kpayh, uzvsml
oherzyz (53) -> yhxlzc, fkwbo, ziyyc, dlfmj
kivyltn (303) -> vxede, pjazwiy, ruozk, sydjg
szcmb (176) -> bjyraf, bvypab
ofxzyhr (22)
xmzzrgs (266) -> aewmad, jefjzvl
gdrxgji (12)
ziyyc (91)
wgqpt (29) -> evcveie, ccter
yykkph (63) -> gyfbgkr, fghxbc, qswoy, gomcbqb, tubhp, zdqmuey, gxddhu
yoxetv (1724) -> eeziziu, kaghlc
xqpfvwx (59)
fxaglf (49)
shjxje (56)
cdlzi (1615) -> wtqxei, mhxheb, nuxxmd
zytau (43)
ghakp (232) -> sagyrje, fxaglf
lbhlxqa (76)
bchixdc (431) -> khdbe, uuyfecv, pnouux
olhnx (1796) -> vymmkdf, qfcetm, atbiby, tcpduh, ymeoz
bvypab (7)
hregcx (66)
aucjw (62)
bmqhvfv (40)
fpfpv (1564) -> fxlbc, alhlvth, yhfpq
lzypz (220) -> rnqgy, csyiik
ujjoydl (38)
rfcbs (197) -> oajdx, yeaic
cmdizw (31) -> ydzibri, syliku
iiqzvha (1325) -> hnedp, iwicpur
zdqsmv (91)
neywe (59) -> lmlsog, svanha, sadnqcp
teyakvf (89)
inlrm (56)
kpayh (34)
spwqxpy (79)
ofnewz (83) -> pryhgj, tcjqw
knqxdq (63)
jtfylv (31)
jhyjqxq (363) -> jlofqwz, bhfui
kmfsmp (59)
kskts (115) -> gdkjoit, lmkwafp
hktzoq (38)
tajfmq (30)
zdxscz (72)
pywmbis (81)
yhsmjfq (29)
kzkfcn (10)
mieqti (16)
mxwbp (235) -> fggyk, mefmo
thrvlt (81)
wqoae (12)
yivjj (62)
aumrixf (40) -> ifualyn, kgqzrt, mhjeza, wfvjnxf
gfigt (211) -> iiugq, zgfqdv
cepxc (38)
vzxktth (76)
locto (240) -> oginzo, twgjdmg
vopqzha (10) -> kglsx, qsjqlp, flkkr, fbpbs
lxwvf (72) -> ixxww, mxnlv, waqca
zuwaw (84) -> tbaads, xjadrfg
oothjv (71)
tubhp (141) -> uftnfv, vgemekb
wywxu (92)
uwjowb (70)
pwzsq (64)
eexmf (130)
ldgyqh (30) -> mriqcjy, khgvmj
ewswf (307)
tbaads (28)
rxsihsa (91)
dtmbf (50)
tzhwvzt (89)
qivxs (10)
nfucnzx (68) -> nvfqmkw, asozcan
znwmvr (63) -> ymataqq, etfbuu, wbqeo, gcydgf
kejtzg (88)
eukgf (112) -> rdvciwk, ulchkal
skpux (146) -> vwftcva, perzy
uewdyd (152) -> uamqx, gnughzp
dnynny (14)
guyrnpn (413) -> bqywl, cvcblhv, ovpzt, qlwhsix
lnmhw (83)
llkaoeh (68)
ydzibri (78)
gaashgh (307)
vbmqj (91)
uqmgmst (1336) -> kdeqm, znwmvr, iftyxdd
tijwlva (187) -> gxsxqwt, yjrfr
fozagvz (37)
tafss (38)
dckbvlg (12)
oncexf (26)
jkkwtd (142) -> jhwrcb, pbkplz, momda
evqibrc (66)
mrwbv (68)
hrokzl (59)
soirl (206) -> uqjfarv, myqre
ubuge (186)
rtutzu (73) -> crcrimv, fxrijc
pmefov (983) -> gibdxij, whvvemg, lfsvtih, ckmftuc
tnqram (7095) -> kxwbdvm, rhcxf, nihiexp
dzfclsm (186) -> yxemuyq, mptovq
pjazwiy (10)
mnqii (16)
uqjfarv (8)
xnxsdq (76) -> ukqmhyc, teduvv, lmhamlz
lnwcryv (62)
lovaf (94) -> osjsm, wptyd
rhcxf (84) -> jgrsa, egtruqh, kqiuy, aduikk
evcveie (84)
lyhlx (52)
zjzgs (88)
brjgwq (88)
wnfqsa (138)
balknnd (377) -> kebhn, bamxvq, xaogy, fefuzon
ayqbj (64)
zynpp (67) -> qahzrif, rlfqf, hekibe
szglq (194) -> iezyfwf, jmypc, rsizei, jpyvpw
ocppbp (26)
wuknah (36) -> kczlit, nggtuh, umgch, xkxqc
ifnkl (324) -> kabqu, ujjoydl
eqkot (33) -> aljgr, lnwcryv
yjrfr (20)
cvdows (11)
lybaepp (91)
jxaorvd (343)
zkpfzio (145) -> vrbcn, kasaf, hhqmsd, idrror
evbtz (297) -> ifwmfdm, rylaxjf, oylvq, locto
srnnjbb (51) -> zxygs, rkwquj, owxawf, ahfdt
viqvtzw (117) -> gmirjhi, aucjw
nsnqedk (18)
wiapj (55) -> djzjiwd, lsire, vlbivgc, xdctkbj, ygvpk
jhwrcb (90)
zdnypzo (66)
eqpuuzs (149) -> gisrnfs, rpqbv
kevlq (156) -> xkzvo, xxego
fxpoal (59)
dlfmj (91)
pbkplz (90)
qdqtw (15)
qkicc (42)
axgndac (156) -> zdnypzo, sglkjsh
gptyqwd (91)
cwkdlil (46)
tmoui (91) -> ceeotg, ejxib
xxmtvr (154) -> ofxzyhr, dzxpqj
zijzutq (90) -> wuclmu, citaywz, ljjyy
xtaoisd (63)
szcozjr (215) -> bgehlas, pocvrcs
jfhqrla (155) -> miwst, elgtk
nsbnixe (77)
haqaohl (15)
eeune (31) -> ysafyj, vlyof
vgexqw (71)
ghapm (94)
swcvn (1105) -> sjaax, szcmb, klovr
lmhamlz (25)
louebj (29)
fjcobs (6)
holen (27)
qryui (49)
olhfbr (14)
wcmyn (61)
dkmkdfd (173) -> vvkkkpb, ulragq
odqns (87)
xwjmsjr (97)
rqrhrnz (66)
uamqx (5)
rkwquj (92) -> gvamhux, dtfdn
ncmad (23)
lefxyzt (56)
qcmnpm (335)
kgqzrt (93)
ttoer (916) -> howlyws, wuknah, bjvuicy
rahgf (25)
mdqeh (17)
ghdbwu (863) -> ifbhg, nqicerc
thbwh (832) -> rfcbs, hioofm, jspui
gfjsie (90)
mmfuve (51)
vzcklke (80)
bffnszc (25)
saddwx (1569) -> bxmcg, vmpnccn, pjjmau
bmnsmqz (14)
qkawtfu (111) -> ujuunj, iugsida
edlved (11)
pxgcbfi (68)
gekygl (247) -> zafggcz, rbuwrpw
egtruqh (389) -> ocppbp, gwbfat
rvpxob (47)
ympbbx (1243) -> spwqxpy, iedfk, ugcccv, djviima, xgfad
pxkypf (54) -> hblux, nemrt
qqllir (25)
tehat (96)
gibdxij (121) -> ohsvn, wkamonm
itlwpm (57)
rfknc (9)
ekvdv (44) -> kpvbt, nnmayb
gwqgewp (99)
cvnabd (14)
dskuj (165) -> slahk, zytau
yqgesx (175) -> zcomxf, bmqhvfv, hwdtvvc, laopkn
vljjqbw (55)
qmati (48)
afyxhh (87)
ubxvdq (90)
ckegba (32)
sysdxvb (66) -> zmkwnv, pcecbrn, hregcx, muptknj
nihiexp (930) -> vopqzha, uytsdd, uevxbyn
myqre (8)
nwupf (109) -> cuprzhk, ozhydny
tzrqqk (79)
pwvahdb (85) -> yybnbso, tzhwvzt
gcowt (84)
ohsvn (19)
zhohes (46) -> wrlkfij, xlkwyg
ripilxo (299)
vwvowk (1293) -> dgosy, zvgsa
bmlkhaf (53)
kztkif (55) -> mtflvu, oothjv
ycpcv (72) -> izdhn, yzhvrx, eionkb, eadvs, jkkqxfr
zyfwjxs (31)
esphpt (85) -> emwblax, dfiyju, qryui, eydak
jsmde (40)
zguzlx (90)
pcckqq (17)
hxmcaoy (235)
taacpu (57)
ilhib (60) -> pubtxq, lpsafeq
myookpi (54)
olrgu (97)
swnafht (44) -> lbxdtms, jensj, zkpfzio, jobwpao, jxfimbl"
  end
  def day8 do
  "ebu inc 626 if iq < 0
obc dec -809 if sdw == -2
vb inc 568 if k > -2
wl dec 721 if wui <= 2
xbh dec -310 if bx != 1
qun inc 741 if qun > -4
k dec 661 if sdw != 0
wui inc 628 if k >= -4
qet inc 563 if skh == 0
ebu dec 197 if wl < -716
qun dec 239 if sdw < 7
n dec 655 if azg == 0
iq inc -857 if kxm <= -9
qet inc -959 if tzy > 5
azg inc -643 if qun >= 510
ebu inc 537 if c >= -8
eh inc -677 if bx >= -1
c dec -267 if ebu < 341
sdw dec 811 if tzy != -1
wui inc -775 if qet >= 562
iq inc 215 if azg >= -8
qun inc 949 if sdw > -813
xjo inc -652 if vb != 563
skh inc -560 if n < -645
xjo dec 978 if ne == 5
skh dec 913 if k > -6
iq inc 783 if azg != 1
skh inc 955 if ne == 0
xbh inc -981 if n > -660
eh inc -361 if vb == 578
iq dec 304 if obc != -3
eh inc 408 if tzy >= -2
w inc -576 if tzy == 0
iq dec 102 if udh < 7
k inc -627 if qet > 558
xjo inc -232 if ne == 0
azg dec -739 if j > -5
a dec -141 if qet == 567
a dec -731 if a < 2
i dec -839 if as < 8
v dec 855 if xbh >= -672
wl dec -602 if wl == -721
obc inc -613 if ebu == 340
j inc 605 if wui >= -148
kxm dec -192 if skh > -521
skh dec 551 if skh >= -512
xbh dec 340 if bx != -9
qet inc 156 if w <= -575
azg dec 627 if eh < -276
qet inc 7 if ne != 5
vjx inc -922 if as == 0
vjx inc -680 if k <= -623
as dec -807 if w != -576
tzy inc -808 if qun != 1458
wui dec -905 if a <= 740
bx inc 371 if n != -655
xbh inc 721 if n != -664
xbh inc 79 if w == -576
udh dec 217 if azg > 738
eh dec 300 if a > 721
k inc 684 if xbh >= -215
i inc -281 if qet >= 717
v dec -408 if kxm > 187
as inc 923 if xbh <= -202
v dec 640 if vjx < -1592
kxm inc 537 if xbh < -215
xbh dec 426 if eh == -564
obc dec -269 if c < 272
udh dec -256 if wl == -119
xbh inc -519 if v <= -1083
eh inc 134 if wl >= -117
azg dec 485 if eh >= -576
obc dec -134 if as != 925
wui inc 549 if udh < 42
eh dec -323 if obc >= -219
a dec 553 if w < -575
vjx dec 311 if qet == 726
vjx dec 602 if as != 930
tzy dec -588 if udh < 41
i inc 479 if eh < -238
eh inc 602 if j != 609
wl inc -800 if sdw == -811
qet dec -493 if k >= 48
obc dec -469 if v >= -1084
ne dec 100 if skh == -518
c inc 574 if tzy >= -225
wui dec -390 if bx > -7
ebu dec 786 if v < -1079
kxm inc -637 if i == 1037
as dec 378 if w == -576
ne dec -946 if v <= -1092
udh inc -433 if obc <= -220
azg dec 660 if w >= -581
v inc 61 if qun == 1451
v inc 644 if v <= -1025
udh inc 531 if k >= 52
obc inc 381 if n <= -655
xjo inc -485 if a != 174
tzy dec -526 if obc > 179
azg inc -831 if skh == -518
sdw dec 288 if sdw <= -808
kxm inc 759 if kxm != -451
n inc -847 if c > 839
skh dec 384 if tzy != -220
i dec -532 if obc > 163
a inc 570 if eh == 356
c dec 437 if wui > 1687
i inc -403 if vb >= 564
wui dec -223 if azg >= -1238
vb dec 370 if vb != 574
qun inc -251 if skh == -518
n inc 490 if iq < 594
kxm inc -542 if v >= -376
c dec 49 if kxm == 314
a inc -970 if xbh >= -734
skh inc -258 if j == 605
kxm dec 180 if j == 605
j dec 243 if k >= 54
vb inc 832 if azg >= -1231
udh dec 662 if tzy >= -229
c inc -327 if bx != -6
obc dec 973 if kxm == 128
udh dec 543 if vb <= 196
n inc 534 if qun < 1208
xjo dec -734 if eh < 362
j dec 629 if azg == -1237
wl dec -205 if qet <= 1219
qet dec -811 if a <= -214
azg inc -936 if sdw >= -1099
udh dec 222 if azg < -2172
j inc -526 if obc < 174
ebu inc -725 if n >= -484
eh inc 120 if i == 1166
wl dec 292 if n >= -487
k inc -718 if c == 28
qet inc -472 if ne < -109
ne inc -426 if qet == 2030
a dec 351 if iq < 600
sdw inc -446 if qet >= 2023
i inc 666 if qun <= 1194
obc dec -915 if udh > -315
tzy inc 281 if a == -573
udh inc -18 if as == 545
k inc 767 if as >= 552
as inc 84 if xjo != -641
vjx dec -321 if qun != 1204
v inc 799 if i > 1162
qet dec -575 if obc > 1079
vb dec -671 if obc < 1077
bx inc -976 if vb == 198
tzy dec 316 if qun == 1200
skh dec -352 if qet <= 2600
sdw dec 407 if qet <= 2605
c dec -398 if iq != 597
i dec 943 if a < -569
wui dec -455 if as != 625
skh inc 392 if k > -668
qun inc 162 if k != -667
xbh dec -311 if sdw == -1962
sdw dec 219 if wl < -1012
vb inc 610 if qun < 1372
bx dec 314 if azg != -2170
xjo inc 298 if wl >= -1007
iq dec -229 if vjx != -2194
obc dec -71 if kxm >= 127
k dec 936 if n > -485
azg dec -282 if v >= 417
j dec 8 if qet < 2614
j dec 599 if tzy >= -254
w inc -111 if v >= 416
skh inc -365 if wui <= 2375
vb inc 830 if qun <= 1362
bx dec -992 if qun >= 1366
obc inc -254 if obc != 1150
azg dec -557 if udh >= -326
c inc -438 if sdw >= -1953
eh inc 41 if as < 635
eh inc -725 if sdw != -1958
azg dec 515 if vb <= 1640
vb dec 149 if qet >= 2597
a inc 431 if wui < 2381
qun inc 596 if c >= -14
i dec -520 if a != -151
v dec -500 if j == -803
wui inc -581 if vjx == -2204
vb inc -753 if a < -139
tzy inc 309 if j > -796
xbh inc -182 if w > -685
qun dec -315 if j < -792
as dec 688 if eh < -202
bx inc -348 if ne > -533
n dec 198 if w >= -690
eh inc 179 if azg == -2406
qun dec -636 if eh == -19
skh dec 684 if a == -137
i dec -501 if wl < -1005
w inc -894 if obc >= 903
qun dec 529 if ebu < -1172
sdw inc -303 if eh != -34
wui inc -912 if bx >= -1630
wui inc 222 if bx != -1643
ebu inc -907 if c < -17
tzy inc -871 if tzy > -256
bx inc -119 if iq > 591
udh dec 56 if n > -678
qun inc -839 if vjx <= -2189
udh inc 867 if j < -791
w inc 26 if i <= 1247
i inc 633 if vb <= 745
v inc -384 if skh >= -757
ebu inc 876 if ne >= -529
udh inc 116 if a <= -145
a dec 179 if a >= -146
ne dec 643 if c == -12
c dec -490 if bx > -1764
qet inc 286 if ebu > -291
as dec -213 if i < 1884
sdw inc -80 if wui != 2597
xjo inc 59 if azg != -2406
n inc 640 if azg > -2399
k dec 444 if wl >= -1006
sdw inc -45 if qun != 1437
kxm inc -330 if bx >= -1757
wui inc 934 if i == 1884
qet dec 295 if azg > -2416
j inc 435 if xbh > -736
a inc -454 if eh >= -36
obc dec -533 if iq == 592
w inc 388 if ne > -1170
wui inc 866 if udh >= 474
wl inc -858 if vb != 736
wl inc -90 if vb < 745
wui dec 794 if vb >= 727
w dec -198 if eh <= -22
n dec 203 if qun != 1431
a inc 252 if bx <= -1757
udh dec 589 if vjx != -2194
azg inc 10 if azg < -2403
vb inc -293 if xbh > -739
udh inc -737 if a != -519
j dec -582 if obc >= 1433
xjo dec -892 if xjo == -337
qun inc 668 if obc <= 1443
udh inc -124 if bx == -1757
azg inc -210 if wui < 2665
i inc -312 if wl > -1087
ebu dec 356 if k > -2041
qet inc 928 if skh == -749
tzy inc 299 if i != 1874
vb dec 151 if vb <= 447
qun dec 936 if eh < -25
eh inc 782 if vjx < -2191
n inc 515 if j < 226
udh inc 482 if obc > 1434
azg dec -244 if n < -356
n inc -192 if kxm == -196
wl inc -573 if bx > -1760
sdw inc 423 if vjx >= -2195
c dec -72 if wui <= 2670
k inc 984 if a == -523
eh inc -288 if a > -525
ebu dec 855 if a < -514
kxm dec -261 if a > -533
wui inc -58 if udh == 100
sdw inc -304 if skh <= -742
vjx dec -86 if qet < 3247
w dec 163 if v >= 32
kxm inc 231 if ne != -1169
vb inc -291 if udh <= 97
v dec 759 if iq >= 584
xjo inc 390 if xbh < -728
bx dec -760 if j > 215
wl dec 370 if kxm > 57
kxm inc 871 if vb >= 285
c dec 4 if n > -556
i dec 813 if v > -734
v dec 129 if udh <= 100
qun dec -762 if ebu == -1150
v dec -415 if as >= 151
ne dec 366 if obc == 1440
udh inc 298 if a <= -533
tzy inc -245 if wl != -2038
i dec 992 if as > 151
c inc -400 if a == -523
wl dec 317 if qun < 1933
azg dec 174 if tzy < -1067
vb dec -780 if vb < 302
udh dec 273 if ne < -1166
obc inc -669 if wl <= -2354
as dec 843 if k >= -1064
as inc 902 if kxm < 944
qun inc -154 if i >= 69
j dec -894 if azg > -2334
as inc 233 if w > -1140
xjo dec 14 if xjo >= 940
sdw dec 999 if tzy != -1066
qun inc -351 if wl > -2363
kxm inc -503 if qet >= 3230
kxm dec -843 if bx != -1003
obc dec -318 if sdw > -3187
wl inc -243 if n >= -564
a inc -873 if sdw < -3179
bx dec 602 if wl >= -2601
wui dec 237 if c >= 145
wui inc -999 if qun >= 1420
w dec 329 if bx != -1599
a inc -550 if xbh > -735
ebu inc 359 if azg != -2328
tzy inc 965 if tzy >= -1067
wui inc -608 if c >= 141
vjx inc -168 if as <= 447
qun dec -183 if qet < 3241
xbh inc -456 if tzy <= -1069
j dec 581 if j != 1110
qun inc 677 if udh >= -173
udh dec 783 if xjo > 924
kxm inc 775 if w == -1132
k dec -961 if v == -440
qet dec 970 if skh != -753
qet dec 566 if vb >= 1064
sdw inc -639 if j == 1110
ebu dec -22 if kxm <= 2051
as dec 9 if tzy == -1072
w inc -513 if obc < 1083
k dec 669 if sdw <= -3822
obc inc -795 if c >= 142
n inc -980 if bx == -1599
obc inc 176 if qet <= 1697
j inc 517 if tzy != -1065
wui inc 394 if qun != 2276
tzy dec -833 if ne == -1170
eh dec 112 if k < -88
wui inc -648 if udh > -964
wl dec 918 if w < -1125
qun dec 846 if skh >= -755
sdw dec 287 if tzy == -1064
udh inc 902 if as != 443
skh dec 793 if ebu > -777
w dec 689 if j > 1621
j dec 415 if azg == -2326
obc dec -869 if k > -101
c dec -524 if eh == 353
j dec 519 if a > -1949
n inc -811 if xbh > -1193
udh dec 980 if qet == 1702
iq inc 358 if qun == 1428
w dec -719 if vb <= 1076
wl inc -543 if vjx >= -2284
vb inc -778 if wui == 517
iq inc -611 if azg != -2330
xbh dec 716 if azg < -2326
obc inc 997 if tzy > -1067
vb inc -645 if kxm <= 2058
iq dec -703 if sdw != -3819
xjo inc -766 if xjo < 924
obc inc 345 if c > 670
i dec 435 if qet > 1697
kxm inc 895 if ne <= -1173
kxm inc 387 if udh < -1041
k dec 851 if wui <= 508
vjx inc -957 if iq >= -26
wui dec -102 if wui < 523
ebu inc -441 if qet < 1710
qet dec -774 if vjx < -3224
skh inc -554 if qun >= 1431
xbh dec -924 if sdw < -3816
a dec 250 if qun <= 1438
xjo dec -430 if wui != 619
sdw inc -845 if kxm >= 2044
udh dec 607 if a <= -2191
w inc -940 if v >= -440
w inc -224 if bx == -1599
ne dec 856 if v != -441
tzy inc 431 if vjx == -3233
azg inc 370 if skh <= -2091
tzy inc 530 if qet > 2468
w inc 371 if vjx != -3233
kxm inc 348 if azg < -1959
n inc -611 if a <= -2190
k inc 365 if c < 681
kxm dec -734 if skh <= -2093
n inc 243 if w == -2266
skh inc 537 if j > 684
j dec -127 if wl <= -4066
n inc -903 if a > -2199
udh inc 685 if kxm == 2785
j inc 656 if v > -435
vb dec 193 if bx == -1599
eh inc -251 if ebu == -1210
qun inc 882 if ebu > -1215
k dec 705 if w == -2266
xbh inc -92 if sdw != -4657
w dec -689 if iq != -19
qun inc 962 if sdw > -4671
wui inc -476 if obc == 1504
azg inc 946 if i > -360
ebu inc 50 if n <= -3616
iq inc -284 if a == -2196
vjx inc -470 if v == -440
w dec 888 if ebu < -1151
a dec 369 if ebu <= -1153
udh dec 3 if kxm > 2777
qet dec -606 if tzy <= -106
kxm inc -483 if sdw <= -4661
vb dec 706 if tzy > -120
udh inc 111 if kxm >= 2296
iq dec 77 if xbh == -354
tzy dec -534 if sdw != -4655
tzy dec -300 if tzy >= 421
ne dec 258 if skh <= -1552
qet dec 363 if i == -357
ebu dec -16 if bx != -1591
eh inc -420 if a <= -2567
qet inc 674 if azg >= -1962
k inc 891 if azg != -1956
ne dec 730 if wl < -4058
ebu dec 497 if wui != 147
udh inc -969 if j <= 699
tzy dec 536 if eh != 101
xjo inc -70 if tzy < 193
xjo dec -873 if tzy < 188
udh inc -923 if k != -442
qet dec -56 if tzy != 193
wui dec -982 if sdw < -4661
iq dec 690 if qet > 3805
azg inc -961 if i > -360
udh dec 856 if wui != 1113
bx inc -710 if j <= 701
n inc 914 if i < -360
eh dec -772 if qet != 3812
ne dec 70 if vb < -470
j dec -460 if i <= -355
qun dec -837 if c != 674
w inc 961 if azg <= -1948
ebu dec -192 if k > -439
w inc 795 if xbh >= -359
wl inc 68 if v <= -436
eh inc 555 if qun >= 3288
vb inc 322 if eh != 95
xjo inc 995 if sdw != -4669
k dec 623 if w != -1388
udh inc 533 if azg > -1960
xbh dec 700 if ebu <= -1441
xbh dec 570 if udh > -3070
vb dec -434 if w == -1398
as inc 173 if bx != -2300
w inc 634 if bx == -2309
vjx dec -719 if i <= -361
w dec -796 if c <= 677
i dec -410 if azg != -1956
udh inc -738 if as != 602
vjx inc -617 if ebu <= -1446
ne dec -518 if ne == -3091
vjx dec 135 if n == -2704
wl dec 78 if tzy == 187
tzy dec 753 if wl > -4075
ebu dec 679 if c >= 683
tzy dec -276 if w <= 34
a dec 82 if wui < 1126
skh inc 473 if azg < -1948
udh inc -26 if tzy < -289
xjo inc 407 if eh == 102
i dec 909 if kxm >= 2306
udh dec -97 if xjo > 3564
tzy dec -858 if eh != 110
ne inc -102 if c != 678
iq dec -655 if iq >= -1063
tzy dec -283 if obc <= 1497
vjx dec 874 if udh < -3728
xjo dec -521 if tzy > 576
ne dec -532 if skh == -1086
j dec 316 if i != -362
sdw dec -256 if vjx >= -4612
ebu dec -695 if v > -443
azg dec 154 if k >= -1062
vjx dec 933 if sdw <= -4399
bx inc 696 if iq > -1069
skh inc -130 if wui <= 1126
eh dec -961 if c >= 669
bx inc 482 if k >= -1061
vb dec 177 if wui == 1121
n dec 169 if i == -355
eh dec 29 if xjo == 3558
xjo inc 59 if xbh == -1624
xjo inc 435 if wl <= -4074
udh dec -642 if skh >= -1224
iq dec 794 if udh != -3098
eh dec -962 if c > 673
wui inc 489 if as <= 613
iq dec -353 if v <= -435
iq inc -293 if n == -2704
n dec -667 if vb > 102
j dec 763 if eh == 2025
kxm inc 100 if i >= -367
tzy inc 757 if j <= 82
i inc -902 if i != -359
ne inc 3 if i < -1261
vb dec 272 if qet != 3818
skh dec -348 if j <= 76
w dec 399 if eh == 2027
skh inc 995 if c != 680
wl inc 343 if a > -2653
eh dec 628 if eh >= 2017
w dec 544 if azg >= -2116
bx inc 54 if xbh != -1624
as dec -724 if vb == -165
tzy dec 48 if vjx == -5543
sdw inc -837 if as != 1333
i inc 692 if obc != 1496
k dec -395 if tzy > 1283
ne dec -925 if vjx > -5549
xbh dec -670 if wl > -3735
obc dec 947 if wui >= 1619
k dec -480 if sdw != -5245
a inc -919 if vb > -158
wui inc 8 if qet == 3812
i inc -855 if eh == 1397
azg inc -41 if j > 74
xbh dec -945 if v > -431
xjo dec -95 if iq >= -1802
w dec -122 if kxm <= 2405
xjo inc -721 if bx >= -1833
xbh dec -182 if ebu < -751
obc dec 694 if wui >= 1614
tzy inc 755 if qet <= 3815
vjx dec -537 if c < 682
v dec 631 if qun > 3275
j dec -573 if xjo >= 2895
ebu dec 592 if xbh <= -776
xjo dec -748 if skh == 128
iq inc 30 if j < 657
bx dec 693 if sdw <= -5240
wui inc -953 if qet < 3817
qet inc 969 if xjo > 2909
as dec 963 if as < 1344
wl inc -997 if as != 372
xbh dec 514 if w <= -383
tzy inc 343 if xjo <= 2905
azg inc 470 if ne < -1725
kxm dec 126 if bx >= -2527
vjx dec -213 if c != 684
wl dec -491 if as >= 377
a dec -769 if azg <= -2114
obc dec 576 if qun >= 3286
udh inc 227 if obc != 805
ne inc 528 if v < -1062
as inc 124 if skh <= 135
a inc -896 if skh <= 131
k dec 949 if ebu == -754
c dec -541 if iq > -1783
wl dec -662 if udh > -2863
xjo inc -41 if qun != 3284
n dec -486 if iq > -1775
vjx dec 982 if obc > 803
kxm dec 349 if azg >= -2115
ebu dec -19 if bx >= -2515
xbh dec 199 if kxm < 1937
ebu dec -907 if wl > -4066
w inc 196 if bx == -2520
bx inc -534 if udh > -2871
skh inc 296 if iq < -1777
azg inc 169 if v < -1063
ne inc -187 if qet >= 3820
qun dec -15 if skh != 130
skh inc -909 if c < 1220
obc dec 583 if obc < 812
ebu dec -879 if qun < 3298
a dec 818 if obc >= 219
sdw dec 169 if as < 505
as inc 971 if sdw != -5422
wl dec 453 if a <= -4361
a dec 584 if udh > -2866
n dec 486 if w != -192
w dec -423 if iq > -1784
ebu inc 681 if as <= 1470
skh dec -585 if sdw <= -5421
qun dec -569 if n != -2038
bx inc -705 if qun >= 3857
w inc -198 if iq <= -1773
ne inc -345 if k <= -2005
vjx inc -368 if n > -2044
eh dec -267 if v == -1071
j inc 959 if c != 1222
c dec -544 if ebu < 1718
c dec -14 if xbh >= -1490
eh dec -746 if as <= 1458
azg dec 746 if tzy <= 2376
a inc -306 if c >= 1781
i inc 655 if azg == -2692
a inc -201 if eh >= 1666
bx inc 426 if qet == 3812
n dec 234 if c < 1776
azg dec -43 if qun < 3867
a dec 527 if a == -4945
iq dec 317 if qun != 3865
iq dec -685 if ne >= -1547
azg inc 309 if v == -1071
as inc 269 if udh <= -2866
a dec 764 if obc == 227
eh inc 918 if qun > 3861
udh dec 450 if wl <= -4509
eh dec -56 if j <= 1615
wui dec -557 if wl >= -4519
skh dec 479 if bx > -3340
skh dec 359 if kxm > 1917
as dec -754 if xjo <= 2868
eh inc -50 if wui >= 1213
xjo dec 883 if j != 1606
qet inc -687 if vjx < -6145
k dec 899 if udh != -3318
azg dec 242 if ebu != 1710
w dec -837 if as == 2217
ne dec 419 if obc > 225
skh dec -258 if qet != 3820
kxm dec -149 if azg != -2581
qet inc 264 if tzy == 2381
xjo dec -46 if qun <= 3866
w dec -772 if ebu > 1705
eh inc 7 if ne > -1955
xbh dec 149 if vb > -159
w inc 830 if xjo >= 2906
xbh dec -341 if v < -1062
obc dec -849 if w == 1633
qet dec 632 if ne >= -1959
j inc 599 if bx >= -3333
ebu dec -326 if vjx != -6133
i inc 752 if udh == -3313
iq dec 305 if skh < -1366
k dec 641 if eh == 2588
vb inc -652 if eh < 2597
skh inc -926 if v >= -1076
j inc -59 if k > -3556
wl dec 958 if wui < 1230
obc inc 871 if xjo < 2919
j inc -220 if k < -3540
c dec -411 if qet >= 3806
wl dec 874 if w < 1634
skh dec 285 if udh <= -3306
udh inc 627 if i != -1431
bx dec -633 if xbh != -1140
i inc -815 if wl >= -6354
c inc 892 if qet > 3811
wl inc 794 if azg != -2568
obc inc 103 if skh < -2566
k inc -188 if ebu < 2049
k dec -356 if vjx != -6149
sdw inc -314 if k > -3384
wl inc 198 if j < 1934
a inc -533 if i != -2251
ne dec -231 if iq <= -1084
ne inc -339 if tzy <= 2382
kxm dec 641 if w != 1640
iq dec 492 if skh <= -2567
sdw dec -229 if obc >= 2047
skh inc -194 if ebu <= 2041
xjo inc 275 if azg >= -2583
iq dec 826 if obc == 2053
sdw dec -993 if kxm > 1444
obc dec 15 if ebu == 2035
skh inc 297 if c <= 3080
sdw dec 748 if udh == -2684
v inc 793 if c <= 3083
obc dec -62 if qun >= 3861
vjx inc -703 if xjo >= 3188
wl dec 68 if ne >= -2077
udh inc 199 if iq < -1579
azg inc 991 if n == -2271
bx inc -554 if vb != -812
w dec -754 if kxm != 1445
vb inc -301 if iq <= -1582
udh inc 849 if wui < 1231
qun dec 495 if xbh == -1144
n dec -349 if w == 2387
n inc 172 if wl < -5416
wui inc -192 if wl <= -5426
vb dec 676 if kxm != 1436
n inc -365 if as >= 2224
eh dec -938 if vb != -1492
j dec -936 if j >= 1923
eh inc -889 if qet != 3802
tzy inc 629 if iq <= -1574
bx dec -333 if c <= 3073
j inc 118 if c <= 3085
bx inc 217 if eh >= 2640
xbh dec -587 if wl >= -5428
kxm inc 9 if tzy != 3011
qet inc 433 if c != 3074
tzy dec 408 if obc > 2108
ne inc -17 if vb >= -1502
tzy dec -223 if azg == -1586
azg dec -925 if azg >= -1580
bx dec -645 if tzy >= 2823
eh dec 870 if sdw > -6252
obc dec -355 if udh != -1645
ne inc -191 if obc != 2477
c inc -88 if wl < -5417
skh inc -36 if sdw > -6251
w inc -404 if sdw <= -6247
as inc 126 if vb <= -1491
iq dec -456 if c != 2991
skh dec -407 if v > -278
a dec 621 if iq > -1135
xjo dec -514 if kxm != 1447
wui dec -912 if iq != -1124
xjo dec 373 if c == 2982
ne inc 61 if ebu != 2048
qet inc -691 if iq == -1125
as inc 553 if vjx > -6148
qun inc -479 if qun == 3370
tzy dec -851 if ebu == 2039
xbh inc -52 if skh >= -2514
udh dec -853 if wl == -5423
udh dec 868 if i != -2245
wl inc 665 if w < 1986
qet inc -975 if w == 1983
kxm dec 677 if kxm < 1446
i dec 964 if j != 2978
i dec 719 if a <= -7385
w inc 142 if qun > 2887
xbh inc 547 if sdw >= -6256
ebu inc 102 if azg > -1592
i inc -255 if v <= -272
udh inc 681 if c < 2987
a inc 535 if qun >= 2887
udh dec -66 if xjo < 3707
vjx inc -496 if j != 2985
tzy inc -131 if v == -278
wui inc 414 if azg >= -1579
vb dec -579 if qun < 2896
v inc -275 if kxm != 767
vb inc -848 if w > 2127
j dec -601 if vjx > -6641
bx dec 311 if wl < -4756
n dec -995 if kxm != 764
iq inc -35 if sdw == -6247
sdw inc 153 if v >= -271
iq dec 219 if j == 3589
tzy dec 183 if j > 3577
a inc 193 if a > -6858
qet inc -847 if xjo >= 3697
iq dec -515 if n <= -755
j inc -690 if j == 3581
v dec -478 if a == -6662
n inc 602 if wl < -4753
xjo dec 532 if ne > -2213
i inc 958 if bx != -3556
k inc -587 if a <= -6662
c dec -82 if eh > 1763
vjx inc 668 if j < 2891
ebu inc -357 if as < 2906
n dec -283 if ne == -2216
w dec 778 if iq <= -640
vb dec 408 if ebu < 1784
azg dec 271 if vjx != -6639
udh dec -46 if ebu != 1784
k dec 628 if azg >= -1592
vb inc -962 if obc < 2467
wl dec 408 if v != 198
a dec 554 if vjx < -6631
c inc 442 if udh > -1591
i dec -417 if eh >= 1763
qet dec -856 if c > 3519
iq dec -144 if as < 2899
sdw inc -229 if skh != -2507
i dec -920 if i < -2800
qet dec -244 if n != 138
vb dec 811 if k != -4600
k inc 560 if qet != 1976
v dec 42 if w != 1342
a inc -588 if skh > -2514
qet inc 56 if obc < 2472
i inc -870 if eh < 1770
ebu dec -915 if w >= 1345
xbh dec 455 if i <= -2752
xbh dec 384 if xjo <= 3699
wl inc -895 if xjo != 3692
kxm inc -190 if sdw <= -6475
vjx dec 450 if xjo != 3698
skh dec 0 if skh > -2514
xjo dec 896 if udh >= -1589
udh inc 811 if k > -4587
eh inc 520 if n != 130
iq inc 873 if i == -2756
eh dec -76 if skh == -2506
ne inc -833 if wl <= -6057
tzy inc -687 if xbh == -901
n dec -232 if iq >= 223
vjx inc -968 if qet == 2032
as inc 503 if c == 3512
a inc 952 if qun != 2892
c dec -290 if wui >= 2128
a dec -777 if wui != 2140
qun inc -472 if tzy >= 2664
vb inc -589 if qet < 2041
tzy dec -548 if v > 153
wui inc 152 if ebu <= 2706
w dec 905 if tzy != 3224
udh dec -241 if obc <= 2473
v dec -532 if sdw <= -6473
bx inc 818 if wui == 2281
skh dec 547 if a != -6070
qet inc 146 if a <= -6067
n inc -528 if iq != 232
qet dec -864 if ne < -3044
qet inc -121 if azg < -1583
i inc 363 if vjx > -7609
k dec -105 if ne > -3040
a inc 480 if i <= -2398
udh inc 173 if ne == -3049
n inc -712 if as < 3405
j dec 597 if bx == -3565
sdw inc -637 if vb < -2311
qet dec -871 if obc == 2458
tzy dec -927 if bx <= -3560
xjo inc -471 if w == 442
wl inc 976 if j < 2304
tzy dec -505 if xbh <= -894
a inc 929 if azg == -1586
eh inc -265 if n < -877
w dec -393 if obc < 2469
a inc 406 if xjo > 2324
c inc -437 if j < 2301
a inc -589 if i <= -2399
c inc -101 if obc < 2471
iq inc -478 if iq <= 232
xjo dec 635 if v >= 685
w dec 485 if vjx == -7604
wl dec 490 if eh >= 1571
wl dec 923 if k == -4595
azg inc -237 if bx == -3558
azg dec 820 if vb >= -2322
kxm inc -371 if qet < 2918
i dec 405 if wl != -6507
qun dec -596 if udh > -1178
v dec 973 if wui == 2286
as dec 840 if sdw <= -7121
udh dec 373 if w <= 831
ebu dec 372 if iq > -253
n inc 469 if qet == 2916
udh dec -123 if obc > 2457
wui inc 517 if c != 3270
wl dec -729 if kxm < 578
vb dec 934 if wui >= 2800
qet inc -307 if wui >= 2803
sdw inc -935 if c <= 3266
tzy dec 14 if w < 841
k dec 167 if eh <= 1579
j dec 438 if bx >= -3573
obc dec -452 if azg >= -2415
xjo dec -41 if ne > -3056
qet inc -482 if qet != 2614
obc dec 390 if bx >= -3571
v inc 289 if azg <= -2410
k dec -777 if azg <= -2397
xjo dec 658 if azg <= -2406
c dec -681 if ebu > 2332
n dec 877 if ebu != 2334
ne inc -602 if azg > -2410
w inc -334 if eh == 1574
c dec 64 if sdw < -8051
bx inc -76 if udh > -1043
vjx dec -169 if c >= 3263
as inc 941 if vb != -3248
i dec 131 if xjo < 1084
as dec 222 if n <= -1750
i inc -249 if wui < 2811
obc dec 28 if tzy == 4635
n inc -816 if xjo <= 1087
obc dec 872 if qet >= 2624
vjx inc -201 if ne == -3649
eh dec 602 if iq >= -250
w dec -596 if i != -3188
w dec 212 if vjx < -7436
xbh dec 523 if kxm == 577
n inc 962 if v <= -281
iq dec 30 if c <= 3268
obc dec -300 if sdw == -8050
vjx inc 125 if eh <= 984
sdw inc -470 if j >= 1854
vb inc 295 if udh >= -1045
skh dec -79 if wui > 2795
skh dec 307 if iq <= -272
azg inc -74 if j != 1865
qun inc 745 if as == 3182
i dec -928 if wui < 2809
obc inc 63 if wui >= 2800
xjo inc 114 if ne < -3644
qun dec -92 if as <= 3185
obc inc -363 if w != 1211
tzy inc 194 if ne == -3651
xjo dec 569 if as < 3185
i dec 295 if j >= 1848
ne inc 946 if w == 1219
skh dec -149 if j >= 1866
kxm inc -579 if c != 3271
a dec -979 if iq < -275
xbh dec 281 if k == -3985
xbh inc 88 if obc != 2207
vjx dec 881 if udh <= -1042
i inc 641 if qun < 3117
vb dec -132 if vjx != -8192
udh inc 952 if obc <= 2195
ne dec 562 if iq > -287
xbh inc 673 if wui <= 2800
bx inc -737 if kxm != 8
w inc -766 if wui >= 2798
tzy dec 838 if vjx > -8198
i inc 435 if obc != 2195
a inc -582 if wui > 2796
azg inc -87 if vjx == -8194
udh dec 634 if ne >= -3274
j dec 235 if kxm != -2
v dec 143 if vb < -3114
as inc 70 if bx > -4308
w inc 864 if n < -1616
bx inc 959 if n < -1604
tzy dec 933 if i != -1469
ne dec 369 if ebu > 2320
v inc 387 if qet >= 2621
qun inc 616 if k != -3985
xbh dec 901 if skh != -3276
k dec 770 if bx > -3347
c inc 345 if azg > -2567
sdw inc 485 if udh != -1672
ebu dec 697 if xbh == -2515
qun inc -223 if obc < 2203
vb dec -329 if as == 3250
i dec -828 if qet == 2614
i dec 457 if ebu > 2317
c inc 859 if vb >= -2794
vjx dec -324 if xbh < -2519
tzy dec 350 if sdw >= -8037
wl dec -546 if a <= -4346
ne dec -422 if vb <= -2784
iq dec 933 if udh == -1682
vb dec -354 if w < 461
as inc 222 if ne == -3211
i inc -488 if c == 4123
v inc 466 if bx < -3338
vb dec -779 if iq < -1208
i inc -54 if i > -1581
vb inc -124 if as > 3248
qet inc -25 if i >= -1586
ebu dec -572 if qet == 2589
bx dec 699 if k >= -4763
iq inc -184 if kxm != 2
kxm dec 986 if xbh <= -2515
j inc 904 if vb != -1773
a dec 862 if vb == -1778
wui inc -604 if ne >= -3223
a dec 682 if qun == 2884
qun inc -315 if iq <= -1395
n dec -930 if qet < 2598
n inc -532 if iq <= -1406
w inc -921 if xjo > 618
bx dec 728 if a > -5891
skh dec 463 if sdw > -8038
i inc -119 if c != 4128
n inc 651 if ebu >= 2894
xjo dec 978 if eh != 982
i inc -948 if n == -28
skh inc -459 if v < 41
j inc 625 if kxm == -988
skh inc 38 if k >= -4757
eh inc 207 if eh > 968
k dec 771 if sdw < -8027
vjx dec 73 if qet <= 2592
j dec -53 if iq >= -1403
vb inc 952 if vjx <= -8263
azg dec -345 if as > 3240
w dec -802 if ebu <= 2901
azg dec -861 if iq <= -1394
xbh dec 160 if xbh > -2522
vb dec 170 if wui != 2201
xbh dec -607 if azg <= -1361
obc inc -204 if as >= 3245
n dec 717 if wl == -5769
tzy inc -417 if qet < 2594
qet inc 516 if kxm > -990
tzy dec -355 if azg < -1356
xbh inc 946 if eh >= 1192
iq dec 221 if ebu <= 2904
c inc -692 if vb > -1006
xjo dec -599 if obc < 2004
ne inc -255 if vb >= -1000
vjx inc 144 if sdw != -8038
tzy inc -905 if ne >= -3467
j inc -71 if qet < 3108
as inc 289 if skh == -4165
i dec -621 if azg > -1371
xjo dec 703 if w == 334
wl inc 657 if azg < -1358
n inc 152 if sdw < -8041
skh inc 258 if vjx == -8123
iq inc -613 if w >= 330
azg dec -55 if azg < -1366
w inc -504 if n == -745
vjx inc -100 if kxm < -996
j dec -699 if tzy > 3577
wui inc -120 if i > -2038"
  end
  def day9 do
  ~s({{{{{{{<!>!>!<u,!>!!!!!!!>!!!>,<<!!">},<!!!>,<!>,<}>},{{<>},<>}},{{{{}},{{{},{{<!>,<!>,<,'e!!'i'!!<,u>}}},{<ia!!!!!>"!>},<!!u!!!!!>,<a!<!!!>>,{<!!{!!',,u!!!>oo'>}},{{<o"!!!o{a>}}}},{}},{{{<!!"!>,<!a!o!!!>!!!{!"!!!>},<o>,{<!i<{}!!!><>}},{}},{},{{{},{<,!>},<!>,<!>},<,!>,<!}!!!>>}},{<{!>,<{oi!a{a!!e!>},<o!!!>>},{<e!','a!!<!i{a},!!!>!>},<>,<{}}!!!>ao!!i}"o!!!>,<i!!>}}},{{{<!!!!<{!,e!!!>>},{<ue!>!!!>o'>}},{{{<o'"ae!!!>e!>,<"!!o!!!>!>},<>,{<}"u!}o!!u}!>},<!!!>oa<!!,>}},{{{{<'<'!!{!!"oeu!!!!ui>},{<,!<!!!>,<!!!>},<!}}!!{!!"ou"!>,<>,{<<,,!!!>i!!<<!>!!!>,<>}}},{<<a<au!'!!!!!>!>!e!!u"e{!!!>},<>}},{{{<!!!!i!!!>!>},<!!!>e,!>!!!!!>!!'"{}>,<"!>},<!!}'!>,<o!!!><>},{{<,!>},<}!!,i!>},<'"<!!!>,<,!!ei'!!a!>},<i>},{{{<{e!!!>,<u!>,<!>},<'!!!>a!!!>}a!!>},{<!!,>}},<!!!>},<,u!!!>,<o>}}},{<!>},<"<!>},<o!>},<!!!>!>>,{{{}},{<!>},<"!>!!}e"!>,<!>},<{"{!!},!!!!!{"<'<>}}}},{{{{<!>,<!!!>o!!}!!!>"!>,<i}}!o!>,<"e!>>}},{{<'i!>e!!!>},<!>!>,<a!!{u!>>,<o!!!>>},{<!>,<>}}},{<o'!>!o!!!>!!!!u!}',!!{!!!>}!!!!!>>}}},{}}}}},{},{{{{{<!!!>{<'!io<,>},{{{}},{{<!!'u<ae>},{{<!>},<!>},<}!>,<}!!{!!!!u,!<!>,<i!<"}<>,{<e!>"i!!'!!a!>},<!!!>o<i!>},<o!!i!>>}},{{}}}},{{{<!>a,"!e>,{<!!!>o!!iu!>},<{!>},<!>io!!{!>,<i<>}}},<u!>,<!!!!<a,}!>'!!'ai>}},{{{<u<!a!>},<!!"a,!!!>,<!>},<eu{}>}},<!!e}!!'!!!>!i!!{!>},<!!!!!>,<<>}},{{{<a!>!>ua!!!>!>},<!!u!>!"!!>,<!>},<{!!!!>},{<!!!>,<!!!!{!>,<!>},<!!"<}!>{,i{'!>,<!>,<>,<{<'<!!!>,<eo}>},{<!!<!!>}},{{},{{<"!>!>},<a,,!>},<}!>!e}<<!a,>}}}},{{{<o'i>,<!aai"!!!>,<!>,<!!!!'!u>},{{{<"<!!!!!!"!!!>u!>,<!!!>>}},<ia!!a>}},{{},{{<!,u!>},<}!!u!!{!>,<>},{{<!>},<}{o}!>},<!>},<ui!>,<!!<!>!>},<>,{<'!!'o}}i!!!!!>!!{<,e>}}}},{{{{<o!!!>!!!>},<>}}},{<oo!>i!>},<!!!>!>},<}i'<!i,!>},<!!'>},{<a,o!!!>a!!!>>,{<aae!u<!>},<e!>}o!!!>}!>a'ia>,<"!,i,e!'!!e!>,<!"!!!>i!>},<>}}}}},{{<!>uu<">,{<'}!!!>!!!><{!!{",!>''o>}},{<u!>},<{!!!>{!!!>,<o'o{">,<o!{"{!{!>},<!>,<ei>},{<!!!>,<!{}a!!e<>,{<!a!!i<ua!!o!!!>,<!!"!>}!>},<i'}a!>!>>,{<!>,<<!>a"{""!>e!>,<<<>}}}}},{{{{{<a,!!!!!>!>e}!!,i}a,!!u}e,a{>}}}},{<!>,<>,{<,"u"!!!>a!!e!!!>>}},{{<ie!!e"!><!>,<'>}}},{{},{{{{{},<!!e>}},{{<{!!"{}e!>}u!!!>u!"!>},<ue>}},{}},{{<aau!>,<!>!>,<}"!!!!a!o!!!!!!}<!!{!>,<'!><">,{<!!{!{!>,<e!!',!!!!eue!>>,{<a!>,!!i}!!'}!!}!!ueu!!{}!!!!!>{u>}}},{{{{<!!,oo!>,!!}a!!"!!!>!>>,{<!>}<"!>},<!!!><!!!>,<ue<!>'>}},{<{,!>!'a<<!>,<a!>!!!>!<}<<>}},{<{!!!!!>},<,!>'<!>e}!>,<i!!!>'!!>}},{<!o!!!!!>o!>},<u<!>,<!>{}!!a!!a>}}},{{{<eo!>,<!!"}ee!>},<ua!>},<!!!>iu>}},{{<}'a"!!!a!'{!!!>!!!>!>!>o!a!!}!!!!!!!>,>},{}}},{{{{{<!!!!!>!,<}!!!!!>,<a!<<a!!!>>,<!!u!>e!o!!!!!>!>},<!>e!!!!!>io!ie'!!>},{<!>,<"!>},<<ou!>},<ei!>,<i!!!>,<<{o!!!!!>{>},{<!>,<ao>}},{{{{{<<o!>,<"a!>o!,o!!!>!"ai'!!'>}}},{{<!!"ea'}aei!!a!!!!<ia",>},{<>}},{{{<!>i!}e,io<u!!!!!>,<!>},<i!!}i>},{<!a"!!a}!!}>}},{{<>}},{{{<!u!>!},e"!!!>ue,!>!>{!>},<{'}i!>>},{<'a,"!>a>,<!!!>!>,<!!ia"!i!!!!!>,<{>},{<ie}}'"a!>,!>,<>,{<>}}}}}},{{<}!{i!!}!!!>i,!>,<}"a!!i!o>,{{<e}>},{<ie!'!!<!>},<i!!!>,<!!u!!{>}}}},{{{},{<o!>,<!>,<!>,<!!!>!!!!!!}!>{!!i!>oe'>}}},{{{<!!e!!o{!>,<ei!>,<,u<o!!!!!><>,<!!e!!!!!>>}},{{{{}}},{{<a!!!>},<o<!uo!>'!{!>},<,},!>,<e<>}},{{<!ai">},{<a!>a'{<>}}}}}},{{{}},{<!!>,{<!>},<!!!>},<{!}e>}}},{{<,!>},<!!ai'i!"!>,<!>},<"{"u!>>,<<!>,<!>},<!!'!a!>},<!!!>!>},<'!!!a}'>},{{},{},{<,!!e!>},<!>},<!!!>!>},<!a!>},<"!!o!>u,<,,!!>}},{{<<a!>a}!a!!!>},!!e'{!!!!'!!!>!!!!o>},{{{<,>},<}!!!>">},<io!!"<i<{}!'!>,<,{!>>}}},{{{<!>!>!>!!">,<!>!!!>!!<'}'>},{{<o!!{a!!!>'"!!>,{<!!!>o!!!>,<o!!!!i{<'}!!!<e,>}},{}},{{{<a!>o<o!>u!}i!>},<!>,<,"!!a,''!>},<>}}}},{{{{{{{<<!>},<>},{<o!!!!!>},<!>''o}o!!<"u!>},<u!!!>e!!!!!>>}},{<!>,<a,ae}',{}ua<u!>},<,eu>}}}}},{{{<!!!>,<}'<<{{!!e!!!>{i}!>},<!>,>,<}!!<i!!!>},<{!>},!!!!i!<!'!!,!!{u<!>>},{{<"!>,<'"<!!!!!>"{!>>,<ea}"!o<<'ui!!<o>},{{{{<}o>}}}},{{}}},{{},{}}},{{<a!"!>},<}!!!!!!!>u!>,<<a!!i"o,o!,!!!>>},<!!!>!!!!ai!!!><!!}!>"!>"'"e>},{{{<e,!!'!!!,!>,<}au!>,<!><"i',<">,<!>,<{"'}i!>},<}!>,<,>},<>},{{<'e>},{}},{{{}},{<e!!i>}}}},{{<,>,{<ou!!!>!,}'i"!!e>}},{<o!u!!!!u!!!!<!!}!>},<<!>,<!>,<!!{!!ue!>eie>,{}},{{{<!o!>'o!!u!>"}'!>!!!!!>!>},<}">,<}",e!!!!!>"!>},<!>>}},{<a!>,<i!!!>,<!>u!}!!u!!>},{<},!!,ioi!!!!!>!>'!!!>u>}}}},{{<!!!oa>},{{{<{a!>},<!!!>!!i{{u">,{{}}},{<i<{,,!!}!!u!>}u>,<!!iu}!!<ua!!!!!>>}},{{},<!!>},{<!>},<!!!>!>},<i}<!!!>!>},<{,>}}}}},{{},{<!>!>!{o!!!>!>},<!>},<<!>,<{!!'!!!><!!u>,<"'>}},{{{<{!>!>!>!>!>!>},<!>e!!!!u!!!!!>u'>},{},{{{<>}},{<!!!>{<!>,<{e!!{!!!>"u!>aa!!!>,<>,{<!>">}},{{},<oa!>>}}},{},{{{},{<{e'!>,<ioo!!!!!>,!!!>>}},{{{<,{"!!!>},<e"'e,iu>},<u!!!>!!!,!!iuuue"au"{>},<}>}}},{{{{<'!>},<e!>!"!!!>!!!!a!!{a!{!ieii!!!>!o>},{{<!>,<!>o{!!!>},<!!!><!>},<i!!!!>}}},{{<a!!'o!!>},{{<!!!!a!!ia!!<}eou"!'!>},<'>}}}},{{{<!!!!,}!!!>},<!!!!!>,<>}},{{<{!!!!!>"!>},<!>,<i!>},<!>,<!>a!>},<!>,<{,!!!>!!!!uo>},<,!!u!}>},{<o!!!!uo'e!}a<o!!!,<!!o"{>,{}}}}}}}}},{{{{},{{<<<>},<!!!>{!!!!i{!!!>oo>}},{{},{{{<ea'ue!>},<!>{!}>,<,>}}}}},{{<>,{}},{{{<!!!>'}{o!>,<!!!>!i!!!>,<!>,<!!'"!!!>!!!>}>},{{}}},<!!!>"!!!!<!!'!u<!>,<>}},{{{},{<!!,!!{!!!>},<!!!>>}},{<!!!!!!!>o!!>,{{<u}i!>,i!!,i}e>},{<!>},<!!"!}!>,<!"!>},<!!!>!!<a!!a!>},<!!!>>}}}},{}},{{{{{<e{!!!><}ei},e"!!!>!>},<'>,{<<!!!!!>,e!e}!!!>},<i'u"!>,<>}},{{}},{<"!i!>!!{!!{o!>},<!i{!>,<>,{<ei,>}}},{{{<!!!><!{a'oo>}},{<a!>a!'e!>,<!>,<>}},{{{},<!>},<!!!i!!!>},<!>,<,o!>},<}!!!>{!!e!!!!u!!<<!!}!>},<!>,<}>},{<ae!!!>{>}}},{{},{<!>!>,<!'!,"e!>o,!!!>!>,<e,}!!<o,>}},{<"{!>,<<i!!!!o{<o>,{<!!}>}}},{{{{<!!!>}!>,<i"!!i"eoieaaii!!!>u>},{<!!}e!!e>,<!!!!<aie!!o!>},<!>,<!>,<!!!!!>!!<!eu,!>u>}},{},{{<!'!>,<<!auo>},{<!>,<>}}},{{<!>},<'"!a!!!!{!>!>,<o!>},<u!>!{}!>>},<o'e{'a"!!!>>}},{{<},"!o!>},<,,!!!>,<!>!!!>!!!>a!>>,{}},{{<<e"u>},{{{<!!,>,<>},{{<!!!><!}a!i!!}!>},<o!!"''e>},{}},{{}}},{<"!>},<!>,<!'!"{!!!!!>},<!>},<>,{<!!!>e!!!!!>au!>},<{ue>}},{{{{<o,!>!!!>!!ua!>!!!>o!}}>},{}},<i!>},<<e!u{eua!e'},>}}}}},{{<ee!!!>'i!>auu!!{{!>">,{}},{{<u'!<!>},<!>},<!!!>'!!>},<a!!!>"e!}!>}>}}}},{{{{<!!!>!"<,!!,ua{!}'a'!a!>,<!>,<>},{{<a'!{,""{u!!{<!>u!>{i!>,<!!!>,a>},{{},<!>!!!>!!!>},<!'!!,i,ii!!!!!!!><'!!!!oi,!!>}},{{{}}}},{{<,!!!>,<,u!!!'ia,>,<!!i!>},<!!{<>},{{{{<!!!>i{e!>,<i,!>},<u!>,<!a,o!>},<>}},{<!>,<e'>,<ee!!!>a!!!>},<<!>>}}},{<o{<e!!!!!>!!e'!>,<"u>,{<!!!>{"!!!!!>!!!>"u{">}}},{{{<!!"eo!!a}<{'>,{<u>}},{{<e,,>,{{{<o!!!>o!"!>{{{!i'!><!>,<!>,<>},<a'!!!!!,u!!e<!a,>},<"!!ue>}},{},{}}},{},{{{<!>a!!!>!!!>!!oo'o!!<}{i"!>,<'u!>},<e>},<i"!!!>ou'!>,<!!!>},<"<<{i>},{{{{<!!!>o<<"{!!}a'",,!!!>"!!!><>}},{{{<!>,<eau>}},<eee},!!eo!<}>}},<u!!}oe>}}},{{}}},{{{{{<ai!>,<'{>}},{<e!!!>},<!>,<!><!!!>a>}}},{{<!!<!!!>},<!>},<a<<!>!"!>,<e{>,{<<"!>,<>}},{{<,o!>"!<u!>,<!>,<u}!!!!>},{{<o'>},{<,!!!>!o>}}},{{},{{<,!>!>},<>,{<!!!!!!"o!!"!!a!>,<!>},<>}},{{{<!!}!!!!!>o!!!>{!!>}},{{<!!!!!>,<e'u!>},<'u!>},<u!>!!e,e">,<o!a>},<euoo!!!>>},{{{{<!!!>'o{>},{{},<e!><>},{{},{<<e,!!!>!>},<}!>,<!>},<'{ee!>,<e,>}}},{<{{<"{u<!!!!i!!}!>,<''{"!!!>>},{{<!!i!>,<"!!{'<e!e{!!!>,<<{!>},<!>!{!!!>!>},<>},{<,iu!!'},ao!!au>}}},{<!!!>i,>},{<ee!>i<!!u{!!!>oa'}>,{<,e'>}}}},{{<!>},<<,,>,{<}>}},{<u}!>,o{!<<,!>,<e,!!a>}}},{{<!"!>,<e!>,<o!>!>},<a}!!eu!>},<!!<>,{}}}}},{{{<>}},{},{<"!ui!>},<!{<!<!ui"'!>u,"a!!!>'>,{<!!i!>,<"eae}a>}}},{{{{}},{{{<!>},<"ei!o!!!>,<{!>,<!!!>e,a>},<!!<>},{<!>""ii'e{e,!!!>,!>,<{>,<!>!!!>,<o!!}{e!!!>i!>,<!>!!!>!<a<{!>},<!>},<>},{{<!>},<!>'e"!!!!!>,"}',"!!!>!!e!!uu>}}},{}},{{{{}},{}},{{}},{<!>},<}!>},<!>},<!>,<o!<!>"u{{ea!>,<!}!>>,{{<<<!>},<o,!!!>{>}}}}}},{{{<<!>},<!>,<>},{{{{<!>},<"!!u!>}!>,<,!>,<!>,<,,>},{<!!!>{!>},<"!>,<!!!!!i,!>},<!!!>},<},i!><>}},{}},{{<!>!!!>"}!!"{!>},<!!u"!!{e}au!!>},<i<{!!!>e'!!!>eu{a"""{a!!!>!!!>>},{{{}},{}}}},{{{<!!'!>o!>},<i!"i',{a>},<>},{},{{<'i!!{i}<ii'{oi'a}u!!ei!!!u>},{<>}}},{{<'!!!>!!a<u!>,<}!i},">,{{{<!>!>,<!!!>a!>!>},<!e!!!>!><">},<!>,<e!!'u<<<!e!'>}}}}},{{{{{{<{',"!>},<>,<}!uaa!>,<<eia<ie>}}},{{{<<",i'>},{<u'!>e<!!aa!!!>,<!,!'>,{<!!!>,<uu,!}!!,uia'e!!ie!!i!a!!!!{!>},<>}},{{<!u!!!>},<!>,<!>},<!>},<">}}},{{{}}},{{<,<{e!!!o!>},<!!!>'i!>,<!!!>a}>},{<a!!!>},<i'!,!!{!>},<!!}e>,{}}}}},{{{<{!>!!!>,>}},{{<!>eo<'u!a,'iu<!i!}!>},<>},{<}<!>},<!>},<>}}},{{{<!!!!!>!!!!<'"a!<!>,<"!>},<o!!o>,<}e<ou!>oa!}!!!>!!}iu}!>>},{}},{{<>}}},{{<e'i>},{{<<!>!!,>}},{{<a>}}}},{{{{{{{<>},<"!!{!!!!!!!>u!!!>a!!,a'!}}!!'!!!>>},{<!>,<!>},<u">}},{{},<!>!>},<!!a!'ee!>,<}eoiao!!!!!!!eu>}},{{<"!!,!!!>},<!!}!!!>i!!!>,<>}}},{<i{<!!a!!!>!>},<,!!!!'>,<!><!!,!uo!!}<{uoo,'!!!!!>{>}},{{<e>,{}},{{<"<!>},<!>u!>!>,<i!!a!!oeo}}o"!!">}},{<!!!,!!a!>},<i!>!!!>},<!u<!!!>>,<{"!!au'"u<ua!>,<,,>}},{{{{}},{<<ei{!>,<>}},{{{<,!"!!"!><}ai!!!!!>!>!!!>!,ui>},{}},{},{}}},{{}}},{{{{<!!}o}!!"}<!!}'!!aao}!!!!e>,<>},{{{<!!!>i!>,<!!!>!>u'!>,<,>,<!!"!>,<a!!,!!e!!!>a"e!!!>!>>},{{<!e},eouua!!oooeo"oo!!!>>,{<eu,!>!>,<!!!>!>}{<!>,<!!!>!>!!"!!!,"i'a>}},{<o'!>},<!!!>e!!!!}''oo!>,<"<>,<}o!>'!!"!>},<!>},<"!}e!!!>!!},>}},{<}i,<!!<u>,<{!!!!<"}>}},{<",,i,e{!!!>,<'i<!!!>},<>,<<!!!>}u!!"o!>!">}}},{{{},{{<a!>},<<}'o!>,<u",!!!><!>,<!'<ae!>>},<a!>,<uoo!'!!i!"!!!!!>!><'"u!!!!!>,<a}>},{<!!!>,!>},<,!!o<i!>,<iu!!,i!!!,{>}},{{},{{<a!>},<'!>},<!ea!>!!,">},{<!>},<>}}},{{{<a!!!>!!<!>},<a!!ou!>},<e,!!i!uo!!!>!!{'>},<!>},<o{}"}!>,<>},{{{{},{{{},{<!>},<!>},<}!>!!o<>}},{{{<!"'<"!!!!!>a!>,<e>}},<!!!>}!!"!!u!!!>},<}!!!>},<,"}<!!i!!!>>}}},<!!!>!>euo!!,u!!!><!>!!<eo!>,<a!>,<>},{{},{{{<!e!!<!>},<!!!>,!ou{!,>}}}}},{<!!!>!e!>ee!!"!!!!!>aia'{!>,<>,<<e!!!>{!>!>},<<}>}}}},{{{{{{<!!'!<>}},{<{!"<a!>}a{<e!!"!!},}'>}}},{{{{<!>!!'!>,<,u!!!!i!!a!>!!e>}},{<,{!>,<!!!>!a!>,<{!!!>!!>}},{{{<,ao!!<{!>{'!>},<u!!!>!!!>o!!!,!>,<"<>}}}},{{{{{}},<!!!!"!>},<!>},<!>,<o!!<!>},<!!o{!>,<<oau!!!!}>}},{<!!!>!>!>,<<!>e,>,{}},{<,!!!>!>,<}!!eao<{,!!a"!>,<!!!>!>},<o""!!">}}}}}},{{{{<o!!!>!>},<'!!>},{<}{'!>'!!"{!>u!'"o{"a!!>}},{{}},{{<!!!}!>},<{{!>!!u!i>},{{{}},{}}}},{}}}},{{{{{{<>},{<>}},{{{<!!!>,!!!>!!u>},{<!ua!!!>!!>,{}}}},{{<e!>},<!>},<!!{ia!!!!!>>}}},{{}},{<}!a'}!>,<<!o!!eu!>},<!!uu'!!!>"!>},<!!e>}},{},{{},{{<!o<!"'"!!u<!!iu!>!>},<<ai>},<>}},{{{<!{ii!!}i!>,<a>,<!>!>,<!!,>}},{<!>'o,!!i!!<oo!>,<u'!>i!!!>'>},{{{},<>},<i!!!!,}!!!!aue>}}},{{{{{<!!a!!!>"a!!!><"euoe!">},{<au,o}!>,<>}},{{{<!>!>,<a,a!!!!!>'!e!u"!>,<!!>}},{<!!!a}!>,<o!<{!{!>,<!!!>}a,"!!u!>},<i!!}o>}}},{<">},{{{<a{e<>}}}},{{{{{{<o!>},<!>!!a!>},<{ao!,i<!!!'{>}}}}}},{{{<!!!!!>!>!{e}{!>},<!!!!!>,<,}oao!><>}}},{{{},{<u!!!!'u!>!!e!!ou'u'u}>},{{{<,a"{o!!!eu">},{<a!>'!!!>,<{!!!e!!!!"e}!>},<<o{{!!!>},<u{u!>>}},{<>,<}'i,!!!>,<!>},<>},{{},{{<"!>},<}!>,<o<!>,,!>,<ueu'!>,<>}}}}},{<!>,<!'ui"<,u>,<!>,<<{"!>},<!"!>,<>}}}},{{{{{}},{{<e{{!ee!>,<a!>,<{!>!!,!!i'u!!!>,<!!!>!!!>>},{{<!!a>},<i<ee!'e{'!!'uoi'!>}>}},{{{{<a!!!!!>>}}},{{{<!>},<!!!>!>,<!!!>!!<!!!>!a!>,<<a!>,<!>!!!>!!!>{",>},{}}}}}},{{{{<!!!!e!>,<<!!!>!>},<!}o>},<!!,'",!!!>,!>,<!>},<!!o,!!!>},<!i<!>,<!>},<{>},{{<e!>},<!!"{!>},<>},<a!!>},{{<!>,<e',ae!!!>"!!<{,o!ai!!a}{!>>,{{<"!!!>,!>},<<!{!>},<u!>,<!>,<>},<!iu'!>},<!!i!!i!!!>!!!>!>!>,<i!!u,!><a>}},{{<o!,ee<>}}}},{{{{<}!>,<<a!>oaa''!>!!!!!>!!o>},{<'<,!<"o,!>},<!>},<ai!>!!<'o,!>>}}},{{<uea!>,<{'!>},<o!",e!!u}{o!>},<{}!o>},{{<!>}<i!!o!>,<!uoo>},{<,!>!!!>'"!!!>!><,ouo>}},{{<ea,"uoao!>,<"<>}}},{{{<!!ai,o''!!<e<{"<eo!!!>>,{<"!!!e}!!!>!!!u!!!>!!<!!!!!>},<{u}a>}},{<',!>,<o!>,<!>,<iu,!>,<>}}}},{{{{{<!>,<<!!!>!!{!!!!,>},<!!!ea!!!>">}}},{{{{{<!>},<!>ue'u'!!",!!!>}>}},{<!!ua!>,<!><!!,o!>,<}}{>}}},{{},{<ui!>},<!!}u!!!>,'!!uu{!!{<e<!!e!>,<!>>}},{{<i!!!>ua!!!>!!!>!!!>u!!'u!!!>},<!e>},{<!,!}!!e<!!'!>!!a!!!!!>!>},<,>}},{{{{<!!!>!!{}u!!!!ii!!!>"a'>,{<ie,!}!>i'!ee'!>,<a!e!!!>{>}},{{<"!!!>o!!!{o!>,<"e!>,<"!'{iao"i>,<!!,e>},{},{}},{{<u<'<}>},{{},<!>o'!!oao!>!!!>},<!{!>},<>}}},{{<!>},<!>i,!!o>},{{}}}},{{},{{<!!o!!iu'>},<!!!>{a<eao>}},{}}}}},{{{{<}{>},<a!!!>!>,<u'!>,<!>,<{iio,'!!ui">}},{{{{<!>,<i!!o>},{<{{",'!!,!>,<!!}u!!a}"!!!>"<!>},<>}},{{{{<"!!!!"!e'!>,<!>'<!a!e<>}}},{<!,!>},<{"i'i>}},{{{<<!>,<a!a{ao>},{<,>}},{},{{{<iui!!!>,<<},!}io!!,o{>},{{<,"!!!!,e!>,<!>},<,!!!>e!>i!>,<u!!{i!!,!!!>},<>},<!}<}!!e!>,<!'{i!!!>},<!i!!!>!'{,!!i>}},{<u!!}!a!!!>!>,<!!!>}!!au!>},<a>,{}}}}}},{{{<>},{{<!iu<i!>{u,!o!>},<"!>},<>}}},{<<!>!>,<!!!!!>!a>,<"!!!>e!>,!>},<"!u!!!>>}},{}}},{{{{{{<u!!,a"<u!!'i,{>,<!!{>},{}},{}},{{{<uio!>,<'!{io{!>>}},{<!>},<!!o!>,<!',,}'!}i<e!o<oa!>,<!!!>e>,{{<<"!>i!!!>e'!!!>,<>}}},{{<'!i>},{{},<{o!,>},{{{<!>,<ei!>!!,<!>,<!>!>,<{a>},<!<>},{{<!>},<a"!!}o,!!!>u!!!>,o>,<uu!>!>},<>},<!eai!!!>!!!>,<i!>,<!}o"!}!!!>o',!>},<!>},<>}}}},{}},{{{{{{<}!!!'a!!!!o"'}!!ee!!,!>,<!"">}},{{<'<!uu"!!!u'!!uua,!"i!!,!>,<!!!>,<{>}},{<!u!!!>!o!!u>}},{{{<u,!!!!!>}!>},<!!!>!!"}!!!>o,'!>,<!>!}o!i>},<!>!>},<eeei'!>!!u!>,<!!",,!o!>'o!!,'>},{}}},{{<!>,<{e}!!!>e>},{{<!!<e!!!>!!">,<a'"!!<!>},<a!!i!>e"}!!<<!!i!>},<!!!>},<>},{<!!!>'!>},<auu!!!!!!!>!>},<'>}}}},{{{<!>,<e""!>,<i">}},{<!!!>a!{!,<!>},<'<!>o'!>"}!eea!>,<!!!!">,{<!!!>!!<o{!>}!>},<}}!>,<,!e{!<e!>,<!>!aa>}}},{{{{{<o,!>},<i!>>},<!>,<,'>},{{<!><!o!a!!!>},<!!!!!>,"!,",}!{a!>,<!>,<!>>}},{{{},{{{<"'"'!!i<!ea!!!>,<i,!!!>e{u!}>},<!!!><u{!>!!!!!>i{"!!""u>},{}},{{<e!>},<a!!!>!>!!!>>}}},{{},<!a,!>,<,u"!ao!eo"!o<>}}}},{{{{<!>},<>},{{{{{{<e!>},<"o},!>},<!{a>}},<i!!'!o!a!!!>},<a!>,<!!!!>},<!!i},<i!!!!<'!>,<'>}},{}}},{<!i,!i!>'}!!!!!>"{}'"!!!!>,{<ouia!!!!!>,<'!!!>',{!>!!}!!u!!<'!>,<!>},<>}},{{{{}},{<!>,<a}!!!>}>}}}},{{},{{<e}a!!}aa""!!aa!!{!u!!!!!>>},{{},{{{{<!><!>!!!>u,!!i{!>},<'!>ao}{>,<!!!!a,o!!o'>},{{<'!!!>,!!eiu>},<}i!!!>,!!o}!!!!!!!>,<ao}u>}},{{{{{{<!>o<'!!e!!!{}!>},<!a>,<u!'!!u!>},<!>"}!e!!!>a}{!>,<>},<!!!>!!!>>}},{}},{{<!!!>e!>},<>}},{{{<!,!>!!o}<'}}>}},{{<!!!!!!!!'!!!!,'!!!>!>,<},a!!>},{<>}},{{<{u">}}}},{{},<!a!!!>"}!!!>},<!>},<>},{{{<<>}}}},{{{<'a!!!>eouu!>,<!!!>,<uo!!a!!i>}},{}}},{<o!!!>a!>oe<!>},<<!!>,<!!!a,aui!>""e!>'i}!>},<!a>}},{<i!>},<o!!!>,<a!>},<>,<}au!>},<!!!>u!>,<u!!!>},<e!!}a!!''!{>}}}}},{},{{{{<<!!!!!>{{!!!>!!oe!>,<"!<o!>,<a>},{{<!"e!>,<>}}}},{{<!>!>,<{!!!>u!>'!>},<>,{{<o!>},<,e>}}},{<<eaoee'!!!>,<a!!!>!!e!!!>,<!!!!!>"!>o!>},<e>,{}},{<!>,<'!!!<!>'>,{{<!!a!>},<!!!>!>u">}}}},{{<a"!>,<'>,<!!!>,<uo!>,<ou,!!!>!>},<!!!>,<'u!!!>!>,<!!!>,<u>},{{{<ua!>,<}u!>,<!!!>!!!>!!!>!!!!'>},{<u'e}!!!>!!!,!!o!u!>},<"<!!"!>,<>}},{{<!>},<<o{u'>},{}}},{<!!"!>u<ai!!!>!>,<!>}!!'o!>,<>,{}}}}}},{},{{{{{<iia!!ei"!!!>"">},{<o,!>e!>!!{!!!>"}i!>,>,{<<{!!"'!>>}}}},{{<<!!},!!>},{{{},{{{},{<!,a!!!>},<e!<!!!!!>u!>u>}},{}}}}},{{},{<e!!!>{,<a!>},<!{,e!o!!!>!!>}}}}},{{{{<'<!!!>},<!!!>!!!!{!!!>u>}},{<a>,{}}},{},{{{<o!>},<}!>,<!!!>{!!!>,<!!a>},{<u!!'i!<!>!!!!!>,<!>!!!>!>,<!!>}},{{<e!>,<u!>e>},{<!!{!!!a"u<!!o!!>,{<o'!!!>!!!>!!!>},<ui!>,<>}}}},{{{<!!!}!!!>{o'!>!>"o",o'<o!>a>}}}},{{{{<!"!!!>{i,oe'!!,au!><!!!>},<u,>},{{{<ei!!!>!'i'a<>},<!!,!}!!!><a!!}'au!>"!>,<!!!"e''>}}},{{{<{o}!>,<""!>,<<,'{u,<}<!}>},<{u!!!>!!!>!!e<>},{<>}},{{},{{},{<u{!!!!>,{<!}u!>},<'e!!!>!>,<!>!!!!,!!!!!>!!!>!>},<!>,<!!}!,>}}},{{},<e!!<"eui!!eo>}},{{{<!'{!!!>'i{a!"'!!!!!!!>>},<{u!>,<}<i"!!!>i>},{{<!!}!>,<{!!a!>i!!,!>,<<!!aa!!>,<>},{<!!{e!!<}>}},{{<!!!>'!,>}}}},{{<o!!!>!>,<!!!>a!!!>!>,<'!>!>},<}!e'o!>,<a>,<!!!>,<!,"!,!>i}!{!>,<!>},<<<a<>},{{<!>,<<!>'<!!!><!!"o>,{<<,a}{"!!!>'!>},<<<!!!>o!!a!>,<i>}}},{{{},<"iae"}!>u{!!!>!!"{uoaa!>},<!!!>!>,<>},{{<{e!<}!<!!!>!!!>,!!'!!o{,!!!>,<{!a!!">},{<!>,<}!>},<!u!>},<o!!<{u>}},{<o,!>,<i!}!!!!!>,<!!aa!>},<u<!!!>},<>,<{o!a!!!!e!>!,!>!i!>!i>}}},{{{},<!!aou},!!!!!!i!>u!>,<}u>},{<!!,!<!"!!ea!!!!!>o}!i}i{!!!>},<!>,<'!<'>,{<!u{u!>!>,<,!>},<!>{<">,{{}}}},{{},{{<i!!!>>}}}}}},{{{{{<!>},<u,!!!ui!!!><!uu!>},<!!!>e!!!{o!!a>}},{{}},{<o'<!!<>}},{{},{{{{<!"!ii",!!!>!!ea!!u',!!!>>},{}},<!!!>},<ua!!u!!!uio!!!>a>}}}},{{{{{{<!!!!'!!!!io,e,!!i!!!>'u>},<!!e!>},i!>},<e!>!!!>,<',}ee!>>},{<a!"}!!oaoe!!!>iu"{>,{}},{{{{{}}},{{<<!!{<!>euao>}}},{{{<"}>,{<!>e"!!!>{e>}},{<"}"!>},<'!>,<'!!!>i!o!>i}!!!>!a>}},{{<!>}!>},<!!!>{!>>}},{{}}},{{<!>,<"!,!>},<!>ua<!!!>},<au!'"!!,u{!>},<!!!>>},{<!>e>}}}}},{{{{}},{<!!!>!"!>},<!,!>,<!>!!!>!!!>u!!!>,"!,u!!!>!e}!!!>e>}},{{{{<!{!!}!>},<,'i<!>,<!{ee!!">}},<!a"!!{!!!>,<}i'{!>},<',>},{{<}!>{!>},<a!,<!>},<u>}}},{<o}u!!<'<!>,<i}!!i!<!i>}}},{{{{<>}},{}}},{{{<e!>!!<ee!!!>}"a!!i!}!!"!!uai>}},{{},{{{}},{<'o"<e!!!!{}'!!!>,<"o<"!>>}},{}},{{<!!!>>,{{}}},{{<,!!!>uuu!>},<}{,u<}'{>}},{}},{{<i!!!!}u<!!!>'!>'!!!>,!!!>!!!>,<}o!>,<,i>,{<}!!!>'!>,<!!!>!!{!!u}'u}"uo>,{<!>u}"!>,<euo,!>,<ea,>,{{},<!!uia!!!!,<a!>,<u<!!!!!>e!!>}}}},{{<,ie>}},{<e!!!>"!>,<!>ue!!!>,!!!!!>},<i!}!>!!!!!>i!>>,{{{<<a"u,'!>ua!!!!{i!!{">,{}}}}}}},{{{{<!>!!!!>},{{<!!a<{<!>},<>},<,i>},{<!!!>'!u'"!!{!!e}>,{{}}}},{{<!>,<!!e!!!}!>,<u}i'o,!!u>,<!!i!>!>,<!!!!!!!!!>>},{},{{<!!!!,!>,<ue!!!,u!e!!{!!!>!>,<}'e>}}},{{{<<>}},{{<o{oi!>},<"!!!!"!e!!!>!>,<{,}u'!!!>>},{<ia!!!>!>},<}a'!>}>}},{{},{{<'!>},<!!i!!!>!!!>},<!!!>u},'!>,<o<i{ou!!>,{}},{{<!>,<!!a{{>,{<{!,o{<!>},<!!ea!>,<,!>},<!>!>,<'"!>,<oi!}>}}}}}}},{},{{{<!>,<!>,<<!!!<!!!!!>,<u,ae>},{<}i!!au,'!>},<!>},<!!!!!!!>!>>,<"!>},<!<"!>,<!>,uio!>,<!>},<!!!>!!!><>},{}},{{{{{{<!>},<}">},{<a!>,<!!!>>}},<{"!!!>!!!>!!!>},<}!!!>},<!!!>"'!!!!!>!>,<}>},{<!u!!!!!>!,<!!!>!>!!,<e{>}},{<!{!!}{o,u}a{!aa!>,!!!!}!!!>},<a>,<!>u!!!><a!>!!'},{oua!>},{!!!!!>>}},{{{<uua}<!!!>{,!!oe<>},<!>ue,!!!>!!!>},<!!u!!{e!!!>>},{{<""a!!!!',,',!>},<u{a>},{<ei!!}!!!!!!!>{!!!>a!auo!>,<>}},{<!!e!>!!!>!>},<!>},<!>,<uoo!!!>,<iiui!!{!>,<!!!!!>,<!>},<>,{}}},{<"!!!>!!!>!>,<!>},<!!!>!>}">,<'!{!!!>!!!>"!!!!!!!!o>}},{{{}}}},{{},{{{<io}"{{e"'!{<!!!>ui!>e>}}}}},{{{{{<{}<u!!!!!!!>o!!!>'!!}!!!uo!'!!!!!>>},<>},{<!!!>>,{}},{{{{{<>}},{<!"!!!>"!!oo!>}a,!!,uu!""!!!>!>},<>}},{{<!!!>o>}},{{{{<>,<!>},<}!u!!!>,<{o}}"!>},<e!!!!"i!!!>,<}a>}},{{<i}!!!>{!!,iee!!!!!!{!>,<!>>}},{{},{<}!!!>!!!!!>{!>,<>,<!>},<e<!!,!!!!e!>,<!!!>>}}},{{},<!!!>},<<{ue}!oa""!>oi<u!!i!>,<!i>},{{},{<!!u!'}i!!{!!!>,<!>,<!!!>},<!o'!!!>>,{<}!!!>!!!>,<a"u!,>,{{},{<!o{!!!><{o>}}}},{{<>,{<!io!!'}e{!!!!!>!!!>!!!>!'}!!!>!aui>}}}}}}}},{{{{{},{<!"i!><ua!>!>},<!!e>}}},{{{<!>,<!>{{!>,<{}"i"}!>},<!>},<<<{au>}},{<!<}!!a>},{{{{<!>,<!!!>,ai',!!!>i"i!>}">}}}}}},{{<!!!>}!!!<u'o','!>!!!>!>},<!!!!!>},<!>},<!!{>},{{{<'!i<}!!e>},{<!!!!!>oo!!<!u'!o"ie!!!>!!!>ee{>}},{<>}}},{{{<o!!""!!!!!!}{<e>},{<!!{!!!>>}},{<!!!>!>i!u!><!!!>e!!a!!!>i!!!>eu'>,{<i!!!>,<!!}!!!iu<a>}},{{},{<''u!>u!>},<,!!i"!!!>{'}'!>},<!!!>i>}}},{{<!>,<!!{!!!>!>,<!<}!>,<>,<!>,<!!!>!!{a!!ao!i!<<u!}!!!!!>,<>},{},{<!!!!!!!!ui!i!!o"aai}!'ue!!i!>,<"i!!!!!!!<>}}}},{{<!>},<}'!i'a}>,<!!!!!>,<{!ueo{},!!!>,<!!!>'!>},<o!>,<o,}>},{<'!!<>,{<!>},<<!!!>!!!>ee!!<{!>,<o{{{>}},{{{<!>!!,>}},{<!!e}!>},<{u>},{{{{<!>},<,!>i{"!o!>!>},<!>},<!><>},{{<!>},<eu!!"!>},<<!>!!i">}}}}}}},{{{<!o!'aa}{!!{<a">}}}}},{{{{<',eua!>{>,<"!!!!!!<"!>,<!!'}u!>,<>}},{<!>,<''!!<{!>,<}}o!>},<ae>}},{{<oi!!!>!!!>!>},<!!!!!>o>,{}},{{{{}}},{{{<!!o>,<!o>},{}},{{{<}u!>,<>},{<!!}a<!!!>uo{,!>,<!a!!{{}!!!>,<!!!!!>!>,<!>>}},{<a{!a{"!!!!,o!>},<iu{{!>a!{'o>,{{<!!!!'!!!>,<!a!!{,o!!!!!><'u>},{<!i}!!o"!!}<!!ee!!!>!!o!>},<!!"!>,<,>}}},{{<e!!}i}!i>},<o!>},<a'u!!!>"!!e"!!!>!>,<!>,<!iu{!'!>>}},{{<i!>,<!>,<e">},<e<uo>}},{{{<!!!>e'!>},<''<e"ue>},{{<}!!!o>}}},{{}}}}},{{<}!!!>},<u!!'e!!,!!!>,<!!!>!u!>,<!!"!>},<}a!>,<!>>},{{<!!!>!!o!>},<!!o!>,<}!!!>i>},{{<!>,<!>,<>}}}},{{{{<o{"}>},{<u!>,<,!!u>,<!>u!!!o<!io>}},{{}},{{{<"{"}'!>,<!}!!<!!!>,!!"a!!!>}i>}},{{<!>{!!!>!!!>},<!>,<!>!!!>',e>},<a"}a{e!>}{<ae<!>},<"e>}}},{{<!>!>},<!<a!!o>},{<!!e{!!"a<{i'!o<<!>},<!>,<!!!>o!!i!!!e>}},{{},{{{},{<"!>,<!!!>a>}},{}}}}},{{{{{<'!!!>ie!!!,a!>}'!>,<!!<e!a!>!>>,{<,,}!>},<ua!!'!!!>i>}},{{},{<!>,<<!!!>},<,!!e>}},{}},{{<,ou!o!!"e!!!>i{!>,<<>,{}},{<!!!!!>"o!>},<{!!!>"i"!!!>>,{<{!>},<"!>},<!>a!!!>>}}}},{{{<!!}'ao<{u!i<!>,,!!<"!!!!ei>},{<!!!>a}i!>,<o!>},<!!!!!>!>},<>,<"!>!!!"u"!>!>!>},<!!!!!>i!!<!>,<u!!{>},{}},{{<!>!>,<!!e>}},{{{{{<!>},<!>,<!<a!!!!!>o}!!{,!>,<!>,<u!>,<u>}},<,!>},<!!}e!}}!!!!!!!>!>!a'!!"e!!}>}},{{}}}},{{{<"i!>},<ie!i>},<,o!>},<!!eie!!!>!>,<<o<",!>!>">},{<{!>,<!!!>!!!>"',!>},<>,<!>!!!>o!!!oe!!,!>"!>},<,>}}}}}})
  end
end