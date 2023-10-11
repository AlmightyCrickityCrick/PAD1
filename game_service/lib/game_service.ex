defmodule GameService do
  use Application


  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    _lobbydb = :ets.new(:lobby_registry, [:named_table, :set, :public])

    {container_id, host_port} = figure_out_self()
    IO.puts("Hi i am #{container_id} listening to #{host_port}")
    children = [
      {Plug.Cowboy, scheme: :http, plug:  GameServer, options: [port: 7070, dispatch: dispatch()] },
      GameHistory.Repo,
      {Registry, keys: :duplicate, name: GameRegistry},
      Supervisor.child_spec({GameLobbySupervisor, []}, id: :lobby_sup, restart: :permanent),
      Supervisor.child_spec({GameMasterDirector, []}, id: :game_master_director, restart: :permanent),
      {Redix, host: "redis_game_cache", name: :redix, port: 6379}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
end


defp figure_out_self do
    {host_name, _} = System.cmd("sh", ["-c", "echo $HOSTNAME"])
    host_name = String.replace(host_name, "\n", "")
    IO.puts(host_name)

    result = HTTPoison.get!("http://host.docker.internal:2375/containers/#{host_name}/json") |> Map.get(:body)
    result = Poison.decode!(result)
    port = result |> Map.get("NetworkSettings") |> Map.get("Ports") |> Map.get("7070/tcp")|> List.first() |> Map.get("HostPort")
    {Map.get(result, "Id"), port}
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
