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
  def day1a(inp \\ Inputs.day1) do
    [first | _] = input = Integer.digits(inp)
    {last, sum} = List.foldl(
      input,
      {:undef, 0},
      fn
        (elem, {elem, sum}) -> {elem, sum + elem}
        (elem, {_, sum}) -> {elem, sum}
      end
    )
    cond do
      first == last -> sum + last
      true -> sum
    end
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
  iex> Aoc_2017.day5b()
  27502966

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
  def sort_string(string) do
    string
    |> String.downcase()
    |> String.graphemes()
    |> Enum.sort()
  end
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
end