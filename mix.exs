defmodule Pistis.MixProject do
  use Mix.Project

  def project do
    [
      app: :pistis,
      version: "0.1.6",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: package_name(),
      package: package_info(),
      source_url: package_source_url(),
      description: package_description(),
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
      {:libcluster, "~> 3.3"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
    ]
  end

  defp package_name(), do: "pistis"
  defp package_description(), do: "Transparent, easily-configurable, distributed state-machine replicas."

  defp package_info() do
    [
      name: "pistis",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => package_source_url()}
    ]
  end

  defp package_source_url(), do: "https://github.com/peterkrauz/pistis"
end
