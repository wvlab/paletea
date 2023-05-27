defmodule PaleFile do
  defp mkd_if_not_exists(dir) do
    if File.exists?(dir) do
      :ok
    else
      File.mkdir_p(dir)
    end
  end

  def write(path, iodata, modes \\ []) do
    abs_path = Path.expand(path)
    dir = Path.dirname(abs_path)

    with :ok <- mkd_if_not_exists(dir),
         :ok <- File.write(abs_path, iodata, modes) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def write!(path, iodata, modes \\ []) do
    case write(path, iodata, modes) do
      :ok ->
        :ok

      {:error, reason} ->
        raise File.Error,
          reason: reason,
          action: "write to file",
          path: IO.chardata_to_string(path)
    end
  end

  def copy(src, dest) do
    abs_src = Path.expand(src)
    src_dir = Path.dirname(abs_src)
    abs_dest = Path.expand(dest)
    dest_dir = Path.dirname(abs_dest)

    with :ok <- mkd_if_not_exists(src_dir),
         :ok <- mkd_if_not_exists(dest_dir),
         {:ok, _} <- File.copy(abs_src, abs_dest) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def copy!(path, iodata, modes \\ []) do
    case write(path, iodata, modes) do
      :ok ->
        :ok

      {:error, reason} ->
        raise File.Error,
          reason: reason,
          action: "copy file",
          path: IO.chardata_to_string(path)
    end
  end

  def exists?(path) do
    path |> Path.expand() |> File.exists?()
  end
end

defmodule PaleIO do
  def confirm(
        prompt \\ "Are you sure? [Y/n] ",
        {agree, disagree} \\ {["n", "no"], ["y", "yes"]},
        opts \\ []
      ) do
    err_message = Keyword.get(opts, :err_message, "Uknown answer, try again")
    default = Keyword.get(opts, :default, false)

    answer = IO.gets(prompt) |> String.trim() |> String.downcase()

    cond do
      answer == "" ->
        default

      answer in Enum.map(agree, &String.downcase/1) ->
        true

      answer in Enum.map(disagree, &String.downcase/1) ->
        false

      true ->
        IO.puts(err_message)
        confirm(prompt, {agree, disagree}, opts)
    end
  end
end

defmodule XDG do
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
