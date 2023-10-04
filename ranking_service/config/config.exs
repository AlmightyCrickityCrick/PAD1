import Config


config :ranking_service, Players.Repo,
  database: "ranking_service_repo",
  username: "user",
  password: "pass",
  hostname: "ranking_service_database",
  port: 5432

config :ranking_service, ecto_repos: [Players.Repo]
