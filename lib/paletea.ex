defmodule Paletea.App do
  @moduledoc """
  Paletea can manage themes and will create them! Offers 
  """
  @program_name "paletea"
  @version "0.0.1"
  alias Paletea.Subcommand, as: Subcommand

  def optparser() do
    Optimus.new!(
      name: @program_name,
      description: "Manage themes in one place!",
      version: @version,
      author: "WVlab",
      allow_unknown_args: false,
      parse_double_dash: true,
      subcommands: Subcommand.args_info()
    )
  end

  def main(argv) do
    Paletea.AppConfig.start_link()

    optparser()
    |> Optimus.parse!(Subcommand.process_argv(argv))
    |> Subcommand.run()
  end
end
