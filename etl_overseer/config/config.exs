import Config

config :etl_overseer, UnoWarehouse.Repo,
  database: "warehouse_repo",
  username: "user",
  password: "pass",
  hostname: "uno_warehouse_database",
  port: 5432

config :etl_overseer, GameHistory.Repo,
  database: "game_history_repo",
  username: "user",
  password: "pass",
  hostname: "game_history_database",
  port: 5432

  repos = %{
    Players.Repo => "ranking_service_database",
    Players.Repo.Replica1 => "ranking_service_database_slave_1",
    Players.Repo.Replica2 => "ranking_service_database_slave_2",
  }

  for {repo, hostname} <- repos do
    config :etl_overseer, repo,
      username: "user",
      password: "pass",
      database: "ranking_service_repo",
      hostname: hostname,
      pool_size: 10
  end

config :etl_overseer, ecto_repos: [Players.Repo, Players.Repo.Replica1, Players.Repo.Replica2, GameHistory.Repo, UnoWarehouse.Repo]
