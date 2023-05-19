defmodule XDG do
  # TODO: rename it? redo it in some other way?
  def get_home_path(dir, default) do
    (System.get_env(dir) || Path.join(System.user_home(), default))
    |> Path.join("paletea")
  end

  def get_cache_path() do
    get_home_path("XDG_CACHE_HOME", ".cache")
  end

  def get_config_path() do
    get_home_path("XDG_CONFIG_HOME", ".config")
  end

  def get_data_path() do
    get_home_path("XDG_DATA_HOME", ".local/share")
  end
end
