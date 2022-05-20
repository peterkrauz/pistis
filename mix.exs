defmodule Pistis.MixProject do
  use Mix.Project

  def project do
    [
      app: :pistis,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Pistis.Application, []}
    ]
  end

  defp deps do
    [
      {:ra, "~> 2.0"},
    ]
  end
end
