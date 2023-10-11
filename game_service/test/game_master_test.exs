defmodule GameMasterTest do
  use ExUnit.Case
  doctest GameMasterDirector

  test "create_table_deck" do
    deck = GameMaster.get_full_deck()
    assert length(deck) == 112

  end
  test "create_user_deck" do
    IO.puts("Create user deck")
    deck = GameMaster.get_full_deck()
    {user, new} = GameMaster.create_user_deck(deck)
    assert length(deck) == length(user) + length(new)
  end
end
