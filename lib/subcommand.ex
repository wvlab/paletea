defmodule Paletea.Subcommand do
  # TODO: add doc
  # TODO: make proper definition
  @callback run(args :: any()) :: any()
  @callback args_info() :: list(Optimus.arg_spec_item())

  @subcommands [
    Paletea.Subcommands.New,
    Paletea.Subcommands.Change,
    Paletea.Subcommands.List,
    Paletea.Subcommands.Erase
  ]

  @aliases %{
    "n" => "new",
    "ch" => "change",
    "ls" => "list",
    "rm" => "erase"
  }

  # @spec process_argv(argv :: list(String.t()) :: list(String.t()))
  def process_argv(argv) do
    if argv == [] do
      ["--help"]
    else
      argv
    end
    |> Enum.with_index()
    |> Enum.map(fn
      {arg, 0} -> Map.get(@aliases, arg) || arg
      {arg, _} -> arg
    end)
  end

  def args_info(),
    do: Enum.map(all_subcommands(), & &1.args_info()) |> Enum.reduce(&++/2)

  def run({[subcommand], args}) do
    "Elixir.Paletea.Subcommands"
    |> Module.concat(Macro.camelize(to_string(subcommand)))
    |> then(& &1.run(args))
  end

  def all_subcommands() do
    @subcommands
  end
end
