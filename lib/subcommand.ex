defmodule Paletea.Subcommand do
  # TODO: make proper definition
  @callback run(args :: any()) :: any()
  @callback args_info() :: list()

  @subcommands [
    Paletea.Subcommands.New,
    Paletea.Subcommands.Change,
    Paletea.Subcommands.Renew,
    Paletea.Subcommands.Edit,
    Paletea.Subcommands.List,
    Paletea.Subcommands.Erase,
    Paletea.Subcommands.Reload
  ]

  def args_info(),
    do: Enum.map(all_subcommands(), & &1.args_info()) |> Enum.reduce(&++/2)

  def run({[subcommand], args}) do
    "Elixir.Paletea.Subcommands"
    |> Module.concat(Macro.camelize(to_string(subcommand)))
    |> apply(:run, [args])
  end

  def all_subcommands() do
    @subcommands
  end
end
