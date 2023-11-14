defmodule RankingService.MixProject do
  use Mix.Project

  def project do
    [
      app: :ranking_service,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RankingService, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.15"},
      {:redix, "~> 1.1"},
      {:castore, ">= 0.0.0"},
      {:nebulex_redis_adapter, "~> 2.3"},
      {:crc, "~> 0.10"},
      {:jchash, "~> 0.1.3"}
    ]
  end
end
