defmodule Paletea.Subcommands.New do
  @behaviour Paletea.Subcommand
  alias Paletea.ColorBackend, as: ColorBackend

  @impl Paletea.Subcommand
  def args_info() do
    [
      new: [
        name: "new",
        about: "Create new theme",
        args: [
          theme: [
            value_name: "theme",
            help: "Theme name",
            required: true,
            parser: :string
          ]
        ],
        options:
          Enum.map(0..7, fn i ->
            name = "color#{i}"

            {String.to_atom(name),
             [
               value_name: name,
               long: "--color#{i}",
               help: "Explicitly adjust color #{i}",
               parser: fn str ->
                 if Regex.match?(~r/^#[a-f0-9]{6}$/i, str) do
                   {:ok, str}
                 else
                   {:error, "Hex rgb values were expected, but got something else"}
                 end
               end
             ]}
          end) ++
            [
              wallpaper: [
                value_name: "wallpaper",
                short: "-w",
                long: "--wallpaper",
                help: "Path to a wallpaper files",
                multiple: true,
                parser: :string,
                default: []
              ],
              backend: [
                value_name: "backend",
                short: "-b",
                long: "--backend",
                help: "Backend to gather colors from wallpaper",
                parser: :string,
                default: "image_magick_magic"
              ]
            ]
      ]
    ]
  end

  @impl Paletea.Subcommand
  def run(args) do
    %{
      args: %{theme: theme},
      options: %{
        backend: backend,
        wallpaper: wallpapers,
        color0: color0,
        color1: color1,
        color2: color2,
        color3: color3,
        color4: color4,
        color5: color5,
        color6: color6,
        color7: color7
      }
    } = args

    data_path = XDG.get_data_path()
    theme_dir = Path.join(data_path, theme)
    wallpapers_dir = Path.join(theme_dir, "wallpapers")

    wallpapers = copy_wallpapers(wallpapers, wallpapers_dir)

    case wallpapers do
      [head | _] -> ColorBackend.get_colors(head, backend)
      _ -> ColorBackend.get_default_colors()
    end
    |> Enum.zip([
      color0,
      color1,
      color2,
      color3,
      color4,
      color5,
      color6,
      color7
    ])
    |> Enum.map(fn {v1, v2} -> v2 || v1 end)
    |> Paletea.ThemeConfig.write_config(wallpapers, theme_dir)
  end

  defp copy_wallpapers([], _), do: []

  defp copy_wallpapers(wallpapers, wallpapers_dir) do
    wallpapers
    |> Enum.map(&Path.expand/1)
    |> Enum.filter(&File.exists?/1)
    |> Enum.with_index(fn e, i -> {e, i + 1} end)
    |> Enum.map(fn {e, i} ->
      new_path = Path.join(wallpapers_dir, "#{i}#{Path.extname(e)}")

      case PaleFile.copy(e, new_path) do
        :ok -> new_path
        {:error, reason} -> IO.warn(reason)
      end
    end)
    |> Enum.uniq()
  end
end
