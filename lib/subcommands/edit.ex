defmodule Paletea.Subcommands.Edit do
  @behaviour Paletea.Subcommand

  @impl Paletea.Subcommand
  def args_info() do
    [
      edit: [
        name: "edit",
        about: "Edit config in order to change minor things",
        args: [
          element: [
            value_name: "name",
            help: "Name of element to edit",
            required: true,
            parser: :string
          ]
        ],
        flags: [
          gui: [
            short: "-g",
            long: "--gui",
            help: "Launch gui editor"
          ]
        ],
        options: [
          editor: [
            short: "-e",
            long: "--editor",
            value_name: "editor",
            help: "Editor program",
            required: false,
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
