defmodule GameMasterDirector do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  #TODO: Handle users joining depending on lobby type
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
            id: String.to_atom("lobby#{lobby_nr}")
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
            id: String.to_atom("lobby#{lobby_nr}")
            )
    )
    %{lobby: "/lobby/#{lobby_nr}"}
  end

end
