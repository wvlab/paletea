defmodule Paletea.Subcommands.Renew do
  @behaviour Paletea.Subcommand

  @impl Paletea.Subcommand
  def args_info() do
    [
      renew: [
        name: "renew",
        about: "Recreate colors from wallpaper. Doesn't break other settings",
        args: [
          theme: [
            value_name: "theme",
            help: "Theme name",
            required: true,
            parser: :string
          ]
        ],
        options: [
          wallpaper: [
            value_name: "wallpaper",
            short: "-w",
            long: "--wallpaper",
            help: "Path to a wallpaper files",
            multiple: true,
            parser: :string,
            default: [nil]
          ],
          backend: [
            value_name: "backend",
            short: "-b",
            long: "--backend",
            help: "Backend to gather colors from wallpaper",
            parser: :string
          ]
        ]
      ]
    ]
  end

  @impl Paletea.Subcommand
  def run(args) do
    args
  end
end
