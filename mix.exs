defmodule Zurbex.Mixfile do
  use Mix.Project

  def project do
    [app: :zurbex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:slime, ">= 0.0.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ]
  end
end
