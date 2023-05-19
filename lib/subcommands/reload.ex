defmodule Paletea.Subcommands.Reload do
  @behaviour Paletea.Subcommand

  @impl Paletea.Subcommand
  def args_info() do
    [
      reload: [
        name: "reload",
        about: "Hot-reload module or whole theme",
        args: [
          module: [
            value_name: "module",
            required: false,
            parser: :string,
            multiple: true
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
