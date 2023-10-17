defmodule GameMasterDirector do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(init_arg) do
    # Start timer to see if too many malicious user actions close together
    :timer.send_after(60000, self(), :check)
    {:ok, %{}}
  end

  def handle_call({:join, id}, _from, state) do
    reply = createLobby(id)
    if reply != nil do
      {:reply, {:ok, reply}, state}
    else
      {:reply, {:error, reply}, state}
    end
  end

  def handle_call({:joinprivate, id, friends}, _from, state) do
    reply = createPrivateLobby(id, friends)
    if reply != nil do
      {:reply, {:ok, reply}, state}
    else
      {:reply, {:error, reply}, state}
    end
  end

  def handle_cast({:finalize, game_info}, state) do
    _res = GameStrategy.addGame(game_info.lobby, game_info.started_time, game_info.winner, game_info.players)
    for player <- game_info.players do
      if player != game_info.winner do
        modifyRank(player, -5)
      else
        modifyRank(player, 5)
      end

    end

    _result = :ets.delete(:lobby_registry, game_info.lobby)
    {:noreply, state}
  end

  def handle_cast({:red, user}, state) do
    new_state = if Map.has_key?(state, user) do
      state |> Map.put(user, Map.get(state, user) + 1)
    else
      state|> Map.put(user, 1)
    end
    {:noreply, new_state}
  end

  def handle_info(:check, state) do
    red_user = Map.filter(state, fn {_key, value} -> value >= 3 end)
    for {usr, _v} <- red_user do
      IO.puts("Banning user #{usr}")
      _result = HTTPoison.post("http://gateway:8080/banUser", Poison.encode!(%{id: usr}))
    end
    x = :timer.send_after(60000, self(), :check)
    {:noreply, %{}}
  end

  def modifyRank(user_id, value) do
    _result = HTTPoison.post("http://gateway:8080/changeRank", Poison.encode!(%{id: user_id, value: value}))
  end

  def createLobby(user_id) do
    lobbies = :ets.tab2list(:lobby_registry)
    IO.inspect(lobbies)

    {res, lobby_nr} = case length(lobbies) do
      0 ->  nr = Enum.random(10000000 .. 99999999)
            :ets.insert(:lobby_registry, {"lobby#{nr}", 1})
            {:new, nr}
      i when i >=4  ->
      available_lobbies = Enum.filter(lobbies, fn {_lobby, nr} -> nr < 4 end )
      if length(available_lobbies) == 0 do
        {:error, nil}
      else
        {lobby, nr} = List.first(available_lobbies)
        :ets.insert(:lobby_registry, {lobby, nr + 1})
        IO.puts("Assigned #{lobby}")
        n = String.replace(lobby, "lobby", "") |> String.to_integer()
        {:assigned, n}
      end
      i when i < 4 ->
        # Search for lobbies with less than 4 players
        available_lobbies = Enum.filter(lobbies, fn {_lobby, nr} -> nr < 4 end )
        #Create Lobby
        if length(available_lobbies) == 0 do
          nr = Enum.random(10000000 .. 99999999)
          :ets.insert(:lobby_registry, {"lobby#{nr}", 1})
         {:new, nr}
        #Return existing lobby
        else
          {lobby, nr} = List.first(available_lobbies)
          :ets.insert(:lobby_registry, {lobby, nr + 1})
          IO.puts("Assigned #{lobby}")
          n = String.replace(lobby, "lobby", "") |> String.to_integer()
          {:assigned, n}
        end
    end

    case res do
      :assigned ->
        GenServer.cast(String.to_atom("lobby#{lobby_nr}"), {:add_player, user_id})
        %{lobby: "/lobby/#{lobby_nr}"}
      :new ->
        DynamicSupervisor.start_child(
          GameLobbySupervisor,
          Supervisor.child_spec(
            {GameMaster, %{:name => String.to_atom("lobby#{lobby_nr}"), :players => [user_id], :type => :public}},
            id: String.to_atom("lobby#{lobby_nr}"),
            restart: :temporary
            )
          )
        %{lobby: "/lobby/#{lobby_nr}"}
      :error ->
        nil
    end
  end

  def createPrivateLobby(user_id, friends_id) do
    lobby_nr = Enum.random(10000000 .. 99999999)
    DynamicSupervisor.start_child(GameLobbySupervisor,
    Supervisor.child_spec(
            {GameMaster, %{:name => String.to_atom("lobby#{lobby_nr}"), :players => [user_id | friends_id], :type => :private}},
            id: String.to_atom("lobby#{lobby_nr}"),
            restart: :temporary
            )
    )
    %{lobby: "/lobby/#{lobby_nr}"}
  end

  def get_lobby_nr() do
    DynamicSupervisor.count_children(GameLobbySupervisor) |> Map.get(:active)
  end

end
