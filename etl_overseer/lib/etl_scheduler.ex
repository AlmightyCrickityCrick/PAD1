defmodule EtlScheduler do
use GenServer

def start_link(args) do
  GenServer.start_link(__MODULE__, args, name: __MODULE__)
end

def init(args) do
  x = :timer.send_after(300000, {:backup})
  {:ok, %{}}
end

def handle_info({:backup}, state) do
  IO.puts("Backuping data to warehouse")
  ranking_repo = GenServer.call(ReplicationOverseer, {:replica, 1})
  user_info_raw = ranking_repo.all(Schemas.Player)
  game_info = GameHistory.Repo.all(Schemas.Game)

  user_info = for u <- user_info_raw do
    %Schemas.PlayerEvo{user_id: u.id, rank: u.rank, is_banned: u.is_banned, time: DateTime.to_string(DateTime.utc_now())}
  end

  res = UnoWarehouse.insert_all(Schemas.PlayerEvo, user_info, on_conflict: :nothing)
  IO.puts("Backuping players result")
  IO.inspect(res)
  res = UnoWarehouse.insert_all(Schemas.Game, game_info, on_conflict: :nothing, conflict_target: :lobby_number)
  IO.puts("Backuping games result")
  IO.inspect(res)
  x = :timer.send_after(300000, {:backup})
  {:noreply, state}
end
end
