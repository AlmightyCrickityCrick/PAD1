defmodule GameServer do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison
  plug :match
  plug :dispatch

  get "/"  do
    send_resp(conn, 200, "Authorised Personnel only")
  end

  get "/getHealth" do
    send_resp(conn, 200, "")
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
    game = GameStrategy.createLobby(Map.get(body, "id"))

    encoded_game = Poison.encode!(game)
    send_resp(conn, 200, encoded_game)
  end

  post "/privatejoin" do
    body = conn.body_params
    game = GameStrategy.createPrivateLobby(Map.get(body, "id"), Map.get(body, "friend_id"))

    encoded_game = Poison.encode!(game)
    send_resp(conn, 200, encoded_game)
  end

  match _ do
    Logger.info("not correct URL given?")
    send_resp(conn, 400, "")
  end

end
