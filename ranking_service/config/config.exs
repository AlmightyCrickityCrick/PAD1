import Config

# config :ranking_service, Players.Repo,
#   database: "ranking_service_repo",
#   username: "user",
#   password: "pass",
#   hostname: "ranking_service_database",
#   port: 5432

  repos = %{
    Players.Repo => "ranking_service_database",
    Players.Repo.Replica1 => "ranking_service_database_slave_1",
    Players.Repo.Replica2 => "ranking_service_database_slave_2",
  }

  for {repo, hostname} <- repos do
    config :ranking_service, repo,
      username: "user",
      password: "pass",
      database: "ranking_service_repo",
      hostname: hostname
  end

config :ranking_service, ecto_repos: [Players.Repo, Players.Repo.Replica1, Players.Repo.Replica2]

config :ranking_service, RedisCache,
  mode: :redis_cluster,
  redis_cluster: [
    configuration_endpoints: [
    endpoint1_conn_opts: [
      host: "redis_cache_node_1",
      port: 6379
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
