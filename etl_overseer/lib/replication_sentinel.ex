defmodule ReplicationSentinel do
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
    data_to_insert =
      Enum.map(records, fn player ->
        %{
          username: player.username,
          password: player.password,
          email: player.email,
          rank: player.rank,
          is_banned: player.is_banned
        }
      end)
    success = repo.insert_all(Schemas.Player, data_to_insert, on_conflict: {:replace, [:is_banned, :rank]}, conflict_target: :email)
    IO.puts("Replicated DB, result is")
    {:noreply, state}
  end
end
