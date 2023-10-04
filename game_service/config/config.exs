import Config

config :game_service, GameHistory.Repo,
  database: "game_history_repo",
  username: "user",
  password: "pass",
  hostname: "game_history_database",
  port: 5432

config :game_service, ecto_repos: [GameHistory.Repo]
