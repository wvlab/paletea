defmodule Paletea.AppModules.XtermSeq do
  @behaviour Paletea.AppModule

  @modulename "xterm_seq"

  def modulename() do
    @modulename
  end

  @impl Paletea.AppModule
  def run(_theme, parent, %{"colors" => colors}) do
    # TODO: seems as bad approach
    color_sequence =
      colors
      |> Enum.with_index()
      |> Enum.map(fn {color, index} -> put_elem(color, 0, index) end)
      |> Enum.map_join(fn {index, color} -> set_color(index, color) end)

    # TODO: add special sequences
    sequences = [color_sequence]

    Path.wildcard("/dev/pts/*")
    |> Enum.filter(&Regex.match?(~r/^\/dev\/pts\/\d+$/, &1))
    |> Enum.each(&File.write(&1, sequences, [:binary, :write]))

    send(parent, {@modulename, self(), :ok})
  end

  defp set_color(index, color) do
    # TODO: add hack for vte based terminals
    "\e]4;#{index};#{color}\e\\"
  end
end
