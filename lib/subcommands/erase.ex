defmodule Paletea.Subcommands.Erase do
  @behaviour Paletea.Subcommand

  @impl Paletea.Subcommand
  def args_info() do
    [
      erase: [
        name: "erase",
        about: "Erase theme",
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
  def run(args) do
    %{
      args: %{theme: theme}
    } = args

    path = Path.join(XDG.get_data_path(), theme)

    if Owl.IO.confirm() do
      File.rm_rf!(path)
    end
  end
end
