import Config

config :game_service, GameHistory.Repo,
  database: "game_history_repo",
  username: "user",
  password: "pass",
  hostname: "game_history_database",
  port: 5432

config :game_service, ecto_repos: [GameHistory.Repo]

config :game_service, RedisCache,
  mode: :redis_cluster,
  redis_cluster: [
    configuration_endpoints: [
      endpoint1_conn_opts: [
        url: "redis://redis_cache_node_1:6379"
      ],
      endpoint2_conn_opts: [
        url: "redis://redis_cache_node_2:6379"

      ],
      endpoint3_conn_opts: [
        url: "redis://redis_cache_node_3:6379"
      ]
    ],
    override_master_host: true
  ]
