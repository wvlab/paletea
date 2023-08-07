defmodule Paletea.Subcommands.Change do
  @behaviour Paletea.Subcommand

  alias Paletea.AppModule, as: AppModule

  @impl Paletea.Subcommand
  def args_info() do
    [
      change: [
        name: "change",
        about: "Change current theme",
        args: [
          theme: [
            value_name: "theme",
            help: "Theme name",
            required: true,
            parser: :string
          ]
        ]
      ]
    ]
  end

  @impl Paletea.Subcommand
  def run(%{args: %{theme: theme}}) do
    conf = Paletea.ThemeConfig.parse(Path.join(XDG.get_data_path(), theme))

    %{
      "wallpapers" => _wallpapers,
      "whitelist" => whitelist,
      "blacklist" => blacklist
    } = conf

    if "any" in blacklist do
      IO.puts("All modules are blacklisted")
      exit(1)
    end

    AppModule.start(theme, conf, whitelist, blacklist)
  end
end
