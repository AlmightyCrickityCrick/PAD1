defmodule GameService do
  use Application


  def start(_type, _args) do
    _lobbydb = :ets.new(:lobby_registry, [:named_table, :set, :public])

    children = [
      {Plug.Cowboy, scheme: :http, plug:  GameServer, options: [port: 7070, dispatch: dispatch()] },
      GameHistory.Repo,
      {Registry, keys: :duplicate, name: GameRegistry},
      Supervisor.child_spec({GameLobbySupervisor, []}, id: :lobby_sup, restart: :permanent),
      {Redix, host: "redis_game_cache", name: :redix, port: 6379}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
end



defp dispatch do
  [
    {:_,
      [
        {"/lobby/[...]", GameWebsocketServer, []},
        {:_, Plug.Cowboy.Handler, {GameServer, []}}
      ]
    }
  ]
end
end
