defmodule Paletea.ColorBackend do
  # TODO: add foreground, background colors
  # TODO: add better typing, more constraints
  @callback get_colors(String.t()) :: list({integer(), integer(), integer()})

  # @backends [
  #  Paletea.ColorBackends.ImageMagickMagic,
  # ]

  def get_colors(wallpaper, backend) do
    Module.concat("Paletea.ColorBackends", Macro.camelize(backend)).get_colors(wallpaper)
  end

  def get_default_colors() do
    # TODO: provide some colorscheme by default
    for _ <- 1..8, do: {0, 0, 0}
  end
end
