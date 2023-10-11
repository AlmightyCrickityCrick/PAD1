defmodule RankingService do
  use Application

  def start(_type, _args) do

    {container_id, host_port} = figure_out_self()
    IO.puts("Hi i am #{container_id} listening to #{host_port}")

    children = [
      {Plug.Cowboy, scheme: :http, plug: RankingServer, options: [port: 8080] },
      Players.Repo,
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
end
