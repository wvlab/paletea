defmodule Paletea.AppModules.Kitty do
  @behaviour Paletea.AppModule
  @modulename "kitty"

  def modulename() do
    @modulename
  end

  @impl Paletea.AppModule
  def run(theme, parent, %{"colors" => colors}) do
    try do
      write_config(theme, colors)
    catch
      error_trace -> send(parent, {@modulename, self(), :error, error_trace})
    else
      _ -> send(parent, {@modulename, self(), :ok})
    end
  end

  defp write_config(theme, colors) do
    %{
      "color0" => color0,
      "color1" => color1,
      "color2" => color2,
      "color3" => color3,
      "color4" => color4,
      "color5" => color5,
      "color6" => color6,
      "color7" => color7
    } = colors

    # TODO: foreground, background, cursor colors
    # TODO: make contrast colors, eg 8..15
    conf = """
    background         #111111
    background_opacity 0.80

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

    # TODO: Make separate func for getting path for module file
    path = Path.join([XDG.get_data_path(), theme, "modules", "kitty"])
    unless File.exists?(path), do: File.mkdir_p!(path)
    :ok = File.write(Path.join(path, "#{theme}.conf"), conf)
  end
end
