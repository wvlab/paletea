defmodule Paletea.Subcommands.List do
  @behaviour Paletea.Subcommand

  @impl Paletea.Subcommand
  def args_info() do
    [
      list: [
        name: "list",
        about: "List items from category and subcategory",
        args: [
          category: [
            value_name: "category",
            help: "Category",
            required: true,
            parser: :string
          ],
          subcategory: [
            value_name: "subcategory",
            help: "Subcategory",
            required: false,
            parser: :string
          ]
        ],
        options: [
          format: [
            short: "-f",
            long: "--format",
            help: "Format in which data will be printed",
            default: "plain",
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
