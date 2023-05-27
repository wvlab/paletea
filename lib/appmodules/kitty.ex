defmodule Paletea.AppModules.Kitty do
  use Paletea.AppModule
  @modulename "kitty"

  def modulename() do
    @modulename
  end

  def default_conf() do
    %{
      "colors" => %{},
      @modulename => %{
        "colors" => %{},
        "settings" => %{
          "opacity" => 1,
          "location" => nil
        }
      }
    }
  end

  @impl Paletea.AppModule
  def run(theme, parent, conf) do
    try do
      write_config(theme, conf)
    catch
      error_trace -> send(parent, {@modulename, self(), :error, error_trace})
    else
      _ -> send(parent, {@modulename, self(), :ok})
    end
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
        "colors" => overwritten_colors,
        "settings" => %{
          "opacity" => opacity,
          "location" => location
        }
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    %{
      "foreground" => foreground,
      "background" => background,
      "color0" => color0,
      "color1" => color1,
      "color2" => color2,
      "color3" => color3,
      "color4" => color4,
      "color5" => color5,
      "color6" => color6,
      "color7" => color7
    } = Map.merge(colors, overwritten_colors)

    # TODO: make contrast real colors, eg 8..15
    conf = """
    background_opacity #{opacity}

    foreground   #{foreground}
    background   #{background}
    cursor       #{foreground}
    color0       #{color0}
    color8       #{color0}
    color1       #{color1}
    color9       #{color1}
    color2       #{color2}
    color10      #{color2}
    color3       #{color3}
    color11      #{color3}
    color4       #{color4}
    color12      #{color4}
    color5       #{color5}
    color13      #{color5}
    color6       #{color6}
    color14      #{color6}
    color7       #{color7}
    color15      #{color7}
    """

    path =
      (location || AppModule.default_module_path(theme, @modulename))
      |> Path.expand()

    unless File.exists?(path), do: File.mkdir_p!(path)
    file_path = Path.join(path, "#{theme}.conf")
    :ok = File.write(file_path, conf)

    :ok =
      File.write(
        Path.join(path, "paletea.conf"),
        "include #{file_path}"
      )
  end
end
