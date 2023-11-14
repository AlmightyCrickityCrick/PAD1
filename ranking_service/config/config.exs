import Config


config :ranking_service, Players.Repo,
  database: "ranking_service_repo",
  username: "user",
  password: "pass",
  hostname: "ranking_service_database",
  port: 5432

config :ranking_service, ecto_repos: [Players.Repo]

config :ranking_service, RedisCache,
  mode: :redis_cluster,
  redis_cluster: [
    configuration_endpoints: [
    endpoint1_conn_opts: [
      host: "redis_cache_node_1",
      port: 6379
      ]
    ],
    override_master_host: true
  ]
