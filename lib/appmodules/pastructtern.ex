defmodule Paletea.AppModules.PaStructtern do
  alias Paletea.AppModules.PaStructtern
  defstruct modulename: "", content: ""

  def find_modules(theme) do
    [
      "#{XDG.get_config_path()}/paletea/patterns/*.toml",
      "/usr/share/paletea/patterns/*.toml",
      "#{XDG.get_data_path()}/paletea/#{theme}/patterns/*.toml"
    ]
    |> Enum.map(&Path.wildcard/1)
    |> Enum.reduce(&++/2)
    |> Enum.map(&parse_module/1)
  end

  defp parse_module(path) do
    %{"name" => name, "content" => content} = Toml.decode_file!(path)

    %PaStructtern{modulename: "pattern_" <> name, content: content}
  end

  def run_module(%PaStructtern{modulename: name, content: content}, theme, conf) do
    %{"location" => location} = Map.get(conf, name, %{"location" => nil})
    PaleFile.write!(
      location || Paletea.AppModule.default_module_path(theme, name),
      EEx.eval_string(content, conf: conf, theme: theme)
    )
  end
end
