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

    if Enum.member?(blacklist, "any") do
      IO.puts("All modules are blacklisted")
      exit(1)
    end

    if(Enum.member?(whitelist, "any"), do: AppModule.all_names(), else: whitelist)
    |> Enum.filter(fn m -> not Enum.member?(blacklist, m) end)
    |> AppModule.start(theme, self(), conf)
  end
end
