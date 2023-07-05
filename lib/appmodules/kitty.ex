defmodule Paletea.AppModules.Kitty do
  use Paletea.AppModule
  @modulename "kitty"

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

  @impl AppModule
  def run(theme, conf) do
    write_config(theme, conf)
  end

  # TODO: extract it some util?
  defp mergefn(_k, v1, v2) when is_map(v1) and is_map(v2) do
    Map.merge(v1, v2, &mergefn/3)
  end

  defp mergefn(_k, _v1, v2) do
    v2
  end

  defp write_config(theme, conf) do
    %{
      "colors" => colors,
      @modulename => %{
        "colors" => adjusted_colors,
        "settings" => %{
          "opacity" => opacity,
          "location" => location
        }
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    %{
      "foreground" => foreground,
      "background" => background,
      "cursor" => cursor,
      "color0" => color0,
      "color1" => color1,
      "color2" => color2,
      "color3" => color3,
      "color4" => color4,
      "color5" => color5,
      "color6" => color6,
      "color7" => color7,
      "color8" => color8,
      "color9" => color9,
      "color10" => color10,
      "color11" => color11,
      "color12" => color12,
      "color13" => color13,
      "color14" => color14,
      "color15" => color15
    } = PalePuer.evaluate!(Map.merge(colors, adjusted_colors))

    conf = """
    background_opacity #{opacity}

    foreground   #{foreground}
    background   #{background}
    cursor       #{cursor}
    color0       #{color0}
    color8       #{color8}
    color1       #{color1}
    color9       #{color9}
    color2       #{color2}
    color10      #{color10}
    color3       #{color3}
    color11      #{color11}
    color4       #{color4}
    color12      #{color12}
    color5       #{color5}
    color13      #{color13}
    color6       #{color6}
    color14      #{color14}
    color7       #{color7}
    color15      #{color15}
    """

    path = location || AppModule.default_module_path(theme, @modulename)

    file_path = Path.join(path, "#{theme}.conf")
    PaleFile.write!(file_path, conf)

    PaleFile.write!(
      Path.join(path, "paletea.conf"),
      "include #{file_path}"
    )
  end
end
