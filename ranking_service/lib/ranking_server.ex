defmodule RankingServer do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:json], pass: ["text/*"], json_decoder: Poison
  plug :match
  plug :dispatch

  get "/"  do
    send_resp(conn, 200, "Authorised Personnel only")
  end

  post "/getHealth" do
    
      send_resp(conn, 200, Poison.encode!(%{database: :ok, load: :ok}))
  end


  post "/register" do
    player = conn.body_params
    IO.inspect(player)

    user = RankingStrategy.register(player)
    # IO.puts(result)

    if user != nil do
      encoded_user = Poison.encode!(user)
      send_resp(conn, 201, encoded_user)
    else
      send_resp(conn, 400, "Not all fields have been completed")
    end
  end

  post "/login" do
    player = conn.body_params
    user = RankingStrategy.login(Map.get(player, "email"), Map.get(player, "password"))
    if user != nil do
      encoded_user = Poison.encode!(user)
      send_resp(conn, 200, encoded_user)
    else
      send_resp(conn, 400, "Incorrect email or password")
    end
  end

  get "/user/:usr_id" do
    user = RankingStrategy.get_user(usr_id)
    IO.inspect(user)
    if user != nil do
      encoded_user = Poison.encode!(user)
      send_resp(conn, 200, encoded_user)
    else
      send_resp(conn, 404, "User doesn't exist")
    end

  end





  match _ do
    Logger.info("not correct URL given?")
    send_resp(conn, 400, "")
  end

end
