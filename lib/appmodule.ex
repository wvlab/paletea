defmodule Paletea.AppModule do
  @appmodules [
    Paletea.AppModules.Kitty,
    Paletea.AppModules.XtermSeq
  ]

  # TODO: add standart config to create default app config,
  @callback run(String.t(), pid(), map()) :: any()

  def all_names() do
    Enum.map(all_modules(), & &1.modulename())
  end

  def all_modules() do
    @appmodules
  end

  def start(mods, theme, parent, conf) do
    mods
    |> Enum.map(fn m ->
      Module.concat(Paletea.AppModules, Macro.camelize(m))
    end)
    |> Enum.map(fn m -> spawn(m, :run, [theme, parent, conf]) end)
    |> watch_modules()
  end

  def watch_modules([]) do
  end

  def watch_modules(processes) do
    receive do
      {mod, pid, :ok} ->
        IO.puts([mod, " is complete"])
        watch_modules(List.delete(processes, pid))

      {mod, pid, :error, reason} ->
        IO.warn([mod, " failed, reason: ", reason])
        watch_modules(List.delete(processes, pid))
    after
      10_000 -> processes |> Enum.filter(&Process.alive?/1) |> watch_modules()
    end
  end

  def default_module_path(theme, mod) do
    Path.join([XDG.get_data_path(), theme, "modules", mod])
  end
end
