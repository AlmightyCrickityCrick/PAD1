defmodule RankingService do
  use Application

  def start(_type, _args) do

    children = [
      {Plug.Cowboy, scheme: :http, plug: RankingServer, options: [port: 8080] },
      Players.Repo,
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
