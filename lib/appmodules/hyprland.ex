defmodule Paletea.AppModules.Hyprland do
  use Paletea.AppModule, [:conf]
  @modulename "hyprland"

  def modulename() do
    @modulename
  end

  defmacro confgen(
             colors,
             mod_colors,
             border_size,
             gaps_in,
             gaps_out,
             active_border_opacity,
             inactive_border_opacity,
             smart_gaps,
             location
           ) do
    quote do
      %{
        "colors" => unquote(v(colors)),
        @modulename => %{
          "colors" => unquote(v(mod_colors)),
          "settings" => %{
            "border_size" => unquote(v(border_size)),
            "gaps_in" => unquote(v(gaps_in)),
            "gaps_out" => unquote(v(gaps_out)),
            "active_border_opacity" => unquote(v(active_border_opacity)),
            "inactive_border_opacity" => unquote(v(inactive_border_opacity)),
            "dwindle" => %{
              "smart_gaps" => unquote(v(smart_gaps)),
            },
            "location" => unquote(v(location)),
          }
        }
      }
    end
  end

  def defaultconf() do
    confgen(%{}, %{}, 2, 0, 0, "ff", "00", false, nil)
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
    confgen(
             colors,
             overwritten_colors,
             border_size,
             gaps_in,
             gaps_out,
             active_border_opacity,
             inactive_border_opacity,
             smart_gaps,
             location
    ) = Map.merge(defaultconf(), conf, &mergefn/3)

    %{
      "color0" => color0,
      "color7" => color7
    } = Map.merge(colors, overwritten_colors)

    # TODO: make contrast real colors, eg 8..15
    conf = """
    general {
        border_size = #{border_size}
        gaps_in = #{gaps_in}
        gaps_out = #{gaps_out}
        col.active_border = rgba(#{String.slice(color7, 1..7)}#{active_border_opacity})
        col.inactive_border = rgba(#{String.slice(color0, 1..7)}#{inactive_border_opacity})
    }

    dwindle {
      no_gaps_when_only = #{smart_gaps}
    }
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
        "source = #{file_path}"
      )
  end
end
