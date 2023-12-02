defmodule RankingService do
  use Application

  def start(_type, _args) do

    {container_id, host_port} = figure_out_self()
    IO.puts("Hi i am #{container_id} listening to #{host_port}")
    register(container_id, host_port)
    children = [
      {Plug.Cowboy, scheme: :http, plug: RankingServer, options: [port: 8080] },
      Players.Repo,
      RedisCache,
      # {Redix, host: "redis_game_cache", name: :redix, port: 6379}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp register(host_id, port) do
    result = HTTPoison.post("http://service_discovery:8080/register", Poison.encode!(%{type: :ranking_service, internal_port: 8080}))
    IO.inspect(result)
  end


  defp figure_out_self do
    {host_name, _} = System.cmd("sh", ["-c", "echo $HOSTNAME"])
    host_name = String.replace(host_name, "\n", "")
    IO.puts(host_name)

    result = HTTPoison.get!("http://host.docker.internal:2375/containers/#{host_name}/json") |> Map.get(:body)
    result = Poison.decode!(result)
    port = result |> Map.get("NetworkSettings") |> Map.get("Ports") |> Map.get("8080/tcp")|> List.first() |> Map.get("HostPort")
    {Map.get(result, "Id"), port}
end
end
