defmodule Paletea.ThemeConfig do
  alias Paletea.AppConfig, as: AppConfig

  def write_config(colors, wallpapers \\ [], theme_dir) do
    # TODO: add only that are in whitelist
    conf =
      """
      wallpapers = [
      #{print_list_content(wallpapers)}
      ]
      whitelist = [
      #{print_list_content(AppConfig.get("whitelist"))}
      ]
      blacklist = [
      #{print_list_content(AppConfig.get("blacklist"))}
      ]

      [colors]
      foreground = "#{Enum.at(colors, 0)}"
      background = "#{Enum.at(colors, 7)}"
      color0 = "#{Enum.at(colors, 0)}"
      color1 = "#{Enum.at(colors, 1)}"
      color2 = "#{Enum.at(colors, 2)}"
      color3 = "#{Enum.at(colors, 3)}"
      color4 = "#{Enum.at(colors, 4)}"
      color5 = "#{Enum.at(colors, 5)}"
      color6 = "#{Enum.at(colors, 6)}"
      color7 = "#{Enum.at(colors, 7)}"
      """ <> get_default_modules_configs()

    :ok = File.write(Path.join(theme_dir, "theme.toml"), conf)
  end

  def parse(theme_dir) do
    Toml.decode_file!(Path.join(theme_dir, "theme.toml"))
  end

  defp print_list_content(l) do
    l |> Enum.map_join("\n", &"   \"#{&1}\",")
  end

  defp get_default_modules_configs() do
    # TODO: implement
    _whitelist = AppConfig.get("whitelist")
    _blacklist = AppConfig.get("blacklist")

    ""
  end
end

defmodule Paletea.AppConfig do
  use Agent

  def conf_path() do
    Path.join(XDG.get_config_path(), "config.toml")
  end

  def create_default_file() do
    # TODO later
  end

  def start_link(_opts \\ []) do
    unless File.exists?(conf_path()), do: create_default_file()

    Agent.start_link(
      fn ->
        Toml.decode_file!(conf_path())
      end,
      name: __MODULE__
    )
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
