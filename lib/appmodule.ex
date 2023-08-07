defmodule Paletea.AppModule do
  alias Paletea.AppModules.PaStructtern, as: PaStructtern

  @appmodules [
    Paletea.AppModules.Kitty,
    Paletea.AppModules.XtermSeq,
    Paletea.AppModules.Hyprland,
    Paletea.AppModules.Ratbag
  ]

  # implement this for better solution when there will be more than one module
  # that appends "native" modules
  # @appendingmodules [Paletea.AppModules.PaStructtern]

  @callback run(String.t(), map()) :: any()

  defp module_name(mod) when is_atom(mod) do
    mod.modulename()
  end

  defp module_name(%PaStructtern{modulename: mod}) do
    mod
  end

  defp run_module(mod, theme, conf) when is_atom(mod) do
    Task.async(fn ->
      try do
        apply(mod, :run, [theme, conf])
      rescue
        # TODO: make better error showing
        err -> IO.inspect([mod, err])
      end
    end)
  end

  defp run_module(%PaStructtern{} = mod, theme, conf) do
    PaStructtern.run_module(mod, theme, conf)
  end

  defp all_modules(theme) do
    enabled = Paletea.AppConfig.get("enable", [])

    if "patterns" in enabled do
      @appmodules ++ PaStructtern.find_modules(theme)
    else
      @appmodules
    end
  end

  def start(theme, conf, whitelist, blacklist) do
    all_modules(theme)
    |> Enum.filter(
      if "any" in whitelist do
        fn _ -> true end
      else
        fn mod ->
          modname = module_name(mod)

          modname in whitelist and modname not in blacklist
        end
      end
    )
    |> Enum.map(&run_module(&1, theme, conf))
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
