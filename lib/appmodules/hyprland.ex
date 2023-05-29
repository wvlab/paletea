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
        "colors" => %{
          "active_border" => "alpha(color7, 255)",
          "inactive_border" => "alpha(color0, 255)"
        },
        "settings" => %{
          "general" => %{
            "border_size" => nil,
            "gaps_in" => nil,
            "gaps_out" => nil
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
            "no_gaps_when_only" => nil
          },
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

  defp make_section({section, variables}) when is_map(variables) do
    Enum.join(
      [
        "#{section} {",
        variables
        |> Enum.filter(fn {_, val} -> not is_nil(val) end)
        |> Enum.map(fn {variable, val} -> "    #{variable} = #{val}\n" end),
        "}"
      ],
      "\n"
    )
  end

  defp write_config(theme, conf) do
    %{
      "colors" => colors,
      @modulename => %{
        "colors" => adjusted_colors,
        "settings" => %{
          "general" => general,
          "decoration" => decoration,
          "dwindle" => dwindle,
          "location" => location
        }
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    %{
      "active_border" => active_border_color,
      "inactive_border" => inactive_border_color
    } = PalePuer.evaluate!(Map.merge(colors, adjusted_colors))

    conf =
      %{
        "general" =>
          Map.merge(
            general,
            %{
              "col.active_border" => "rgba(#{String.slice(active_border_color, 1..9)})",
              "col.inactive_border" => "rgba(#{String.slice(inactive_border_color, 1..9)})"
            }
          ),
        "decoration" => decoration,
        "dwindle" => dwindle
      }
      |> Enum.map_join("\n\n", &make_section/1)

    path = location || AppModule.default_module_path(theme, @modulename)

    file_path = Path.join(path, "#{theme}.conf")
    :ok = PaleFile.write(file_path, conf)

    :ok =
      PaleFile.write(
        Path.join(path, "paletea.conf"),
        "source = #{file_path}"
      )
  end
end
