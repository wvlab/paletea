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
        ]
        # options: [
        #  format: [
        #    short: "-f",
        #    long: "--format",
        #    help: "Format in which data will be printed",
        #    default: "plain",
        #    parser: :string
        #  ]
        # ]
      ]
    ]
  end

  @impl Paletea.Subcommand
  def run(%{args: args, options: _opts}) do
    case args do
      %{category: "themes", subcategory: nil} ->
        themes()

      %{category: "colors", subcategory: theme} when not is_nil(theme) ->
        colors(theme)

      _ ->
        IO.warn("Can't find that category or subcategory")
    end
  end

  defp print_list(enumerable, offset \\ 1) do
    enumerable
    |> Enum.with_index(offset)
    |> Enum.each(fn
      {theme, index} -> IO.puts([to_string(index), ". ", theme])
    end)
  end

  defp themes() do
    themes_dir = XDG.get_data_path()

    case File.ls(themes_dir) do
      {:ok, list} ->
        list
        |> Enum.filter(&File.exists?(Path.join(themes_dir, &1)))
        |> print_list()

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  defp colors(theme) do
    path = Path.join([XDG.get_data_path(), theme, "theme.toml"])

    %{
      "colors" => colors
    } = Toml.decode_file!(path)

    colors
    |> Enum.map(&elem(&1, 1))
    |> print_list(0)
  end
end
