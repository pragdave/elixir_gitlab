defmodule ElixirGitlab.Mixfile do
  use Mix.Project

  def project do
    [
      app:     :elixir_gitlab,
      version: "0.0.1",
      elixir:  "~> 1.2",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :httpoison,
      ],
      mod: {ElixirGitlab, []}
    ]
  end

  defp deps do
    [
      {:poison,    "~> 2.0.0"},
      {:httpoison, "~> 0.8.0"},

      {:bypass,   "~> 0.1", only: :test},
    ]
  end
end
