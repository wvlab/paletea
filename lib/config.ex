defmodule Paletea.ThemeConfig do
  alias Paletea.AppConfig, as: AppConfig

  def write_config(colors, wallpapers \\ [], theme_dir) do
    [
      color0,
      color1,
      color2,
      color3,
      color4,
      color5,
      color6,
      color7
    ] = colors

    conf =
      [
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
        color0 = "#{color0}"
        color1 = "#{color1}"
        color2 = "#{color2}"
        color3 = "#{color3}"
        color4 = "#{color4}"
        color5 = "#{color5}"
        color6 = "#{color6}"
        color7 = "#{color7}"
        """
      ] ++ get_default_modules_configs()

    :ok = PaleFile.write(Path.join(theme_dir, "theme.toml"), conf)
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

    []
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
