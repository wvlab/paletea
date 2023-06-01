# THIS ALL SEEMS VERY QUESTIONABLE, DO SOMETHING WITH IT, PLEASE

defmodule PalePuer do
  @function_call_regex ~r/^(\w+)\((.*)\)$/

  def evaluate!(str, colors) when is_map(colors) do
    case Regex.scan(@function_call_regex, str) do
      [[_, function, arguments]] ->
        call_function(
          function,
          arguments
          |> String.splitter(",")
          |> Enum.map(&String.trim/1)
          |> Enum.map(&evaluate!(&1, colors))
        )

      [] ->
        case Map.fetch(colors, str) do
          :error ->
            str

          {:ok, obj} ->
            evaluate!(obj, colors)
        end

      _ ->
        raise RuntimeError
    end
  end

  def call_function(function, args) do
    apply(PalePuer.Callables, String.to_atom(function), args)
  end

  def evaluate!(colors) when is_map(colors) do
    colors
    |> Enum.map(fn {c, v} -> {c, evaluate!(v, colors)} end)
    |> Map.new()
  end
end

defmodule PalePuer.Util do
  def hex_to_rgb(color) do
    color
    |> String.graphemes()
    |> Enum.drop(1)
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.to_integer(&1, 16))
  end

  def rgb_to_hex(rgb) do
    "##{rgb |> Enum.map_join(fn c -> Integer.to_string(c, 16) |> String.pad_leading(2, "0") end)}"
  end

  def rgb_to_hsl([r, g, b]) do
    red = r / 255
    green = g / 255
    blue = b / 255
    mi = Enum.min([red, green, blue])
    ma = Enum.max([red, green, blue])
    chroma = ma - mi
    luminosity = (ma + mi) / 2

    saturation =
      if luminosity == 1 or luminosity == 0 do
        0
      else
        chroma / (1 - abs(2 * luminosity - 1))
      end

    hue =
      cond do
        chroma == 0 ->
          0

        ma == red ->
          seg = (green - blue) / chroma
          if seg < 0, do: seg + 6, else: seg

        ma == green ->
          (blue - red) / chroma + 2

        ma == blue ->
          (red - green) / chroma + 4
      end

    [hue * 60, saturation, luminosity]
  end

  def hex_to_hsl(color) do
    color |> hex_to_rgb() |> rgb_to_hsl()
  end

  defp rgb_from_hue(h, chroma, x) do
    cond do
      0 <= h and h <= 60 ->
        {chroma, x, 0}

      60 < h and h <= 120 ->
        {x, chroma, 0}

      120 < h and h <= 180 ->
        {0, chroma, x}

      180 < h and h <= 240 ->
        {0, x, chroma}

      240 < h and h <= 300 ->
        {x, 0, chroma}

      300 < h and h <= 360 ->
        {chroma, 0, x}
    end
  end

  def hsl_to_rgb([h, s, l]) do
    mymod = fn num, d -> num - d * Float.floor(num / d) end
    chroma = (1 - abs(2 * l - 1)) * s
    x = chroma * (1 - abs(mymod.(h / 60, 2) - 1))
    m = l - chroma / 2

    {r, g, b} = rgb_from_hue(h, chroma, x)

    [r, g, b] |> Enum.map(&trunc(Float.round((&1 + m) * 255)))
  end

  def hsl_to_hex(hsl) do
    hsl |> hsl_to_rgb() |> rgb_to_hex()
  end

  def check_overflow(value) when is_integer(value) do
    check_overflow(value, 0, 255)
  end

  def check_overflow(value) when is_float(value) do
    check_overflow(value, 0, 1)
  end

  def check_overflow(value, min..max) do
    check_overflow(value, min, max)
  end

  def check_overflow(value, min, max) do
    cond do
      value < min ->
        min

      value > max ->
        max

      true ->
        value
    end
  end
end

defmodule PalePuer.Callables do
  def invert(color) do
    color
    |> PalePuer.Util.hex_to_rgb()
    |> Enum.map(fn c -> 255 - c end)
    |> PalePuer.Util.rgb_to_hex()
  end

  def red(color, delta) do
    d = String.to_integer(delta)
    [r, g, b] = PalePuer.Util.hex_to_rgb(color)

    [PalePuer.Util.check_overflow(r + d), g, b]
    |> PalePuer.Util.rgb_to_hex()
  end

  def green(color, delta) do
    d = String.to_integer(delta)
    [r, g, b] = PalePuer.Util.hex_to_rgb(color)

    [r, PalePuer.Util.check_overflow(g + d), b]
    |> PalePuer.Util.rgb_to_hex()
  end

  def blue(color, delta) do
    d = String.to_integer(delta)
    [r, g, b] = PalePuer.Util.hex_to_rgb(color)

    [r, g, PalePuer.Util.check_overflow(b + d)]
    |> PalePuer.Util.rgb_to_hex()
  end

  def alpha(color, value) do
    color <>
      (value
       |> String.to_integer()
       |> PalePuer.Util.check_overflow()
       |> Integer.to_string(16)
       |> String.pad_leading(2, "0"))
  end

  def hue(color, delta) do
    d = String.to_integer(delta)
    [h, s, l] = PalePuer.Util.hex_to_hsl(color)

    [PalePuer.Util.check_overflow(h + d, 0, 360), s, l]
    |> PalePuer.Util.hsl_to_hex()
  end

  def saturate(color, delta) do
    d = String.to_float(delta)
    [h, s, l] = PalePuer.Util.hex_to_hsl(color)

    [h, PalePuer.Util.check_overflow(s + d), l]
    |> PalePuer.Util.hsl_to_hex()
  end

  def desaturate(color, delta) do
    saturate(color, -(delta |> String.to_float()) |> Float.to_string())
  end

  def lighten(color, delta) do
    d = String.to_float(delta)
    [h, s, l] = PalePuer.Util.hex_to_hsl(color)

    [h, s, PalePuer.Util.check_overflow(l + d)]
    |> PalePuer.Util.hsl_to_hex()
  end

  def darken(color, delta) do
    lighten(color, -(delta |> String.to_float()) |> Float.to_string())
  end
end
