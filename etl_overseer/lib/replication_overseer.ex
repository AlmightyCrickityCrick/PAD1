defmodule ReplicationOverseer do
  use Supervisor
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)

    children = [
      Supervisor.child_spec({ReplicationSentinel, 0}, id: String.to_atom("rs0"), restart: :permanent),
      Supervisor.child_spec({ReplicationSentinel, 1}, id: String.to_atom("rs1"), restart: :permanent),
    ]

    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
    x = :timer.send_after(5000, {:verify_db})
    {:ok, %{repo: Players.Repo, replicas: [ Players.Repo.Replica1, Players.Repo.Replica2]}}
  end

  def handle_call({:replica, nr}, state) do
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

      %{repo: Enum.at(state[:replicas], 0), replicas: new_replicas}
    else
      IO.inspect(rec)
      GenServer.cast(:rs0, {:replicate, rec})
      GenServer.cast(:rs1, {:replicate, rec})
      state
    end
    x = :timer.send_after(5000, {:verify_db})
    {:noreply, new_state}
  end


end
