defmodule Paletea.AppModule do
  @appmodules [
    Paletea.AppModules.Kitty,
    Paletea.AppModules.XtermSeq
  ]

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

  defmacro __using__(opts) do
    quote do
      alias Paletea.AppModule, as: AppModule
      @behaviour AppModule

      # TODO: Maybe extract it to another module like AppModuleConf or any other?
      # this may make spec more clear. How to name it then?
      unquote(
        if :conf in opts or :conf == opts do
          quote do
            def v(arg) do
              case arg do
                arg when is_atom(arg) and not is_nil(arg) and not is_boolean(arg) ->
                  quote(do: var!(unquote(arg)))

                arg ->
                  quote(do: unquote(arg))
              end
            end
          end
        end
      )
    end
  end
end
