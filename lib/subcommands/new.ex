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
        options: [
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
            default: "image_magick_magic",
            parser: :string
          ]
        ]
      ]
    ]
  end

  @impl Paletea.Subcommand
  def run(args) do
    %{
      args: %{theme: theme},
      options: %{backend: backend, wallpaper: wallpapers}
    } = args

    xdg_data_path = XDG.get_data_path()
    theme_dir = Path.join(xdg_data_path, theme)
    wallpapers_dir = Path.join(theme_dir, "wallpapers")

    unless File.dir?(wallpapers_dir), do: File.mkdir_p(wallpapers_dir)

    wallpapers = copy_wallpapers(wallpapers, wallpapers_dir)

    case wallpapers do
      [head | _] -> ColorBackend.get_colors(head, backend)
      _ -> ColorBackend.get_default_colors()
    end
    |> Paletea.ThemeConfig.write_config(wallpapers, theme_dir)
  end

  defp copy_wallpapers([], _) do
  end

  defp copy_wallpapers(wallpapers, wallpapers_dir) do
    wallpapers
    |> Enum.map(&Path.expand/1)
    |> Enum.filter(&File.exists?/1)
    |> Enum.with_index(fn e, i -> {e, i + 1} end)
    |> Enum.map(fn {e, i} ->
      new_path = Path.join(wallpapers_dir, "#{i}#{Path.extname(e)}")

      case File.copy(e, new_path) do
        {:ok, _} -> new_path
        {:error, reason} -> IO.warn(reason)
      end
    end)
    |> Enum.uniq()
  end
end
