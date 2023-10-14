defmodule GameMasterDirectorTest do
  use ExUnit.Case
  doctest GameMasterDirector

  test "create_lobby" do
    IO.puts("Create lobby running")
    {result, game} = GenServer.call(GameMasterDirector, {:join, 1})
    assert  result == :ok
  end

  test "join_lobby" do
    IO.puts("Join lobby running")
    {result, game} = GenServer.call(GameMasterDirector, {:join, 2})
    assert  result == :ok
  end

  test "get_lobby_count" do
    IO.puts("Test for getting Lobby count")
    result = GameMasterDirector.get_lobby_nr()
    IO.puts("Lobbies == #{result}")
    assert result == 1
  end

  test "create_private_lobby" do
    IO.puts("Create private lobby running")
    {result, game} = GenServer.call(GameMasterDirector, {:joinprivate, 1, [2, 3, 4]})
    assert  result == :ok
  end

  test "get_lobby_count2" do
    IO.puts("Test for getting Lobby count2")
    result = GameMasterDirector.get_lobby_nr()
    IO.puts("Lobbies == #{result}")
    assert result == 2
  end

  test "lobby_full_check" do
    IO.puts("Full lobby running")
    :ets.delete_all_objects(:lobby_registry)
    :ets.insert(:lobby_registry, {"lobby1", 4})
    :ets.insert(:lobby_registry, {"lobby2", 4})
    :ets.insert(:lobby_registry, {"lobby3", 4})
    :ets.insert(:lobby_registry, {"lobby4", 4})

    {result, game} = GenServer.call(GameMasterDirector, {:join, 1})
    assert  result == :error
  end
end
