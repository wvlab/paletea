defmodule Paletea.AppModules.Ratbag do
  use Paletea.AppModule
  @modulename "ratbag"

  def modulename() do
    @modulename
  end

  def default_conf() do
    %{
      "colors" => %{},
      @modulename => %{
        "colors" => %{
          "led0" => "color7"
        },
        "settings" => %{
          "mode" => "on",
          "duration" => nil,
          "brightness" => nil
        }
      }
    }
  end

  @impl AppModule
  def run(_theme, conf) do
    configure_devices(conf)
  end

  # TODO: extract it some util?
  defp mergefn(_k, v1, v2) when is_map(v1) and is_map(v2) do
    Map.merge(v1, v2, &mergefn/3)
  end

  defp mergefn(_k, _v1, v2) do
    v2
  end

  defp ratbagctl_set(_device, _n, _category, nil) do
  end

  defp ratbagctl_set(device, n, category, value) when is_integer(value) do
    ratbagctl_set(device, n, category, Integer.to_string(value))
  end

  defp ratbagctl_set(device, n, category, value) do
    {_, 0} =
      System.cmd("ratbagctl", [
        device,
        "led",
        n,
        "set",
        category,
        value
      ])
  end

  defp set_settings(leds, mode, duration, brightness) do
    {devices_list, 0} = System.cmd("ratbagctl", ["list"])

    devices_list
    |> String.split("\n")
    |> Enum.map(&hd(String.split(&1, ":")))
    |> Enum.reverse()
    |> tl()
    |> set_settings(leds, mode, duration, brightness)
  end

  defp set_settings([], _leds, _mode, _duration, _brightness) do
  end

  defp set_settings([current | devices], leds, mode, duration, brightness) do
    leds
    |> Enum.each(fn {n, color} ->
      ratbagctl_set(current, n, "color", String.slice(color, 1..7))
      ratbagctl_set(current, n, "mode", mode)
      ratbagctl_set(current, n, "duration", duration)
      ratbagctl_set(current, n, "brightness", brightness)
    end)

    set_settings(devices, leds, mode, duration, brightness)
  end

  defp configure_devices(conf) do
    %{
      "colors" => colors,
      @modulename => %{
        "colors" => adjusted_colors,
        "settings" => %{
          "mode" => mode,
          "duration" => duration,
          "brightness" => brightness
        }
      }
    } = Map.merge(default_conf(), conf, &mergefn/3)

    Map.merge(colors, adjusted_colors)
    |> PalePuer.evaluate!()
    |> Map.filter(fn {x, _} -> String.starts_with?(x, "led") end)
    |> Enum.map(fn {ledn, v} -> {String.slice(ledn, 3..-1), v} end)
    |> set_settings(mode, duration, brightness)
  end
end
