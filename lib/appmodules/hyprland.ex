defmodule Paletea.AppModules.Hyprland do
  use Paletea.AppModule
  @modulename "hyprland"

  def modulename() do
    @modulename
  end

  def default_conf() do
    %{
      "colors" => %{},
      @modulename => %{
        "colors" => %{},
        "settings" => %{
          "general" => %{
            "border_size" => nil,
            "gaps_in" => nil,
            "gaps_out" => nil,
            "active_border_opacity" => "ff",
            "inactive_border_opacity" => "ff",
          },
          "decoration" => %{
            "rounding" => nil,
            "multisample_edges" => nil,
            "blur" => nil,
            "drop_shadow" => nil,
            "shadow_range" => nil,
            "dim_inactive" => nil,
            "dim_strength" => nil
          },
          "dwindle" => %{
            "smart_gaps" => nil,
          },
          "location" => nil,
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

  defp write_line(_fmt, nil), do: ""

  defp write_line(variable, value) do
    "#{variable} = #{value}"
  end

  defp write_config(theme, conf) do
    # TODO: make it more consice
    %{
      "colors" => colors,
      @modulename => %{
        "colors" => overwritten_colors,
        "settings" => %{
          "general" => %{
            "border_size" => border_size,
            "gaps_in" => gaps_in,
            "gaps_out" => gaps_out,
            "active_border_opacity" => active_border_opacity,
            "inactive_border_opacity" => inactive_border_opacity,
          },
          "decoration" => %{
            "rounding" => rounding,
            "multisample_edges" => multisample_edges,
            "blur" => blur,
            "drop_shadow" => drop_shadow,
            "shadow_range" => shadow_range,
            "dim_inactive" => dim_inactive,
            "dim_strength" => dim_strength
          },
          "dwindle" => %{
            "smart_gaps" => smart_gaps,
          },
          "location" => location,
        }
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    %{
      "color0" => color0,
      "color7" => color7
    } = Map.merge(colors, overwritten_colors)

    # TODO: make contrast real colors, eg 8..15
    conf = """
    general {
        #{write_line("border_size", border_size)}
        #{write_line("gaps_in", gaps_in)}
        #{write_line("gaps_out", gaps_out)}
        col.active_border = rgba(#{String.slice(color7, 1..7)}#{active_border_opacity})
        col.inactive_border = rgba(#{String.slice(color0, 1..7)}#{inactive_border_opacity})
    }

    decoration {
      #{write_line("rounding", rounding)}
      #{write_line("multisample_edges", multisample_edges)}
      #{write_line("blur", blur)}
      #{write_line("drop_shadow", drop_shadow)}
      #{write_line("shadow_range", shadow_range)}
      #{write_line("dim_inactive", dim_inactive)}
      #{write_line("dim_strength", dim_strength)}
    }

    dwindle {
      #{write_line("no_gaps_when_only", smart_gaps)}
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
