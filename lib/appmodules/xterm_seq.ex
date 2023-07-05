defmodule Paletea.AppModules.XtermSeq do
  use Paletea.AppModule

  @modulename "xterm_seq"

  def modulename() do
    @modulename
  end

  def default_conf() do
    %{
      "colors" => %{
        "foreground" => "color7",
        "background" => "color0",
        "cursor" => "foreground",
        "color8" => "darken(color0, 0.1)",
        "color9" => "darken(color1, 0.1)",
        "color10" => "darken(color2, 0.1)",
        "color11" => "darken(color3, 0.1)",
        "color12" => "darken(color4, 0.1)",
        "color13" => "darken(color5, 0.1)",
        "color14" => "darken(color6, 0.1)",
        "color15" => "darken(color7, 0.1)"
      },
      @modulename => %{
        "colors" => %{},
        "settings" => %{
          "opacity" => 1,
          "location" => nil
        }
      }
    }
  end

  # TODO: extract it some util?
  defp mergefn(_k, v1, v2) when is_map(v1) and is_map(v2) do
    Map.merge(v1, v2, &mergefn/3)
  end

  defp mergefn(_k, _v1, v2) do
    v2
  end

  @impl AppModule
  def run(_theme, conf) do
    %{
      "colors" => colors,
      @modulename => %{
        "colors" => adjusted_colors
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    # TODO: seems as bad approach
    color_sequence =
      Map.merge(colors, adjusted_colors)
      |> PalePuer.evaluate!()
      |> Map.filter(fn {c, _v} -> String.starts_with?(c, "color") end)
      |> Enum.with_index()
      |> Enum.map(fn {color, index} -> put_elem(color, 0, index) end)
      |> Enum.map_join(fn {index, color} -> set_color(index, color) end)

    # TODO: add special sequences
    sequences = [color_sequence]

    Path.wildcard("/dev/pts/*")
    |> Enum.filter(&Regex.match?(~r/^\/dev\/pts\/\d+$/, &1))
    |> Enum.each(&File.write(&1, sequences, [:binary, :write]))
  end

  defp set_color(index, color) do
    # TODO: add hack for vte based terminals
    "\e]4;#{index};#{color}\e\\"
  end
end
