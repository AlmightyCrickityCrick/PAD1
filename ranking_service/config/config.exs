import Config

config :ranking_service, Players.Repo,
  database: "ranking_service_repo",
  username: "user",
  password: "pass",
  hostname: "ranking_service_database",
  port: 5432

  # repos = %{
  #   Players.Repo.Replica1 => "ranking_service_database_slave_1",
  #   # Players.Repo.Replica2 => "ranking_service_database_slave_2",
  # }

  # for {repo, hostname} <- repos do
  #   config :ranking_service, repo,
  #     username: "repl_user",
  #     password: "repl_user",
  #     database: "ranking_service_repo",
  #     hostname: hostname,
  #     pool_size: 10
  # end

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
