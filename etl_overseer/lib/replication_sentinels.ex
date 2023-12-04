defmodule ReplicationSentinels do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: String.to_atom("rs#{args}"))
  end

  def init(args) do

    {:ok, %{db_id: args}}
  end

  def handle_cast({:replicate, records}, state) do
    repo = GenServer.call(ReplicationOverseer, {:replica, state[:db_id]})
    IO.puts("Replicating DB in replica #{state[:db_id]}")
    success = repo.insert_all(Schemas.Player, records, on_conflict: {:replace, [:is_banned, :rank]}, conflict_target: :id)
    IO.puts("Replicated DB, result is")
    IO.inspect(success)
    {:noreply, state}
  end
end
