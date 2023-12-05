import Config

config :etl_overseer, UnoWarehouse.Repo,
  database: "warehouse_repo",
  username: "user",
  password: "pass",
  hostname: "uno_warehouse_database",
  port: 5432,
  pool_size: 10

  config :etl_overseer, GameHistory.Repo,
  database: "game_history_repo",
  username: "user",
  password: "pass",
  hostname: "game_history_database",
  port: 5432,
  pool_size: 10


config :etl_overseer, Players.Repo,
      database: "ranking_service_repo",
      username: "user",
      password: "pass",
      hostname: "ranking_service_database",
      port: 5432,
      pool_size: 10


config :etl_overseer, Players.Repo.Replica1,
      database: "ranking_service_repo",
      username: "user",
      password: "pass",
      hostname: "ranking_service_database_slave_1",
      port: 5432,
      pool_size: 20,
      queue_target: 25,
      queue_interval: 60000


config :etl_overseer, Players.Repo.Replica2,
      database: "ranking_service_repo",
      username: "user",
      password: "pass",
      hostname: "ranking_service_database_slave_2",
      port: 5432,
      pool_size: 20,
      queue_target: 25,
      queue_interval: 60000

config :etl_overseer, ecto_repos: [Players.Repo, Players.Repo.Replica1, Players.Repo.Replica2, GameHistory.Repo, UnoWarehouse.Repo]
