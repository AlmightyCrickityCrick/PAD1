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
      time_started: DateTime.to_string(DateTime.utc_now()),
      time_ended: DateTime.to_string(DateTime.utc_now()),
      winner: winner,
      players: players
      })
    {_result, game} = GameHistory.Repo.insert(changeset)
    IO.inspect(game)
    addGameToCache(game)
    game
  end

  def addGameToCache(game) do
   result = Redix.command(:redix, ["SET", game.lobby_number, Poison.encode!(game)])
   IO.inspect(result)
  end

  def createLobby(user_id) do

    #TODO: Search for any non fully occupied lobbies first

    lobby_nr = Enum.random(10000000 .. 99999999)
    DynamicSupervisor.start_child(GameLobbySupervisor,
    {GameMaster, %{:name => "lobby#{lobby_nr}", :players => [user_id], :type => :public}})

    %{lobby: "/lobby/#{lobby_nr}"}
  end

  def createPrivateLobby(user_id, friends_id) do
    lobby_nr = Enum.random(10000000 .. 99999999)
    DynamicSupervisor.start_child(GameLobbySupervisor,
    {GameMaster, %{:name => "lobby#{lobby_nr}", :players => [user_id | friends_id], :type => :private}})
    %{lobby: "/lobby/#{lobby_nr}"}
  end

end




  #    :ets.insert(:spotify, {:code, code})
#    {_, code} = List.first(:ets.lookup(:spotify, :code))
    # :ets.lookup_element()
    # :ets.lookup(:lobby_registry)
    # :ets.update_element()
