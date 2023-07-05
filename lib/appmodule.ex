defmodule Paletea.AppModule do
  @appmodules [
    Paletea.AppModules.Kitty,
    Paletea.AppModules.XtermSeq,
    Paletea.AppModules.Hyprland,
    Paletea.AppModules.Ratbag
  ]

  @callback run(String.t(), map()) :: any()

  def all_names() do
    Enum.map(all_modules(), & &1.modulename())
  end

  def all_modules() do
    @appmodules
  end

  def start(mods, theme, conf) do
    mods
    |> Enum.map(&Module.concat(Paletea.AppModules, Macro.camelize(&1)))
    |> Enum.map(fn mod ->
      Task.async(fn ->
        try do
          apply(mod, :run, [theme, conf])
        rescue
          # TODO: make better error showing
          err -> IO.inspect([mod, err])
        end
      end)
    end)
    |> Task.await_many(:infinity)
  end

  def default_module_path(theme, mod) do
    Path.join([XDG.get_data_path(), theme, "modules", mod])
  end

  defmacro __using__(_opts) do
    quote do
      alias Paletea.AppModule, as: AppModule
      @behaviour AppModule
    end
  end
end
