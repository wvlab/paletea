defmodule Paletea.MixProject do
  use Mix.Project

  def project do
    [
      app: :paletea,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:owl, "~> 0.7"},
      {:optimus, "~> 0.2"},
      {:toml, "~> 0.7.0"},
    ]
  end

  defp escript do
    [
      main_module: Paletea.App
    ]
  end
end
