defmodule ReplicationOverseer do
  use GenServer
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    x = :timer.send_after(5000, {:verify_db})
    {:ok, %{repo: Players.Repo, replicas: [ Players.Repo.Replica1, Players.Repo.Replica2]}}
  end

  def handle_call({:replica, nr}, _from, state) do
    {:reply, Enum.at(state[:replicas], nr), state}
  end

  def handle_info({:verify_db}, state) do
    IO.puts("Checking DB")
    rec = try do
      state[:repo].all(Schemas.Player)
    rescue
      _ ->
        IO.puts("DB down")
        :error
    end
    new_state = if rec == :error do
      new_replicas = List.replace_at(state[:replicas], 0, state[:repo])
      #TODO: Send the bad news to the Ranking Services via Gateway. Must contain "repo" field with a number from 1 to 3
      res = HTTPoison.post("http://gateway:8080/updateDB", Poison.encode!(%{repo: 1}))
      %{repo: Enum.at(state[:replicas], 0), replicas: new_replicas}
    else
      IO.inspect(rec)
      GenServer.cast(:rs0, {:replicate, rec})
      GenServer.cast(:rs1, {:replicate, rec})
      state
    end
    x = :timer.send_after(60000, {:verify_db})
    {:noreply, new_state}
  end


end
