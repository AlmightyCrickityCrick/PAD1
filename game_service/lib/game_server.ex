defmodule GameServer do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison
  plug :match
  plug :dispatch

  get "/"  do
    send_resp(conn, 200, "Authorised Personnel only")
  end

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  post "/getHealth" do
    nr_of_lobbies = GameMasterDirector.get_lobby_nr()
    if (nr_of_lobbies > 4) do
      send_resp(conn, 503, Poison.encode!(%{database: :ok, load: :full}))
    else
      send_resp(conn, 200, Poison.encode!(%{database: :ok, load: :ok}))
    end
  end


  get "/getGames/:id" do
    games = GameStrategy.getUserGames(id)
    encoded_games = Poison.encode!(games)
    send_resp(conn, 200, encoded_games)
  end

  post "/addGame" do
    body = conn.body_params
    game = GameStrategy.addGame(Map.get(body, "lobby_nr"), "1234", Map.get(body, "winner"), Map.get(body, "players"))
    encoded_game = Poison.encode!(game)
    send_resp(conn, 201, encoded_game)
  end

  post "/join" do
    body = conn.body_params
    {result, game}= GenServer.call(GameMasterDirector, {:join, Map.get(body, "id")})
    if result != :ok do
      send_resp(conn, 408, "Connection full")
    else
      encoded_game = Poison.encode!(game)
      send_resp(conn, 200, encoded_game)
    end
  end

  post "/privatejoin" do
    body = conn.body_params
    {result, game} = GenServer.call(GameMasterDirector, {:joinprivate, Map.get(body, "id"), Map.get(body, "friend_id")})
    if result != :ok do
      send_resp(conn, 408, "Connection full")
    else
      encoded_game = Poison.encode!(game)
      send_resp(conn, 200, encoded_game)
    end
  end

  match _ do
    Logger.info("not correct URL given?")
    send_resp(conn, 400, "")
  end

end
