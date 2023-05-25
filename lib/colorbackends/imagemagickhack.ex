defmodule Paletea.ColorBackends.ImageMagickMagic do
  # TODO: add foreground, background colors
  @behaviour Paletea.ColorBackend

  @impl Paletea.ColorBackend
  def get_colors(wallpaper) do
    parse_colors(wallpaper)
  end

  defp parse_colors(wallpaper) do
    args = ~w(#{wallpaper} +dither -colors 8 -unique-colors txt:)
    {text, _} = System.cmd("convert", args)

    text
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.reverse()
    |> Enum.map(&String.splitter(&1, " "))
    |> Enum.map(&Enum.at(&1, 3))
    |> Enum.map(&String.slice(&1, 0..6))
    # |> Enum.map(fn str ->
    #  str
    #  |> String.replace("(", "")
    #  |> String.replace(")", "")
    #  |> String.split(",", trim: true)
    #  |> Enum.take(3)
    #  |> Enum.map(&String.to_integer/1)
    #  |> List.to_tuple()
    # end)
    |> fill_list()
  end

  def fill_list(l) do
    if length(l) < 8 do
      l ++ for _ <- 1..(8 - length(l)), do: "#000000"
    else
      l
    end
  end
end
