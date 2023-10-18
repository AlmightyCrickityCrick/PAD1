defmodule GameStrategy do
  import Ecto.Query

  def getUserGames(id) do
    try do
      games = GameHistory.Repo.all(from g in Schemas.Game, where: ^id in g.players)
      games
    rescue
      _ -> nil
    end

  end
  def addGame(lobby, started_time, winner, players) do
    changeset = Schemas.Game.changeset(%Schemas.Game{}, %{
      lobby_number: lobby,
      time_started: started_time,
      time_ended: DateTime.to_string(DateTime.utc_now()),
      winner: winner,
      players: players
      })
    {_result, game} = GameHistory.Repo.insert(changeset)
    IO.inspect(game)
    game
  end

  def getUserInfo(user_id) do
   {result, user} = Redix.command(:redix, ["GET", user_id])
   IO.inspect(result)
   if user == nil do
    nil
   else
    u = Poison.decode!(user)
    IO.inspect(u)
    u
   end
  end

end
