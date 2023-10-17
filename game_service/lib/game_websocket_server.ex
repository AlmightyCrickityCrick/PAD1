defmodule GameWebsocketServer do
  @behaviour :cowboy_websocket

  def init(request, _state) do
    user_id = String.replace(request.qs, "userid=", "")
    state = %{registry_key: request.path, lobby_nr: String.replace(request.path,  "/lobby/", ""), user_id: String.to_integer(user_id)}
    IO.inspect(state)

    {:cowboy_websocket, request, state}
  end

  def websocket_init(state) do
    GameRegistry |> Registry.register(state.registry_key, state.user_id)
    responses = GenServer.call(String.to_atom("lobby#{state.lobby_nr}"), {:join, state.user_id})
    Process.send(self(), Poison.encode!(responses), [])
    if Map.get(responses, :status) == :success do
      {:ok, state}
    else
      GenServer.cast(GameMasterDirector, {:red, state.user_id})
      {:close, state}
    end
  end

  def websocket_handle({:text, json}, state) do
    message = Poison.decode!(json)
    cond do
      state.user_id != message["id"] ->
        GenServer.cast(GameMasterDirector, {:red, state.user_id})
        {:reply, {:text, "Violation of Game Integrity will be punished. Please stop."}, state}

      message["exit"] == true ->
        responses = GenServer.call(String.to_atom("lobby#{state.lobby_nr}"), {:exit, message["id"]})
        GameRegistry
        |> Registry.dispatch(state.registry_key, fn(entries) ->
          for {pid, user_id} <- entries do
            IO.inspect(user_id)
            if pid != self() do
              Process.send(pid, Poison.encode!(responses[user_id]), [])
            end
          end
        end)
        {:close, state}

      true ->
        responses = GenServer.call(String.to_atom("lobby#{state.lobby_nr}"), {:move, message})
        GameRegistry
        |> Registry.dispatch(state.registry_key, fn(entries) ->
          for {pid, user_id} <- entries do
            IO.inspect(user_id)
            if pid != self() do
              Process.send(pid, Poison.encode!(responses[user_id]), [])
            end
          end
        end)

        {:reply, {:text, Poison.encode!(responses[state.user_id])}, state}
  end
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
