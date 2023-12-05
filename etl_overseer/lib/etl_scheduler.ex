defmodule EtlScheduler do
use GenServer

def start_link(args) do
  GenServer.start_link(__MODULE__, args, name: __MODULE__)
end

def init(args) do
  x = :timer.send_after(5000, {:backup})
  {:ok, %{}}
end

def handle_info({:backup}, state) do
  IO.puts("Backuping data to warehouse")
  ranking_repo = GenServer.call(ReplicationOverseer, {:replica, 1})
  user_info_raw = ranking_repo.all(Schemas.Player)
  game_info = GameHistory.Repo.all(Schemas.Game)

  user_info = for u <- user_info_raw do
    %{user_id: u.id, rank: u.rank, is_banned: u.is_banned, time: DateTime.to_string(DateTime.utc_now())}
  end

  game_info = for u <- game_info do
    %{
      lobby_number: u.lobby_number,
      time_started: u.time_started,
      time_ended: u.time_ended,
      winner: u.winner,
      players: u.players
    }
  end

  res = UnoWarehouse.Repo.insert_all(Schemas.PlayerEvo, user_info, on_conflict: :nothing)
  IO.puts("Backuping players result")
  res = UnoWarehouse.Repo.insert_all(Schemas.Game, game_info, on_conflict: :nothing, conflict_target: :lobby_number)
  IO.puts("Backuping games result")
  x = :timer.send_after(300000, {:backup})
  {:noreply, state}
end
end
