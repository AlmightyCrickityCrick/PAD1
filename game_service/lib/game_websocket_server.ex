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
    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    payload = Poison.decode!(json)
    message = json
    IO.inspect(json)
    IO.inspect(state)
    lobby_nr = String.replace(state.registry_key, "/lobby/", "")
    # responses = GenServer.call("lobby#{lobby_nr}", {:move, message})

    GameRegistry
    |> Registry.dispatch(state.registry_key, fn(entries) ->
      for {pid, user_id} <- entries do
        IO.inspect(user_id)
        if pid != self() do
          Process.send(pid, message, [])
        end
      end
    end)

    {:reply, {:text, message}, state}
  end

  def websocket_info(info, state) do
    {:reply, {:text, info}, state}
  end
end
