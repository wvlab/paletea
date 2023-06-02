defmodule Paletea.MixProject do
  use Mix.Project

  def project do
    [
      app: :paletea,
      version: "0.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      test_coverage: coverage()
    ]
  end

  def application do
    []
  end

  defp coverage() do
    [
      ignore_modules: [Paletea.App]
    ]
  end

  defp deps do
    [
      {:optimus, "~> 0.2"},
      {:toml, "~> 0.7.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp escript do
    [
      main_module: Paletea.App
    ]
  end
end
